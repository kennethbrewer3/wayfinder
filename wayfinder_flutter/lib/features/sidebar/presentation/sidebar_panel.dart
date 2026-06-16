import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../../circles/models/circle_geometry.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/presentation/create_circle_dialog.dart';
import '../../circles/utils/circle_distance.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../rectangles/models/rectangle_size_display.dart';
import '../../rectangles/presentation/create_rectangle_dialog.dart';
import '../../rectangles/utils/rectangle_dimensions.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../lines/utils/line_distance.dart';
import '../../map/providers/map_providers.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/presentation/map_object_notes_preview.dart';
import '../../markers/presentation/map_objects_status.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../utils/map_object_sort.dart';

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
        final filteredMarkers = markers.where((marker) {
          if (sidebar.searchQuery.isEmpty) return true;
          return marker.name
              .toLowerCase()
              .contains(sidebar.searchQuery.toLowerCase());
        }).toList();

        if (filteredMarkers.isEmpty) {
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MarkerSortSelector(
              value: sidebar.markerSort,
              onChanged: (sort) {
                ref.read(sidebarProvider.notifier).setMarkerSort(sort);
              },
            ),
            Expanded(
              child: sidebar.viewMode == SidebarViewMode.tree
                  ? _MarkerTreeView(
                      groups: groupMarkers(filteredMarkers, sidebar.markerSort),
                      onZoomTo: onZoomTo,
                    )
                  : _MarkerListView(
                      markers: sortMarkers(filteredMarkers, sidebar.markerSort),
                      onZoomTo: onZoomTo,
                    ),
            ),
          ],
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
        final filteredZones = zones.where((zone) {
          if (sidebar.searchQuery.isEmpty) return true;
          return zone.name
              .toLowerCase()
              .contains(sidebar.searchQuery.toLowerCase());
        }).toList();

        if (filteredZones.isEmpty) {
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ZoneSortSelector(
              value: sidebar.zoneSort,
              onChanged: (sort) {
                ref.read(sidebarProvider.notifier).setZoneSort(sort);
              },
            ),
            Expanded(
              child: sidebar.viewMode == SidebarViewMode.tree
                  ? _ZoneTreeView(
                      groups: groupZones(filteredZones, sidebar.zoneSort),
                      onZoomTo: onZoomTo,
                    )
                  : _ZoneListView(
                      zones: sortZones(filteredZones, sidebar.zoneSort),
                      onZoomTo: onZoomTo,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MarkerSortSelector extends StatelessWidget {
  const _MarkerSortSelector({
    required this.value,
    required this.onChanged,
  });

  final MarkerSortField value;
  final ValueChanged<MarkerSortField> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SortFieldSelector<MarkerSortField>(
      label: 'Sort markers',
      value: value,
      items: MarkerSortField.values,
      itemLabel: (field) => field.label,
      onChanged: onChanged,
    );
  }
}

class _ZoneSortSelector extends StatelessWidget {
  const _ZoneSortSelector({
    required this.value,
    required this.onChanged,
  });

  final ZoneSortField value;
  final ValueChanged<ZoneSortField> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SortFieldSelector<ZoneSortField>(
      label: 'Sort zones',
      value: value,
      items: ZoneSortField.values,
      itemLabel: (field) => field.label,
      onChanged: onChanged,
    );
  }
}

class _SortFieldSelector<T> extends StatelessWidget {
  const _SortFieldSelector({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            style: theme.textTheme.bodyMedium,
            items: [
              for (final item in items)
                DropdownMenuItem(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
            ],
            onChanged: (selection) {
              if (selection != null) {
                onChanged(selection);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _MarkerListView extends StatelessWidget {
  const _MarkerListView({
    required this.markers,
    required this.onZoomTo,
  });

  final List<MapMarker> markers;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: markers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final marker = markers[index];
        return _MarkerListTile(
          key: ValueKey(marker.id),
          marker: marker,
          onZoomTo: onZoomTo,
        );
      },
    );
  }
}

class _ZoneListView extends StatelessWidget {
  const _ZoneListView({
    required this.zones,
    required this.onZoomTo,
  });

  final List<MapZone> zones;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: zones.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final zone = zones[index];
        return _ZoneListTile(
          key: ValueKey(zone.id),
          zone: zone,
          onZoomTo: onZoomTo,
        );
      },
    );
  }
}

class _MarkerTreeView extends StatelessWidget {
  const _MarkerTreeView({
    required this.groups,
    required this.onZoomTo,
  });

  final List<MapObjectTreeGroup<MapMarker>> groups;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context) {
    return _MapObjectTreeScaffold(
      groups: groups,
      itemBuilder: (marker) => _MarkerListTile(
        key: ValueKey(marker.id),
        marker: marker,
        onZoomTo: onZoomTo,
      ),
    );
  }
}

class _ZoneTreeView extends StatelessWidget {
  const _ZoneTreeView({
    required this.groups,
    required this.onZoomTo,
  });

  final List<MapObjectTreeGroup<MapZone>> groups;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context) {
    return _MapObjectTreeScaffold(
      groups: groups,
      itemBuilder: (zone) => _ZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      ),
    );
  }
}

class _MapObjectTreeScaffold<T> extends StatelessWidget {
  const _MapObjectTreeScaffold({
    required this.groups,
    required this.itemBuilder,
  });

