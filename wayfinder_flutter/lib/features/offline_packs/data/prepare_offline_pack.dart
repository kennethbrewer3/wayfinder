import 'dart:typed_data';

import 'package:pmtiles/pmtiles.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../elevation/utils/elevation_dem_detect.dart';
import '../../layers/utils/map_layer_utils.dart';
import '../../map_atlas/models/atlas_bounds.dart';
import '../../map_atlas/utils/atlas_web_mercator.dart';
import '../../settings/data/pmtiles_loader.dart';
import '../../settings/data/pmtiles_repository.dart';
import '../../settings/models/pmtiles_source.dart';
import '../models/offline_pack.dart';
import '../models/offline_snapshot.dart';
import 'offline_pack_store.dart';
import 'offline_tile_cache.dart';

typedef OfflinePrepareProgress =
    void Function(String message, double? fraction);

bool _objectOnSelectedLayers(
  UuidValue? layerId,
  Set<String> selectedLayerKeys,
) {
  final effective = (layerId ?? defaultMapLayerId).uuid;
  return selectedLayerKeys.contains(effective);
}

/// Rough tile count for the prepare dialog estimate.
int estimateOfflineTileCount({
  required OfflinePackRegion region,
  int archiveCount = 1,
}) {
  if (archiveCount <= 0) {
    return 0;
  }
  final bounds = AtlasBounds(
    south: region.south,
    west: region.west,
    north: region.north,
    east: region.east,
  );
  var total = 0;
  for (var z = region.minZoom; z <= region.maxZoom; z++) {
    final range = tileRangeForBounds(bounds: bounds, zoom: z);
    total += (range.maxX - range.minX + 1) * (range.maxY - range.minY + 1);
  }
  return total * archiveCount;
}

/// Builds an offline pack: selected-layer objects + AOI basemap tiles.
Future<OfflinePackMeta> prepareOfflinePack({
  required Client client,
  required PmtilesRepository pmtilesRepository,
  required OfflinePackStore store,
  required OfflineTileCache tileCache,
  required String name,
  required List<UuidValue> layerIds,
  required OfflinePackRegion region,
  OfflinePrepareProgress? onProgress,
}) async {
  final log = AppLogger.logMap;
  final selectedKeys = {for (final id in layerIds) id.uuid};

  onProgress?.call('Loading map objects…', 0.05);
  final layers = await client.mapLayer.listLayers();
  final markers = await client.mapMarker.listMarkers();
  final zones = await client.mapZone.listZones();
  List<WatchLogEntry> watchLog = const [];
  try {
    watchLog = await client.watchLog.listEntries();
  } catch (_) {
    // Watch log optional if endpoint unavailable.
  }

  final packLayers = [
    for (final layer in layers)
      if (selectedKeys.contains(layer.id.uuid)) layer,
  ];
  final packMarkers = [
    for (final marker in markers)
      if (_objectOnSelectedLayers(marker.layerId, selectedKeys)) marker,
  ];
  final packZones = [
    for (final zone in zones)
      if (_objectOnSelectedLayers(zone.layerId, selectedKeys)) zone,
  ];
  final markerIds = {for (final m in packMarkers) m.id.uuid};
  final zoneIds = {for (final z in packZones) z.id.uuid};
  final packWatchLog = [
    for (final entry in watchLog)
      if ((entry.markerId != null &&
              markerIds.contains(entry.markerId!.uuid)) ||
          (entry.zoneId != null && zoneIds.contains(entry.zoneId!.uuid)) ||
          (entry.markerId == null && entry.zoneId == null))
        entry,
  ];

  final snapshot = OfflineSnapshot(
    layers: packLayers,
    markers: packMarkers,
    zones: packZones,
    watchLogEntries: packWatchLog,
    capturedAt: DateTime.now().toUtc(),
  );
  await store.saveSnapshot(snapshot);
  onProgress?.call('Caching basemap tiles…', 0.2);

  await tileCache.clear();
  final files = await pmtilesRepository.listFiles();
  final enabled = [
    for (final file in files)
      if (file.enabledOnMap && !looksLikeElevationDemArchive(file.name)) file,
  ];

  var tilesCached = 0;
  final basemaps = <OfflinePackBasemap>[];
  final bounds = AtlasBounds(
    south: region.south,
    west: region.west,
    north: region.north,
    east: region.east,
  );

  for (var fileIndex = 0; fileIndex < enabled.length; fileIndex++) {
    final file = enabled[fileIndex];
    final source = PmtilesSourceUrl(
      pmtilesRepository.fileUrl(file.id),
    );
    final archive = await openPmtilesArchive(source);
    try {
      final zMin = region.minZoom.clamp(archive.minZoom, archive.maxZoom);
      final zMax = region.maxZoom.clamp(archive.minZoom, archive.maxZoom);
      basemaps.add(
        OfflinePackBasemap(
          catalogId: file.id,
          name: file.name,
          tileType: archive.tileType.name,
          minZoom: zMin,
          maxZoom: zMax,
          south: region.south,
          west: region.west,
          north: region.north,
          east: region.east,
        ),
      );
      for (var z = zMin; z <= zMax; z++) {
        final range = tileRangeForBounds(bounds: bounds, zoom: z);
        final totalAtZoom =
            (range.maxX - range.minX + 1) * (range.maxY - range.minY + 1);
        var doneAtZoom = 0;
        for (var x = range.minX; x <= range.maxX; x++) {
          for (var y = range.minY; y <= range.maxY; y++) {
            final tileId = ZXY(z, x, y).toTileId();
            try {
              final tile = await archive.tile(tileId);
              final bytes = tile.bytes();
              if (bytes.isNotEmpty) {
                await tileCache.putTile(
                  catalogId: file.id,
                  z: z,
                  x: x,
                  y: y,
                  bytes: Uint8List.fromList(bytes),
                );
                tilesCached += 1;
              }
            } catch (_) {
              // Missing tiles in sparse archives are expected.
            }
            doneAtZoom += 1;
            if (doneAtZoom % 25 == 0 || doneAtZoom == totalAtZoom) {
              final fileFrac =
                  (fileIndex + doneAtZoom / totalAtZoom) /
                  enabled.length.clamp(1, 999);
              onProgress?.call(
                'Caching ${file.name} z$z…',
                0.2 + 0.75 * fileFrac,
              );
            }
          }
        }
      }
    } finally {
      await releasePmtilesArchive(source);
    }
  }

  final meta = OfflinePackMeta(
    name: name,
    layerIds: layerIds,
    region: region,
    preparedAt: DateTime.now().toUtc(),
    basemaps: basemaps,
    tileCount: tilesCached,
    markerCount: packMarkers.length,
    zoneCount: packZones.length,
  );
  await store.saveMeta(meta);
  log.success(
    'Offline pack prepared',
    data:
        'layers=${layerIds.length} markers=${packMarkers.length} '
        'zones=${packZones.length} tiles=$tilesCached',
  );
  onProgress?.call('Offline pack ready', 1);
  return meta;
}
