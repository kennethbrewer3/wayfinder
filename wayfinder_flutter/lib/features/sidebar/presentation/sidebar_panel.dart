import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../../map/providers/map_providers.dart';
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

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Map Objects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
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
                ref.read(sidebarProvider.notifier).setActiveTab(selection.first);
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
                ref.read(sidebarProvider.notifier).setViewMode(selection.first);
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
      error: (error, _) => Center(child: Text('Failed to load markers: $error')),
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
          return const Center(child: Text('No markers yet.'));
        }

        return ListView.separated(
          itemCount: visibleMarkers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final marker = visibleMarkers[index];
            return _MarkerListTile(
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
      error: (error, _) => Center(child: Text('Failed to load zones: $error')),
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
          return const Center(child: Text('No zones yet.'));
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
    required this.marker,
    required this.onZoomTo,
  });

  final MapMarker marker;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _parseColor(marker.color),
        child: Icon(
          _iconData(marker.icon),
          color: Colors.white,
          size: 18,
        ),
      ),
      title: Text(marker.name),
      subtitle: Text(
        '${marker.latitude.toStringAsFixed(4)}, '
        '${marker.longitude.toStringAsFixed(4)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: marker.visible ? 'Hide marker' : 'Show marker',
            icon: Icon(
              marker.visible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () async {
              final client = ref.read(serverClientProvider);
              await client.mapMarker.updateMarker(
                marker.copyWith(visible: !marker.visible),
              );
              ref.invalidate(markersProvider);
            },
          ),
          IconButton(
            tooltip: 'Delete marker',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final client = ref.read(serverClientProvider);
              await client.mapMarker.deleteMarker(marker.id);
              ref.invalidate(markersProvider);
            },
          ),
        ],
      ),
      onTap: () => onZoomTo(LatLng(marker.latitude, marker.longitude)),
    );
  }
}

class _ZoneListTile extends ConsumerWidget {
  const _ZoneListTile({
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _parseColor(zone.color),
        child: const Icon(Icons.layers, color: Colors.white, size: 18),
      ),
      title: Text(zone.name),
      subtitle: Text(zone.type),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: zone.visible ? 'Hide zone' : 'Show zone',
            icon: Icon(zone.visible ? Icons.visibility : Icons.visibility_off),
            onPressed: () async {
              final client = ref.read(serverClientProvider);
              await client.mapZone.updateZone(
                zone.copyWith(visible: !zone.visible),
              );
              ref.invalidate(zonesProvider);
            },
          ),
          IconButton(
            tooltip: 'Delete zone',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final client = ref.read(serverClientProvider);
              await client.mapZone.deleteZone(zone.id);
              ref.invalidate(zonesProvider);
            },
          ),
        ],
      ),
      onTap: () {
        // Zone center lookup is implemented when geometry parsing is added.
      },
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
  return switch (sort) {
    ZoneSortField.name => a.name.compareTo(b.name),
    ZoneSortField.hue => a.color.compareTo(b.color),
    ZoneSortField.type => a.type.compareTo(b.type),
  };
}

Color _parseColor(String value) {
  final hex = value.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return Colors.blueGrey;
}

IconData _iconData(String iconName) {
  return switch (iconName) {
    'home' => Icons.home,
    'flag' => Icons.flag,
    'star' => Icons.star,
    _ => Icons.place,
  };
}
