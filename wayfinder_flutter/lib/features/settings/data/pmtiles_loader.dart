import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

import '../../../core/logging/app_logger.dart';
import '../../map/data/protomaps_offline_assets.dart';
import '../models/pmtiles_map_layer.dart';
import '../models/pmtiles_source.dart';

Future<PmTilesArchive> openPmtilesArchive(PmtilesSource source) async {
  final log = AppLogger.logPmtiles;
  log.info('🗺️ Opening PMTiles archive', data: source.runtimeType);

  try {
    final archive = await switch (source) {
      PmtilesSourcePath(:final path) => () async {
          log.debug('🗺️ Opening from path', data: path);
          return PmTilesArchive.from(path);
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

Future<PmTilesTileProvider> openPmtilesTileProvider(PmtilesSource source) async {
  final config = await buildPmtilesMapLayer(source);
  if (config is! PmtilesRasterMapLayerConfig) {
    throw UnsupportedError(
      'Raster tile provider requested but archive contains ${config.tileType} tiles.',
    );
  }
  return config.tileProvider;
}

Future<PmtilesMapLayerConfig> buildPmtilesMapLayer(PmtilesSource source) async {
  final log = AppLogger.logPmtiles;
  final archive = await openPmtilesArchive(source);

  switch (archive.tileType) {
    case TileType.mvt:
      log.info('🗺️ Using bundled offline Protomaps vector map layer');
      final offlineStyle = await ProtomapsOfflineAssets.loadLightV4();
      return PmtilesVectorMapLayerConfig(
        minZoom: archive.minZoom,
        maxZoom: archive.maxZoom,
        tileType: archive.tileType,
        tileProvider: PmTilesVectorTileProvider.fromArchive(archive),
        theme: offlineStyle.theme,
        sprites: offlineStyle.sprites,
      );
    case TileType.png:
    case TileType.jpeg:
    case TileType.webp:
    case TileType.avif:
      log.info('🗺️ Using raster tile layer', data: archive.tileType.name);
      return PmtilesRasterMapLayerConfig(
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
