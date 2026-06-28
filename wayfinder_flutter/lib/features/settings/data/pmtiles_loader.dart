import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

import '../../../core/logging/app_logger.dart';
import '../../map/data/protomaps_offline_assets.dart';
import '../../map/utils/pmtiles_viewport.dart';
import '../models/pmtiles_archive_entry.dart';
import '../models/pmtiles_geo_bounds.dart';
import '../models/pmtiles_map_layer.dart';
import '../models/pmtiles_source.dart';

const _metadataBatchSize = 8;

Future<PmTilesArchive> openPmtilesArchive(PmtilesSource source) async {
  final log = AppLogger.logPmtiles;
  log.info('🗺️ Opening PMTiles archive', data: source.runtimeType);

  try {
    final archive = await switch (source) {
      PmtilesSourcePath(:final path) => () async {
          log.debug('🗺️ Opening from path', data: path);
          return PmTilesArchive.from(path);
        }(),
      PmtilesSourceUrl(:final url) => () async {
          log.debug('🗺️ Opening from URL', data: url);
          return PmTilesArchive.from(url);
        }(),
      PmtilesSourceBytes(:final bytes) => () async {
          log.debug(
            '🗺️ Opening from memory',
            data: 'size=${formatBytes(bytes.length)}',
          );
          return PmTilesArchive.fromBytes(bytes);
        }(),
    };

    log.success(
      '🗺️ PMTiles archive opened',
      data:
          'version=${archive.version} tileType=${archive.tileType} tileCompression=${archive.tileCompression}',
    );
    return archive;
  } catch (error, stackTrace) {
    log.error(
      '🗺️ Failed to open PMTiles archive',
      error: error,
      stackTrace: stackTrace,
      data: source,
    );
    rethrow;
  }
}

Future<PmTilesTileProvider> openPmtilesTileProvider(
  PmtilesSource source, {
  required String catalogId,
}) async {
  final config = await buildPmtilesMapLayer(source, catalogId: catalogId);
  if (config is! PmtilesRasterMapLayerConfig) {
    throw UnsupportedError(
      'Raster tile provider requested but archive contains ${config.tileType} tiles.',
    );
  }
  return config.tileProvider;
}

Future<PmtilesArchiveEntry> readPmtilesArchiveEntry({
  required String id,
  required String name,
  required PmtilesSource source,
}) async {
  final archive = await openPmtilesArchive(source);
  try {
    return PmtilesArchiveEntry(
      id: id,
      name: name,
      source: source,
      bounds: PmtilesGeoBounds.fromPositions(
        archive.minPosition,
        archive.maxPosition,
      ),
      boundsKnown: true,
      minZoom: archive.minZoom,
      maxZoom: archive.maxZoom,
    );
  } finally {
    await archive.close();
  }
}

Future<List<PmtilesArchiveEntry>> readPmtilesArchiveEntries(
  List<PmtilesArchiveEntry> descriptors,
) async {
  final entries = <PmtilesArchiveEntry>[];
  for (var index = 0; index < descriptors.length; index += _metadataBatchSize) {
    final end = math.min(index + _metadataBatchSize, descriptors.length);
    final batch = descriptors.sublist(index, end);
    final batchEntries = await Future.wait(
      batch.map(
        (descriptor) => readPmtilesArchiveEntry(
          id: descriptor.id,
          name: descriptor.name,
          source: descriptor.source,
        ),
      ),
    );
    entries.addAll(batchEntries);
  }
  return entries;
}

