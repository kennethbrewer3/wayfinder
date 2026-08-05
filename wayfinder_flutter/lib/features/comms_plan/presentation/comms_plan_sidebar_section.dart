import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../access/providers/access_session_provider.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/presentation/map_object_markdown.dart';
import '../../markers/presentation/marker_radio_editor.dart';
import '../../markers/providers/markers_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../models/comms_challenge_table.dart';
import '../models/comms_plan_channel.dart';
import '../models/comms_radio_service.dart';
import '../providers/comms_plan_provider.dart';
import '../utils/comms_plan_schedule.dart';
import 'comms_challenge_table_preview.dart';
import 'comms_plan_editor_dialog.dart';

class CommsPlanSidebarSection extends ConsumerWidget {
  const CommsPlanSidebarSection({
    super.key,
    required this.onZoomTo,
  });

  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canManage = ref.watch(canManageLayersProvider);
    final offline = ref.watch(offlineModeActiveProvider);
    final plansAsync = ref.watch(commsPlansProvider);
    final markers = ref.watch(markersProvider).valueOrNull ?? const [];

    return ExpansionTile(
      initiallyExpanded: false,
      leading: const Icon(Icons.cell_tower_outlined),
      title: Text(l10n.commsPlanTitle),
      subtitle: Text(
        plansAsync.when(
          data: (plans) {
            final active = activeCommsPlan(plans);
            if (active == null) {
              return l10n.commsPlanSidebarEmpty;
            }
            final channels = decodeCommsPlanChannels(active.channelsJson);
            return l10n.commsPlanSidebarSubtitle(
              active.name,
              channels.length,
            );
          },
          loading: () => l10n.commsPlanSidebarLoading,
          error: (_, _) => l10n.commsPlanSidebarLoadFailed,
        ),
        style: theme.textTheme.bodySmall,
      ),
      children: [
        if (offline)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              l10n.commsPlanOfflineHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (canManage && !offline)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await showCommsPlanEditorDialog(
                      context: context,
                      ref: ref,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.commsPlanAddPlan),
                ),
                plansAsync.maybeWhen(
                  data: (plans) {
                    final active = activeCommsPlan(plans);
                    if (active == null) {
                      return const SizedBox.shrink();
                    }
                    return TextButton.icon(
                      onPressed: () async {
                        await showCommsPlanEditorDialog(
                          context: context,
                          ref: ref,
                          existing: active,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.commsPlanEditPlan),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        plansAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.commsPlanLoadFailed(error.toString())),
          ),
          data: (plans) {
            final active = activeCommsPlan(plans);
            if (active == null) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.commsPlanEmpty),
              );
            }

            final channels = channelsByNextNet(
              decodeCommsPlanChannels(active.channelsJson),
              timezoneIana: active.timezoneIana,
            );

            final otherPlans = [
              for (final plan in plans)
                if (plan.id != active.id) plan,
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    l10n.commsPlanBoardHeader(
                      active.name,
                      active.timezoneIana,
                    ),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                if (active.notes != null && active.notes!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: MapObjectMarkdownBody(
                      markdown: active.notes!,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _ChallengeTableSidebarRow(
                    plan: active,
                    canManage: canManage && !offline,
                  ),
                ),
                if (channels.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(l10n.commsPlanChannelsEmpty),
                  )
                else
                  for (final channel in channels)
                    _CommsChannelTile(
                      channel: channel,
                      timezoneIana: active.timezoneIana,
                      markers: markers,
                      onZoomTo: onZoomTo,
                    ),
                if (otherPlans.isNotEmpty) ...[
                  const Divider(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Text(
                      l10n.commsPlanOtherPlans,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  for (final plan in otherPlans)
                    ListTile(
                      dense: true,
                      title: Text(plan.name),
                      subtitle: Text(
                        l10n.commsPlanChannelsCount(
                          decodeCommsPlanChannels(plan.channelsJson).length,
                        ),
                      ),
                      trailing: canManage && !offline
                          ? PopupMenuButton<_PlanMenuAction>(
                              onSelected: (action) async {
                                switch (action) {
                                  case _PlanMenuAction.activate:
                                    await ref
                                        .read(commsPlansProvider.notifier)
                                        .updatePlan(
                                          plan.copyWith(
                                            active: true,
                                            updatedAt: DateTime.now().toUtc(),
                                          ),
                                        );
                                    final all =
                                        ref
                                            .read(commsPlansProvider)
                                            .valueOrNull ??
                                        const <CommsPlan>[];
                                    for (final other in all) {
                                      if (other.id == plan.id ||
                                          !other.active) {
                                        continue;
                                      }
                                      await ref
                                          .read(commsPlansProvider.notifier)
                                          .updatePlan(
                                            other.copyWith(
                                              active: false,
                                              updatedAt: DateTime.now().toUtc(),
                                            ),
                                          );
                                    }
                                  case _PlanMenuAction.edit:
                                    if (!context.mounted) {
                                      return;
                                    }
                                    await showCommsPlanEditorDialog(
                                      context: context,
                                      ref: ref,
                                      existing: plan,
                                    );
                                  case _PlanMenuAction.delete:
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          l10n.commsPlanDeleteConfirmTitle,
                                        ),
                                        content: Text(
                                          l10n.commsPlanDeleteConfirmMessage(
                                            plan.name,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: Text(l10n.actionCancel),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(true),
                                            child: Text(l10n.actionDelete),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await ref
                                          .read(commsPlansProvider.notifier)
                                          .delete(plan.id);
                                    }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: _PlanMenuAction.activate,
                                  child: Text(l10n.commsPlanMakeActive),
                                ),
                                PopupMenuItem(
                                  value: _PlanMenuAction.edit,
                                  child: Text(l10n.actionEdit),
                                ),
                                PopupMenuItem(
                                  value: _PlanMenuAction.delete,
                                  child: Text(l10n.actionDelete),
                                ),
                              ],
                            )
                          : null,
                    ),
                ],
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ],
    );
  }
}

enum _PlanMenuAction { activate, edit, delete }

class _CommsChannelTile extends ConsumerWidget {
  const _CommsChannelTile({
    required this.channel,
    required this.timezoneIana,
    required this.markers,
    required this.onZoomTo,
  });

  final CommsPlanChannel channel;
  final String timezoneIana;
  final List<MapMarker> markers;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final next = nextNetStartUtc(channel, timezoneIana: timezoneIana);
    final nextLabel = next == null
        ? l10n.commsPlanUnscheduled
        : l10n.commsPlanNextNet(
            DateFormat.E().add_Hm().format(next.toLocal()),
          );

    final service = commsRadioServiceLabel(l10n, channel.radioService);
    final permitted = findPermittedChannel(
      channel.radioService,
      channel.serviceChannelId,
    );
    final freq = permitted != null
        ? 'Ch ${permitted.numberLabel} · ${permitted.frequencyMHz} MHz'
        : channel.frequencyMHz == null
        ? null
        : '${channel.frequencyMHz} ${markerRadioModeLabel(l10n, channel.mode)}';

    final statusNote = channel.statusNote?.trim();
    final channelNotes = channel.notes?.trim();
    final subtitle = [
      service,
      commsChannelRoleLabel(l10n, channel.role),
      ?freq,
      nextLabel,
      if (statusNote != null && statusNote.isNotEmpty) statusNote,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          dense: true,
          leading: Tooltip(
            message: commsChannelAvailabilityLabel(
              l10n,
              channel.availability,
            ),
            child: Icon(
              Icons.circle,
              size: 14,
              color: _availabilityColor(channel.availability),
            ),
          ),
          title: Text(
            channel.netName?.trim().isNotEmpty == true
                ? '${channel.label} — ${channel.netName}'
                : channel.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _focusLinkedMarker(
            ref: ref,
            channel: channel,
            markers: markers,
            onZoomTo: onZoomTo,
          ),
        ),
        if (channelNotes != null && channelNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 16, 8),
            child: MapObjectMarkdownBody(
              markdown: channelNotes,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
      ],
    );
  }
}

class _ChallengeTableSidebarRow extends ConsumerWidget {
  const _ChallengeTableSidebarRow({
    required this.plan,
    required this.canManage,
  });

