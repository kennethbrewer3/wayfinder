import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../lines/providers/zones_provider.dart';
import '../../map/providers/map_providers.dart';
import '../../markers/providers/markers_provider.dart';
import '../data/layers_repository.dart';
import '../utils/map_layer_utils.dart';

final layersProvider = FutureProvider<List<MapLayer>>((ref) async {
  AppLogger.logMap.debug('📡 Fetching map layers from server');
  try {
    final client = ref.read(serverClientProvider);
    final layers = await fetchMapLayers(client);
    AppLogger.logMap.success(
      '📡 Map layers loaded',
      data: 'count=${layers.length}',
    );
    return layers;
  } catch (error, stackTrace) {
    AppLogger.logMap.error(
      '📡 Failed to load map layers',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

Future<void> createMapLayer(WidgetRef ref, String name) async {
  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final existing = ref.read(layersProvider).valueOrNull ?? const <MapLayer>[];
  final nextSortOrder = existing.isEmpty
      ? 0
      : existing
              .map((layer) => layer.sortOrder)
              .reduce((a, b) => a > b ? a : b) +
          1;

  await client.mapLayer.createLayer(
    MapLayer(
      name: name,
      sortOrder: nextSortOrder,
      visible: true,
      createdAt: now,
      updatedAt: now,
    ),
  );
  ref.invalidate(layersProvider);
}

Future<void> updateMapLayer(WidgetRef ref, MapLayer layer) async {
  final client = ref.read(serverClientProvider);
  await client.mapLayer.updateLayer(
    layer.copyWith(updatedAt: DateTime.now().toUtc()),
  );
  ref.invalidate(layersProvider);
}

Future<void> deleteMapLayer(WidgetRef ref, MapLayer layer) async {
  final client = ref.read(serverClientProvider);
  await client.mapLayer.deleteLayer(layer.id);
  ref.invalidate(layersProvider);
  ref.invalidate(markersProvider);
  ref.invalidate(zonesProvider);
}

Future<void> reorderMapLayers(
  WidgetRef ref,
  List<MapLayer> layers,
) async {
  final client = ref.read(serverClientProvider);
  await client.mapLayer.reorderLayers(layers);
  ref.invalidate(layersProvider);
}

UuidValue? selectedLayerIdForCreate(WidgetRef ref) {
  final layers = ref.read(layersProvider).valueOrNull ?? const <MapLayer>[];
  final sidebar = ref.read(sidebarProvider);
  return resolveSelectedLayerId(
    selectedLayerId: sidebar.selectedLayerId,
    layers: layers,
  );
}
