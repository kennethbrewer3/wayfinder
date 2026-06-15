import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../markers/providers/markers_provider.dart';
import '../../settings/models/pmtiles_map_layer.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../models/map_viewport.dart';

class MapView extends ConsumerWidget {
  const MapView({
    super.key,
    required this.viewport,
    required this.onViewportChanged,
  });

  final MapViewport viewport;
  final ValueChanged<MapViewport> onViewportChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markersAsync = ref.watch(markersProvider);
    final mapLayerAsync = ref.watch(activePmtilesMapLayerProvider);

    return mapLayerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        AppLogger.logMap.error(
          '🗺️ Map layer failed to load',
          error: error,
          stackTrace: stackTrace,
        );
        return _PlaceholderLayer(
          errorMessage: error.toString(),
          onOpenSettings: () {
            AppLogger.logNav.info('🧭 Navigating to settings from map error placeholder');
            context.push('/settings');
          },
        );
      },
      data: (mapLayer) {
        if (mapLayer == null) {
          AppLogger.logMap.warn('🗺️ No PMTiles map layer — showing placeholder');
        }
        return _MapCanvas(
          viewport: viewport,
          onViewportChanged: onViewportChanged,
          mapLayer: mapLayer,
          markersAsync: markersAsync,
          onCreateMarker: (point) => _createMarker(context, ref, point),
          onOpenSettings: () {
            AppLogger.logNav.info('🧭 Navigating to settings from map placeholder');
            context.push('/settings');
          },
        );
      },
    );
  }

  Future<void> _createMarker(
    BuildContext context,
    WidgetRef ref,
    LatLng point,
  ) async {
    final nameController = TextEditingController(text: 'New marker');
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create marker'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created != true || !context.mounted) return;

    AppLogger.logMarkers.info(
      '📍 Creating marker',
      data: 'lat=${point.latitude} lng=${point.longitude}',
    );
    final client = ref.read(serverClientProvider);
    final now = DateTime.now().toUtc();
    await client.mapMarker.createMarker(
      MapMarker(
        name: nameController.text.trim().isEmpty
            ? 'New marker'
            : nameController.text.trim(),
        latitude: point.latitude,
        longitude: point.longitude,
        color: '#1B4965',
        icon: 'place',
        visible: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    ref.invalidate(markersProvider);
    AppLogger.logMarkers.success('📍 Marker created');
  }
}

class _MapCanvas extends StatefulWidget {
  const _MapCanvas({
    required this.viewport,
    required this.onViewportChanged,
    required this.mapLayer,
    required this.markersAsync,
    required this.onCreateMarker,
    required this.onOpenSettings,
  });

  final MapViewport viewport;
  final ValueChanged<MapViewport> onViewportChanged;
  final PmtilesMapLayerConfig? mapLayer;
  final AsyncValue<List<MapMarker>> markersAsync;
  final Future<void> Function(LatLng point) onCreateMarker;
  final VoidCallback onOpenSettings;

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(_MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewport.center != widget.viewport.center ||
        oldWidget.viewport.zoom != widget.viewport.zoom) {
      _mapController.move(widget.viewport.center, widget.viewport.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapLayer = widget.mapLayer;
    final minZoom = mapLayer?.minZoom.toDouble() ?? 2;
    final maxZoom = mapLayer?.maxZoom.toDouble() ?? 18;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.viewport.center,
        initialZoom: widget.viewport.zoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onPositionChanged: (position, hasGesture) {
          if (!hasGesture) return;
          widget.onViewportChanged(
            MapViewport(
              center: position.center,
              zoom: position.zoom,
            ),
          );
        },
        onSecondaryTap: (tapPosition, point) {
          widget.onCreateMarker(point);
        },
      ),
      children: [
        ...switch (mapLayer) {
          PmtilesVectorMapLayerConfig(:final tileProvider, :final theme, :final sprites) => [
              VectorTileLayer(
                theme: theme,
                sprites: sprites,
                tileProviders: TileProviders({
                  'protomaps': tileProvider,
                }),
              ),
            ],
          PmtilesRasterMapLayerConfig(:final tileProvider) => [
              TileLayer(
                tileProvider: tileProvider,
              ),
            ],
          null => [
              _PlaceholderLayer(
                onOpenSettings: widget.onOpenSettings,
              ),
            ],
        },
        if (widget.markersAsync case AsyncData(:final value))
          MarkerLayer(
            markers: value
                .where((marker) => marker.visible)
                .map(
                  (marker) => Marker(
                    point: LatLng(marker.latitude, marker.longitude),
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.place,
                      color: _parseColor(marker.color),
                      size: 36,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _PlaceholderLayer extends StatelessWidget {
  const _PlaceholderLayer({
    this.errorMessage,
    required this.onOpenSettings,
  });

  final String? errorMessage;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8EEF2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No offline map installed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ??
                    'Upload a .pmtiles file in Settings to display map tiles.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
