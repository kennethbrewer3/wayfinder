import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../models/marker_checklists.dart';
import '../providers/markers_provider.dart';

class MarkerChecklistsDetailsSection extends ConsumerWidget {
  const MarkerChecklistsDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  MapMarker _resolvedMarker(WidgetRef ref) {
    final markers = ref.watch(markersProvider).valueOrNull;
    if (markers == null) {
      return marker;
    }
    for (final candidate in markers) {
      if (candidate.id == marker.id) {
        return candidate;
      }
    }
    return marker;
  }

  Future<void> _persist(
    WidgetRef ref,
    MapMarker current,
    MarkerChecklists next,
  ) async {
    final client = ref.read(serverClientProvider);
    await client.mapMarker.updateMarker(
      current.copyWith(
        checklistsJson: next.toStorageJson(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    ref.invalidate(markersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final current = _resolvedMarker(ref);
    final checklists = MarkerChecklists.fromMarkerChecklistsJson(
      current.checklistsJson,
    );
    if (checklists.isEmpty) {
      return const SizedBox.shrink();
    }

    final offline = ref.watch(offlineModeActiveProvider);
    final kiosk = ref.watch(kioskModeActiveProvider);
    final canEdit = !offline && !kiosk;
    final dateFormat = DateFormat.yMMMd();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.markerChecklistsTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final (index, checklist)
                  in checklists.checklists.indexed) ...[
                if (index > 0) const Divider(height: 16),
                Text(
                  checklist.name,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  l10n.markerChecklistsProgress(
                    checklist.doneCount,
                    checklist.totalCount,
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                if (checklist.notes != null && checklist.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      checklist.notes!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                Text(
                  checklist.lastAuditedAt == null
                      ? l10n.markerChecklistsLastAuditedNever
                      : l10n.markerChecklistsLastAudited(
                          dateFormat.format(
                            checklist.lastAuditedAt!.toLocal(),
                          ),
                        ),
                  style: theme.textTheme.bodySmall,
                ),
                if (canEdit)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () async {
                        final nextLists = [...checklists.checklists];
                        nextLists[index] = checklist.copyWith(
                          lastAuditedAt: DateTime.now().toUtc(),
                        );
                        await _persist(
                          ref,
                          current,
                          MarkerChecklists(checklists: nextLists),
                        );
                      },
                      child: Text(l10n.markerChecklistsMarkAudited),
                    ),
                  ),
                for (final (itemIndex, item) in checklist.items.indexed)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: item.done,
                    title: Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: item.notes == null || item.notes!.isEmpty
                        ? null
                        : Text(item.notes!),
                    onChanged: canEdit
                        ? (value) async {
                            final nextItems = [...checklist.items];
                            nextItems[itemIndex] = item.copyWith(
                              done: value == true,
                            );
                            final nextLists = [...checklists.checklists];
                            nextLists[index] = checklist.copyWith(
                              items: nextItems,
                            );
                            await _persist(
                              ref,
                              current,
                              MarkerChecklists(checklists: nextLists),
                            );
                          }
                        : null,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
