import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/selected_line_provider.dart';
import '../../lines/utils/line_distance.dart';
import '../../map/providers/map_providers.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/presentation/map_objects_status.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';

class SidebarPanel extends ConsumerWidget {
  const SidebarPanel({
    super.key,
    required this.onZoomTo,
  });

  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebar = ref.watch(sidebarProvider);
    final markersAsync = ref.watch(markersProvider);
    final zonesAsync = ref.watch(zonesProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarHeader(
            expanded: sidebar.expanded,
            onToggle: () {
              ref.read(sidebarProvider.notifier).toggleExpanded();
            },
          ),
          if (sidebar.expanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<SidebarPanelTab>(
                segments: const [
                  ButtonSegment(
                    value: SidebarPanelTab.markers,
                    label: Text('Markers'),
                    icon: Icon(Icons.place_outlined),
                  ),
                  ButtonSegment(
                    value: SidebarPanelTab.zones,
                    label: Text('Zones'),
                    icon: Icon(Icons.layers_outlined),
                  ),
                ],
                selected: {sidebar.activeTab},
                onSelectionChanged: (selection) {
                  ref
                      .read(sidebarProvider.notifier)
                      .setActiveTab(selection.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<SidebarViewMode>(
                segments: const [
                  ButtonSegment(
                    value: SidebarViewMode.list,
                    label: Text('List'),
                  ),
                  ButtonSegment(
                    value: SidebarViewMode.tree,
                    label: Text('Tree'),
                  ),
                ],
                selected: {sidebar.viewMode},
                onSelectionChanged: (selection) {
                  ref
                      .read(sidebarProvider.notifier)
                      .setViewMode(selection.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sidebar.activeTab == SidebarPanelTab.markers
                  ? _MarkersPanel(
                      markersAsync: markersAsync,
                      sidebar: sidebar,
                      onZoomTo: onZoomTo,
                    )
                  : _ZonesPanel(
                      zonesAsync: zonesAsync,
                      sidebar: sidebar,
                      onZoomTo: onZoomTo,
                    ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Map Objects',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            tooltip: expanded ? 'Collapse panel' : 'Expand panel',
            icon: Icon(
              expanded
                  ? (isWide ? Icons.chevron_right : Icons.expand_more)
                  : (isWide ? Icons.chevron_left : Icons.expand_less),
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

class _MarkersPanel extends ConsumerWidget {
  const _MarkersPanel({
    required this.markersAsync,
    required this.sidebar,
    required this.onZoomTo,
  });

  final AsyncValue<List<MapMarker>> markersAsync;
  final SidebarState sidebar;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return markersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => MapObjectsErrorState(
        title: 'Markers unavailable',
        message: mapObjectsLoadErrorMessage(error),
        onRetry: () => ref.invalidate(markersProvider),
      ),
      data: (markers) {
        final visibleMarkers = markers.where((marker) {
          if (sidebar.searchQuery.isEmpty) return true;
          return marker.name
              .toLowerCase()
              .contains(sidebar.searchQuery.toLowerCase());
        }).toList()
          ..sort((a, b) => _compareMarkers(a, b, sidebar.markerSort));

        if (sidebar.viewMode == SidebarViewMode.tree) {
          return _TreePlaceholder(
            message: 'Tree view for markers will organize categories here.',
          );
        }

        if (visibleMarkers.isEmpty) {
          if (sidebar.searchQuery.isNotEmpty) {
            return const MapObjectsEmptyState(
              icon: Icons.search_off,
              title: 'No matching markers',
              message: 'Try a different search term.',
            );
          }

          return const MapObjectsEmptyState(
            icon: Icons.place_outlined,
            title: 'No markers yet',
            message: 'Long-press the map to add your first marker.',
          );
        }

        return ListView.separated(
          itemCount: visibleMarkers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final marker = visibleMarkers[index];
            return _MarkerListTile(
              key: ValueKey(marker.id),
              marker: marker,
              onZoomTo: onZoomTo,
            );
          },
        );
      },
    );
  }
}

class _ZonesPanel extends ConsumerWidget {
  const _ZonesPanel({
    required this.zonesAsync,
    required this.sidebar,
    required this.onZoomTo,
  });

  final AsyncValue<List<MapZone>> zonesAsync;
  final SidebarState sidebar;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return zonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => MapObjectsErrorState(
        title: 'Zones unavailable',
        message: mapObjectsLoadErrorMessage(error),
        onRetry: () => ref.read(zonesProvider.notifier).reload(),
      ),
      data: (zones) {
        final visibleZones = zones.where((zone) {
          if (sidebar.searchQuery.isEmpty) return true;
          return zone.name
              .toLowerCase()
              .contains(sidebar.searchQuery.toLowerCase());
        }).toList()
          ..sort((a, b) => _compareZones(a, b, sidebar.zoneSort));

        if (sidebar.viewMode == SidebarViewMode.tree) {
          return _TreePlaceholder(
            message: 'Tree view for zones will organize categories here.',
          );
        }

        if (visibleZones.isEmpty) {
          if (sidebar.searchQuery.isNotEmpty) {
            return const MapObjectsEmptyState(
              icon: Icons.search_off,
              title: 'No matching zones',
              message: 'Try a different search term.',
            );
          }

          return const MapObjectsEmptyState(
            icon: Icons.layers_outlined,
            title: 'No zones yet',
            message: 'Long-press the map and choose Line to draw one.',
          );
        }

        return ListView.separated(
          itemCount: visibleZones.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final zone = visibleZones[index];
            return _ZoneListTile(
              zone: zone,
              onZoomTo: onZoomTo,
            );
          },
        );
      },
    );
  }
}

class _MarkerListTile extends ConsumerWidget {
  const _MarkerListTile({
    super.key,
    required this.marker,
    required this.onZoomTo,
  });

  final MapMarker marker;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notesPreview = marker.notes?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => onZoomTo(LatLng(marker.latitude, marker.longitude)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MapMarkerIcon(
                  color: parseMarkerColor(marker.color),
                  iconName: marker.icon,
                  width: 28,
                  height: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${marker.latitude.toStringAsFixed(4)}, '
                        '${marker.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (notesPreview != null && notesPreview.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notesPreview.split('\n').first,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _MapObjectActionBar(
          actions: [
            _MapObjectIconAction(
              tooltip: marker.visible ? 'Hide marker' : 'Show marker',
              icon: marker.visible ? Icons.visibility : Icons.visibility_off,
              toggled: marker.visible,
              isToggle: true,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapMarker.updateMarker(
                  marker.copyWith(visible: !marker.visible),
                );
                ref.invalidate(markersProvider);
              },
            ),
            _MapObjectIconAction(
              tooltip: 'Edit marker',
              icon: Icons.edit_outlined,
              onPressed: () => updateMarkerFromForm(
                context: context,
                ref: ref,
                marker: marker,
              ),
            ),
            _MapObjectIconAction(
              tooltip: 'Delete marker',
              icon: Icons.delete_outline,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapMarker.deleteMarker(marker.id);
                ref.invalidate(markersProvider);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ZoneListTile extends ConsumerWidget {
  const _ZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLine = zone.type == lineZoneType;
    if (isLine) {
      return _LineZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      );
    }
    return _GenericZoneListTile(
      key: ValueKey(zone.id),
      zone: zone,
      onZoomTo: onZoomTo,
    );
  }
}

class _LineZoneListTile extends ConsumerWidget {
  const _LineZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final zoneId = zone.id;
    final geometry = LineGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selectedLineId = ref.watch(selectedLineProvider);
    final isSelected = selectedLineId == zone.id;
    final notesPreview = geometry?.notes?.trim();

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final distance = formatLineDistance(
      lineLengthMeters(geometry.start!, geometry.end!),
      measurementUnits,
    );

    return ColoredBox(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              final notifier = ref.read(selectedLineProvider.notifier);
              if (isSelected) {
                notifier.clear();
              } else {
                notifier.select(zone.id);
              }
              final center = lineZoneCenter(zone);
              if (center != null) {
                onZoomTo(center);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(zone.color),
                    radius: 18,
                    child: const Icon(
                      Icons.timeline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          distance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notesPreview != null && notesPreview.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const SizedBox(height: 6),
                          Text(
                            notesPreview.split('\n').first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MapObjectActionBar(
            actions: [
              _MapObjectIconAction(
                tooltip: geometry.showNameLabel
                    ? 'Hide name on map'
                    : 'Show name on map',
                icon: geometry.showNameLabel ? Icons.label : Icons.label_off,
                toggled: geometry.showNameLabel,
                isToggle: true,
                onPressed: () => toggleLineNameLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip: geometry.showDistanceLabel
                    ? 'Hide distance on map'
                    : 'Show distance on map',
                icon: geometry.showDistanceLabel
                    ? Icons.straighten
                    : Icons.straighten_outlined,
                toggled: geometry.showDistanceLabel,
                isToggle: true,
                onPressed: () =>
                    toggleLineDistanceLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip: zone.visible ? 'Hide line' : 'Show line',
                icon: zone.visible ? Icons.visibility : Icons.visibility_off,
                toggled: zone.visible,
                isToggle: true,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.updateZone(
                    zone.copyWith(visible: !zone.visible),
                  );
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
              _MapObjectIconAction(
                tooltip: 'Edit line',
                icon: Icons.edit_outlined,
                onPressed: () => updateLineFromForm(
                  context: context,
                  ref: ref,
                  zone: zone,
                ),
              ),
              _MapObjectIconAction(
                tooltip: 'Delete line',
                icon: Icons.delete_outline,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.deleteZone(zoneId);
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenericZoneListTile extends ConsumerWidget {
  const _GenericZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            ref.read(selectedLineProvider.notifier).clear();
            final center = lineZoneCenter(zone);
            if (center != null) {
              onZoomTo(center);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _parseColor(zone.color),
                  radius: 18,
                  child: const Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        zone.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _MapObjectActionBar(
          actions: [
            _MapObjectIconAction(
              tooltip: zone.visible ? 'Hide zone' : 'Show zone',
              icon: zone.visible ? Icons.visibility : Icons.visibility_off,
              toggled: zone.visible,
              isToggle: true,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapZone.updateZone(
                  zone.copyWith(visible: !zone.visible),
                );
                ref.read(zonesProvider.notifier).reload();
              },
            ),
            _MapObjectIconAction(
              tooltip: 'Delete zone',
              icon: Icons.delete_outline,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapZone.deleteZone(zone.id);
                ref.read(zonesProvider.notifier).reload();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _MapObjectActionBar extends StatelessWidget {
  const _MapObjectActionBar({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          children: actions,
        ),
      ),
    );
  }
}

class _MapObjectIconAction extends StatelessWidget {
  const _MapObjectIconAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.toggled = false,
    this.isToggle = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool toggled;
  final bool isToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      style: isToggle
          ? (toggled
              ? IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                )
              : IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.55),
                ))
          : IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _TreePlaceholder extends StatelessWidget {
  const _TreePlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

int _compareMarkers(MapMarker a, MapMarker b, MarkerSortField sort) {
  return switch (sort) {
    MarkerSortField.name => a.name.compareTo(b.name),
    MarkerSortField.hue => a.color.compareTo(b.color),
    MarkerSortField.icon => a.icon.compareTo(b.icon),
  };
}

int _compareZones(MapZone a, MapZone b, ZoneSortField sort) {
  final primary = switch (sort) {
    ZoneSortField.name => a.name.compareTo(b.name),
    ZoneSortField.hue => a.color.compareTo(b.color),
    ZoneSortField.type => a.type.compareTo(b.type),
  };
  if (primary != 0) {
    return primary;
  }
  return a.id.uuid.compareTo(b.id.uuid);
}

Color _parseColor(String value) => parseMarkerColor(value);
