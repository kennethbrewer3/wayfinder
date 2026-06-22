import 'dart:math' as math;

import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

import '../../../core/logging/app_logger.dart';
import '../../map/data/protomaps_offline_assets.dart';
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