  final List<MapObjectTreeGroup<T>> groups;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey('tree-group-${group.key}'),
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: EdgeInsets.zero,
            leading: group.leading,
            title: Text(
              group.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${group.items.length} item${group.items.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            children: [
              for (final (itemIndex, item) in group.items.indexed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (itemIndex > 0) const Divider(height: 1),
                    itemBuilder(item),
                  ],
                ),
            ],
          ),
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
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.marker &&
        selected?.id == marker.id;

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            final notifier = ref.read(selectedMapObjectProvider.notifier);
            if (isSelected) {
              notifier.clear();
            } else {
              notifier.selectMarker(marker.id);
            }
            onZoomTo(LatLng(marker.latitude, marker.longitude));
          },
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
                        MapObjectNotesPreview(markdown: notesPreview),
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
    ),
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
    final isCircle = zone.type == circleZoneType;
    if (isCircle) {
      return _CircleZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      );
    }
    final isRectangle = zone.type == rectangleZoneType;
    if (isRectangle) {
      return _RectangleZoneListTile(
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
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;
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
              final notifier = ref.read(selectedMapObjectProvider.notifier);
              if (isSelected) {
                notifier.clear();
              } else {
                notifier.selectZone(zone.id);
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
                          MapObjectNotesPreview(
                            markdown: notesPreview,
                            color: theme.colorScheme.onSurfaceVariant,
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

class _CircleZoneListTile extends ConsumerWidget {
  const _CircleZoneListTile({
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
    final geometry = CircleGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;
    final notesPreview = geometry?.notes?.trim();

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final radiusLabel = formatCircleSize(
      geometry.radiusMeters,
      measurementUnits,
      CircleSizeDisplay.radius,
    );
    final mapSizeLabel = formatCircleSizeForMapLabel(
      geometry.radiusMeters,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            final notifier = ref.read(selectedMapObjectProvider.notifier);
            if (isSelected) {
              notifier.clear();
            } else {
              notifier.selectZone(zone.id);
            }
            onZoomTo(geometry.center);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _parseColor(zone.borderColor),
                  radius: 18,
                  child: const Icon(
                    Icons.radio_button_unchecked,
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
                        mapSizeLabel == null
                            ? 'R $radiusLabel · no map label'
                            : '${geometry.sizeDisplay.shortLabel} $mapSizeLabel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (notesPreview != null && notesPreview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        MapObjectNotesPreview(
                          markdown: notesPreview,
                          color: theme.colorScheme.onSurfaceVariant,
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
              onPressed: () => toggleCircleNameLabel(ref: ref, zoneId: zoneId),
            ),
            _MapObjectIconAction(
              tooltip: circleSizeDisplayToggleTooltip(geometry.sizeDisplay),
              icon: geometry.sizeDisplay == CircleSizeDisplay.none
                  ? Icons.straighten_outlined
                  : Icons.straighten,
              toggled: geometry.sizeDisplay != CircleSizeDisplay.none,
              isToggle: true,
              onPressed: () => toggleCircleSizeLabel(ref: ref, zoneId: zoneId),
            ),
            _MapObjectIconAction(
              tooltip: zone.visible ? 'Hide circle' : 'Show circle',
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
              tooltip: 'Edit circle',
              icon: Icons.edit_outlined,
              onPressed: () => updateCircleFromForm(
                context: context,
                ref: ref,
                zone: zone,
              ),
            ),
            _MapObjectIconAction(
              tooltip: 'Delete circle',
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

class _RectangleZoneListTile extends ConsumerWidget {
  const _RectangleZoneListTile({
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
    final geometry = RectangleGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;
    final notesPreview = geometry?.notes?.trim();

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final dimensionsLabel = formatRectangleDimensions(
      geometry.bounds,
      measurementUnits,
    );
    final mapSizeLabel = formatRectangleSizeForMapLabel(
      geometry.bounds,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              final notifier = ref.read(selectedMapObjectProvider.notifier);
              if (isSelected) {
                notifier.clear();
              } else {
                notifier.selectZone(zone.id);
              }
              onZoomTo(geometry.bounds.center);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(zone.borderColor),
                    radius: 18,
                    child: const Icon(
                      Icons.crop_square,
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
                          mapSizeLabel == null
                              ? '$dimensionsLabel · no map label'
                              : '${geometry.sizeDisplay.shortLabel} $mapSizeLabel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notesPreview != null && notesPreview.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          MapObjectNotesPreview(
                            markdown: notesPreview,
                            color: theme.colorScheme.onSurfaceVariant,
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
                onPressed: () =>
                    toggleRectangleNameLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip:
                    rectangleSizeDisplayToggleTooltip(geometry.sizeDisplay),
                icon: geometry.sizeDisplay == RectangleSizeDisplay.none
                    ? Icons.straighten_outlined
                    : Icons.straighten,
                toggled: geometry.sizeDisplay != RectangleSizeDisplay.none,
                isToggle: true,
                onPressed: () =>
                    toggleRectangleSizeLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip: zone.visible ? 'Hide rectangle' : 'Show rectangle',
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
                tooltip: 'Edit rectangle',
                icon: Icons.edit_outlined,
                onPressed: () => updateRectangleFromForm(
                  context: context,
                  ref: ref,
                  zone: zone,
                ),
              ),
              _MapObjectIconAction(
                tooltip: 'Delete rectangle',
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
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            final notifier = ref.read(selectedMapObjectProvider.notifier);
            if (isSelected) {
              notifier.clear();
            } else {
              notifier.selectZone(zone.id);
            }
            final center = rectangleZoneCenter(zone) ??
                circleZoneCenter(zone) ??
                lineZoneCenter(zone);
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
    ),
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

Color _parseColor(String value) => parseMarkerColor(value);

Color _selectionHighlightColor(ThemeData theme, bool isSelected) {
  return isSelected
      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
      : Colors.transparent;
}
