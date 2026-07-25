import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../access/providers/access_session_provider.dart';
import '../../map/providers/map_providers.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../../seasonal_overlays/models/seasonal_date_window.dart';
import '../../seasonal_overlays/presentation/create_seasonal_overlay_dialog.dart';
import '../../seasonal_overlays/providers/seasonal_overlays_provider.dart';

/// Matches settings general / map AppBar compact breakpoint.
const _settingsCompactBreakpoint = 720.0;

class SettingsSeasonalOverlaysTab extends ConsumerWidget {
  const SettingsSeasonalOverlaysTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overlaysAsync = ref.watch(seasonalOverlaysProvider);
    final showInactive = ref.watch(showInactiveSeasonalOverlaysProvider);
    final canManageLayers = ref.watch(canManageLayersProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.seasonalOverlaysSettingsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          canManageLayers
              ? l10n.seasonalOverlaysSettingsSubtitle
              : l10n.manageLayersPermissionDenied,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.seasonalOverlaysShowInactive),
          subtitle: Text(l10n.seasonalOverlaysShowInactiveHint),
          value: showInactive,
          onChanged: (value) {
            unawaited(
              ref
                  .read(showInactiveSeasonalOverlaysProvider.notifier)
                  .setEnabled(value),
            );
          },
        ),
        if (canManageLayers) ...[
          const SizedBox(height: 8),
          Text(
            l10n.seasonalOverlaysDrawHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.seasonalOverlaysInstalled,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        overlaysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(
            l10n.seasonalOverlaysLoadFailed(error.toString()),
          ),
          data: (overlays) {
            if (overlays.isEmpty) {
              return Text(l10n.seasonalOverlaysEmpty);
            }
            return Column(
              children: [
                for (final overlay in overlays)
                  _SeasonalOverlaySettingsTile(
                    overlay: overlay,
                    canManage: canManageLayers,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SeasonalOverlaySettingsTile extends ConsumerWidget {
  const _SeasonalOverlaySettingsTile({
    required this.overlay,
    required this.canManage,
  });

  final SeasonalOverlay overlay;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final active = isSeasonalOverlayCurrentlyActive(overlay);
    final schedule = SeasonalSchedule.parse(
      dateMode: overlay.dateMode,
      dateWindowsJson: overlay.dateWindowsJson,
    );
    final geometry = PolygonGeometry.fromJsonString(overlay.geometryJson);
    final isCompact =
        MediaQuery.sizeOf(context).width < _settingsCompactBreakpoint;

    final statusIcon = Icon(
      active ? Icons.calendar_month : Icons.calendar_month_outlined,
      color: active
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
    );
    final title = Text(overlay.name);
    final subtitle = Text(
      [
        active
            ? l10n.seasonalOverlayStatusActive
            : l10n.seasonalOverlayStatusInactive,
        schedule.isRecurring
            ? l10n.seasonalOverlayDateModeRecurring
            : l10n.seasonalOverlayDateModeAbsolute,
        l10n.seasonalOverlayWindowCount(schedule.windows.length),
      ].join(' · '),
    );
    // IconButton default padding insets the glyph past the text edge in the
    // stacked compact layout; strip it so actions flush with the title.
    final actionButtonStyle = isCompact
        ? IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            alignment: Alignment.centerLeft,
          )
        : null;
    final actions = Wrap(
      spacing: isCompact ? 12 : 4,
      runSpacing: 0,
      alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
      children: [
        if (canManage)
          IconButton(
            style: actionButtonStyle,
            tooltip: overlay.visible
                ? l10n.seasonalOverlayHide
                : l10n.seasonalOverlayShow,
            onPressed: () {
              unawaited(
                ref
                    .read(seasonalOverlaysProvider.notifier)
                    .setVisible(overlay.id, !overlay.visible),
              );
            },
            icon: Icon(
              overlay.visible
                  ? Icons.visibility
                  : Icons.visibility_off_outlined,
            ),
          ),
        if (canManage)
          IconButton(
            style: actionButtonStyle,
            tooltip: l10n.actionEdit,
            onPressed: () {
              unawaited(
                updateSeasonalOverlayFromForm(
                  context: context,
                  ref: ref,
                  overlay: overlay,
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        if (geometry != null)
          IconButton(
            style: actionButtonStyle,
            tooltip: l10n.seasonalOverlayZoomTo,
            onPressed: () {
              ref.read(sidebarProvider.notifier).setExpanded(false);
              context.go('/maps');
              unawaited(
                ref
                    .read(mapViewportProvider.notifier)
                    .moveTo(
                      center: geometry.labelPoint,
                      zoom: 14,
                    ),
              );
            },
            icon: const Icon(Icons.my_location_outlined),
          ),
        if (canManage)
          IconButton(
            style: actionButtonStyle,
            tooltip: l10n.actionDelete,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.seasonalOverlayDeleteTitle),
                  content: Text(
                    l10n.seasonalOverlayDeleteConfirm(overlay.name),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.actionCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.actionDelete),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(seasonalOverlaysProvider.notifier)
                    .delete(overlay.id);
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: isCompact
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusIcon,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle.merge(
                          style: theme.textTheme.titleMedium!,
                          child: title,
                        ),
                        const SizedBox(height: 4),
                        DefaultTextStyle.merge(
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          child: subtitle,
                        ),
                        actions,
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListTile(
              leading: statusIcon,
              title: title,
              subtitle: subtitle,
              trailing: actions,
            ),
    );
  }
}
