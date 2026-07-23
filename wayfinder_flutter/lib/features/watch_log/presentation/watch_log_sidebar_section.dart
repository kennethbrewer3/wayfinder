import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../access/providers/access_session_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../watch_log/presentation/watch_log_details_section.dart';
import '../../watch_log/presentation/watch_log_entry_dialog.dart';
import '../../watch_log/providers/watch_log_provider.dart';

class WatchLogSidebarSection extends ConsumerWidget {
  const WatchLogSidebarSection({
    super.key,
    required this.onZoomTo,
  });

  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(canViewWatchLogProvider);
    if (!canView) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canAdd = ref.watch(canAddWatchLogProvider);
    final entriesAsync = ref.watch(watchLogEntriesProvider);
    final markers = ref.watch(markersProvider).valueOrNull ?? const [];
    final zones = ref.watch(zonesProvider).valueOrNull ?? const [];

    return ExpansionTile(
      initiallyExpanded: false,
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(l10n.watchLogTitle),
      subtitle: Text(
        l10n.watchLogSidebarHint,
        style: theme.textTheme.bodySmall,
      ),
      children: [
        if (canAdd)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await showWatchLogEntryDialog(context: context, ref: ref);
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.watchLogAddEntry),
              ),
            ),
          ),
        entriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.watchLogLoadFailed(error.toString())),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.watchLogEmpty),
              );
            }
            final visible = entries.take(20).toList();
            return Column(
              children: [
                for (final entry in visible)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      _severityIcon(WatchLogSeverity.parse(entry.severity)),
                      size: 20,
                    ),
                    title: Text(
                      entry.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _subtitle(l10n, entry, markers, zones),
                    ),
                    onTap: () {
                      _focusLinkedObject(
                        ref: ref,
                        entry: entry,
                        markers: markers,
                        zones: zones,
                        onZoomTo: onZoomTo,
                      );
                    },
                    trailing: canAdd
                        ? IconButton(
                            tooltip: l10n.actionEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () async {
                              await showWatchLogEntryDialog(
                                context: context,
                                ref: ref,
                                existing: entry,
                              );
                            },
                          )
                        : null,
                  ),
                if (entries.length > visible.length)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l10n.watchLogMoreEntries(entries.length - visible.length),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _subtitle(
  AppLocalizations l10n,
  WatchLogEntry entry,
  List<MapMarker> markers,
  List<MapZone> zones,
) {
  final when = DateFormat.MMMd().add_Hm().format(entry.occurredAt.toLocal());
  final severity = watchLogSeverityLabel(
    l10n,
    WatchLogSeverity.parse(entry.severity),
  );
  final objectName = _linkedObjectName(entry, markers, zones);
  final parts = <String>[when, severity];
  if (entry.author != null && entry.author!.trim().isNotEmpty) {
    parts.add(entry.author!);
  }
  if (objectName != null) {
    parts.add(objectName);
  }
  return parts.join(' · ');
}

String? _linkedObjectName(
  WatchLogEntry entry,
  List<MapMarker> markers,
  List<MapZone> zones,
) {
  if (entry.markerId != null) {
    for (final marker in markers) {
      if (marker.id == entry.markerId) {
        return marker.name;
      }
    }
  }
  if (entry.zoneId != null) {
    for (final zone in zones) {
      if (zone.id == entry.zoneId) {
        return zone.name;
      }
    }
  }
  return null;
}

void _focusLinkedObject({
  required WidgetRef ref,
  required WatchLogEntry entry,
  required List<MapMarker> markers,
  required List<MapZone> zones,
  required ValueChanged<LatLng> onZoomTo,
}) {
  if (entry.markerId != null) {
    for (final marker in markers) {
      if (marker.id == entry.markerId) {
        ref
            .read(selectedMapObjectProvider.notifier)
            .selectMarker(marker.id, openDetails: false);
        onZoomTo(LatLng(marker.latitude, marker.longitude));
        return;
      }
    }
  }
  if (entry.zoneId != null) {
    for (final zone in zones) {
      if (zone.id == entry.zoneId) {
        ref
            .read(selectedMapObjectProvider.notifier)
            .selectZone(zone.id, openDetails: false);
        // Zones lack a single center; leave zoom to selection listeners if any.
        return;
      }
    }
  }
}

IconData _severityIcon(WatchLogSeverity severity) {
  return switch (severity) {
    WatchLogSeverity.info => Icons.info_outline,
    WatchLogSeverity.notice => Icons.campaign_outlined,
    WatchLogSeverity.warning => Icons.warning_amber_outlined,
    WatchLogSeverity.critical => Icons.error_outline,
  };
}