Future<bool> archiveHasMapDataAtCenter({
  required PmtilesArchiveEntry entry,
  required LatLng center,
  required double viewportZoom,
}) async {
  final requestedZoom = tileZoomForViewport(viewportZoom);
  final maxZoom = math.min(requestedZoom, entry.maxZoom);
  final minZoom = entry.minZoom;

  final archive = await openPmtilesArchive(entry.source);
  try {
    for (var zoom = maxZoom; zoom >= minZoom; zoom--) {
      final coords = latLngToTile(center, zoom);
      final tileId = ZXY(coords.z, coords.x, coords.y).toTileId();
      final tile = await archive.tile(tileId);
      try {
        final bytes = tile.bytes();
        if (bytes.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  } finally {
    await archive.close();
  }
}

/// Chooses the archive that actually contains map tiles at the viewport center.
///
/// Header bounds for neighboring states overlap near borders; probing avoids
/// picking a smaller state archive whose rectangle contains the point but has
/// no tile data there.
Future<PmtilesArchiveEntry?> resolveActiveArchiveForViewport({
  required List<PmtilesArchiveEntry> entries,
  required LatLngBounds viewportBounds,
  required LatLng viewportCenter,
  required double viewportZoom,
}) async {
  if (entries.isEmpty) {
    return null;
  }

  final paddedViewport = expandLatLngBounds(viewportBounds);

  final containingCenter = rankArchivesContainingCenter(
    entries: entries,
    paddedViewport: paddedViewport,
    viewportCenter: viewportCenter,
    viewportZoom: viewportZoom,
  );

  if (containingCenter.isEmpty) {
    final fallback = selectArchivesForViewport(
      entries: entries,
      viewportBounds: viewportBounds,
      viewportCenter: viewportCenter,
      viewportZoom: viewportZoom,
    );
    return fallback.isEmpty ? null : fallback.first;
  }

  if (containingCenter.length == 1) {
    return containingCenter.first;
  }

  for (final entry in containingCenter) {
    if (await archiveHasMapDataAtCenter(
      entry: entry,
      center: viewportCenter,
      viewportZoom: viewportZoom,
    )) {
      AppLogger.logPmtiles.info(
        '🗺️ Selected archive by center tile probe',
        data: 'id=${entry.id} name="${entry.name}"',
      );
      return entry;
    }
  }

  AppLogger.logPmtiles.warn(
    '🗺️ No archive had center tile data; using best bounds match',
    data:
        'center=${viewportCenter.latitude},${viewportCenter.longitude} candidates=${containingCenter.map((e) => e.name).join(', ')}',
  );
  return containingCenter.first;
}

Future<PmtilesMapLayerConfig> buildPmtilesMapLayer(
  PmtilesSource source, {
  required String catalogId,
}) async {
  final log = AppLogger.logPmtiles;
  final archive = await openPmtilesArchive(source);

  switch (archive.tileType) {
    case TileType.mvt:
      log.info('🗺️ Using bundled offline Protomaps vector map layer');
      final offlineStyle = await ProtomapsOfflineAssets.loadLightV4();
      return PmtilesVectorMapLayerConfig(
        catalogId: catalogId,
        minZoom: archive.minZoom,
        maxZoom: archive.maxZoom,
        tileType: archive.tileType,
        tileProvider: PmTilesVectorTileProvider.fromArchive(archive),
        theme: offlineStyle.theme,
        backgroundTheme: offlineStyle.backgroundTheme,
        sprites: offlineStyle.sprites,
      );
    case TileType.png:
    case TileType.jpeg:
    case TileType.webp:
    case TileType.avif:
      log.info('🗺️ Using raster tile layer', data: archive.tileType.name);
      return PmtilesRasterMapLayerConfig(
        catalogId: catalogId,
        minZoom: archive.minZoom,
        maxZoom: archive.maxZoom,
        tileType: archive.tileType,
        tileProvider: PmTilesTileProvider.fromArchive(archive),
      );
    case TileType.unknown:
      log.error('🗺️ Unsupported PMTiles tile type', data: archive.tileType.name);
      throw UnsupportedError(
        'Unsupported PMTiles tile type. Use Protomaps vector (.pmtiles with MVT tiles) '
        'or raster tiles (PNG/JPEG/WebP).',
      );
  }
}