  final CommsPlan plan;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tables = decodeCommsChallengeTables(plan.challengeTableJson);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.commsChallengeTableTitle,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          tables.isEmpty
              ? l10n.commsChallengeTableMissing
              : l10n.commsChallengeTableCount(tables.length),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (canManage)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                final generated = generateCommsChallengeTable(
                  label: nextChallengeTableLabel(tables),
                );
                await ref
                    .read(commsPlansProvider.notifier)
                    .updatePlan(
                      plan.copyWith(
                        challengeTableJson: encodeCommsChallengeTables([
                          ...tables,
                          generated,
                        ]),
                        updatedAt: DateTime.now().toUtc(),
                      ),
                    );
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.commsChallengeTableGenerate),
            ),
          ),
        for (final table in tables)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.grid_on, size: 18),
            title: Text(table.label),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.commsChallengeTableView,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () async {
                    await showCommsChallengeTablePreview(
                      context: context,
                      planName: plan.name,
                      table: table,
                    );
                  },
                ),
                if (canManage)
                  IconButton(
                    tooltip: l10n.commsChallengeTableBurn,
                    icon: const Icon(
                      Icons.local_fire_department_outlined,
                      size: 18,
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            l10n.commsChallengeTableBurnConfirmTitle,
                          ),
                          content: Text(
                            l10n.commsChallengeTableBurnConfirmMessage,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(l10n.actionCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(l10n.commsChallengeTableBurn),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) {
                        return;
                      }
                      await ref
                          .read(commsPlansProvider.notifier)
                          .updatePlan(
                            plan.copyWith(
                              challengeTableJson: encodeCommsChallengeTables([
                                for (final item in tables)
                                  if (item.id != table.id) item,
                              ]),
                              updatedAt: DateTime.now().toUtc(),
                            ),
                          );
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

void _focusLinkedMarker({
  required WidgetRef ref,
  required CommsPlanChannel channel,
  required List<MapMarker> markers,
  required ValueChanged<LatLng> onZoomTo,
}) {
  final markerId = channel.markerId;
  if (markerId == null || markerId.isEmpty) {
    return;
  }
  MapMarker? marker;
  for (final candidate in markers) {
    if (candidate.id.uuid == markerId) {
      marker = candidate;
      break;
    }
  }
  if (marker == null) {
    return;
  }
  ref
      .read(selectedMapObjectProvider.notifier)
      .selectMarker(marker.id, openDetails: true);
  onZoomTo(LatLng(marker.latitude, marker.longitude));
}

Color _availabilityColor(CommsChannelAvailability availability) {
  return switch (availability) {
    CommsChannelAvailability.go => Colors.green.shade700,
    CommsChannelAvailability.noGo => Colors.red.shade700,
    CommsChannelAvailability.conditional => Colors.orange.shade800,
    CommsChannelAvailability.unknown => Colors.blueGrey,
  };
}
