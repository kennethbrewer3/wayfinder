import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:http/http.dart' as http;
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logging_http_client.dart';
import '../../map/data/protomaps_offline_assets.dart';
import '../models/pmtiles_archive_entry.dart';
import '../models/pmtiles_geo_bounds.dart';
import '../models/pmtiles_map_layer.dart';
import '../models/pmtiles_source.dart';
import 'pmtiles_archive_pool.dart';

const _metadataBatchSize = 8;
const _pmtilesOpenTimeout = Duration(seconds: 45);
const _pmtilesProbeTimeout = Duration(seconds: 12);

/// Fail fast before [PmTilesArchive.from] if the tile HTTP endpoint is
/// unreachable. PMTiles needs Range/206; a hanging TCP connect looks like a
/// stuck "Opening…" spinner on phones.
Future<void> probePmtilesHttpUrl(String url) async {
  final log = AppLogger.logPmtiles;
  log.info('TILES | probing URL', data: url);
  final client = LoggingHttpClient(logger: log);
  try {
    final request = http.Request('GET', Uri.parse(url));
    request.headers[HttpHeaders.rangeHeader] = 'bytes=0-126';
    final response = await client
        .send(request)
        .timeout(
          _pmtilesProbeTimeout,
          onTimeout: () {
            throw TimeoutException(
              'Timed out reaching map tiles at $url. '
              'From this phone, the Wayfinder web/PMTiles URL must be '
              'reachable and allow HTTP Range requests '
              '(check Settings → server web URL).',
            );
          },
        );
    // Abort the body immediately — a misconfigured server may ignore Range
    // and try to send the entire archive.
    await response.stream.listen((_) {}, cancelOnError: true).cancel();

    if (response.statusCode != 206 && response.statusCode != 200) {
      throw HttpException(
        'Map tile server returned HTTP ${response.statusCode} for $url '
        '(expected 206 Partial Content). Is the web server running?',
      );
    }
    if (response.statusCode == 200) {
      log.warn(
        'TILES | probe got HTTP 200 instead of 206; Range may be broken',
        data: url,
      );
    } else {
      log.success('TILES | probe OK (206)', data: url);
    }
  } finally {
    client.close();
  }
}

Future<PmTilesArchive> _openPmtilesArchiveRaw(PmtilesSource source) async {
  final log = AppLogger.logPmtiles;
  log.info('TILES | open archive', data: source.runtimeType);

  try {
    final archive = await switch (source) {
      PmtilesSourcePath(:final path) => () async {
        log.info('TILES | open from path', data: path);
        return PmTilesArchive.from(path).timeout(_pmtilesOpenTimeout);
      }(),
      PmtilesSourceUrl(:final url) => () async {
        log.info('TILES | open from URL', data: url);
        await probePmtilesHttpUrl(url);
        log.info('TILES | probe done; reading archive header', data: url);
        return PmTilesArchive.from(url).timeout(
          _pmtilesOpenTimeout,
          onTimeout: () {
            throw TimeoutException(
              'Timed out opening PMTiles at $url after '
              '${_pmtilesOpenTimeout.inSeconds}s.',
            );
          },
        );
      }(),
      PmtilesSourceBytes(:final bytes) => () async {
        log.info(
          'TILES | open from memory',
          data: 'size=${formatBytes(bytes.length)}',
        );
        return PmTilesArchive.fromBytes(bytes);
      }(),
    };

    log.success(
      'TILES | archive header OK',
      data:
          'version=${archive.version} tileType=${archive.tileType} tileCompression=${archive.tileCompression}',
    );
    return archive;
  } catch (error, stackTrace) {
    log.error(
      'TILES | archive open failed',
      error: error,
      stackTrace: stackTrace,
      data: source,
    );
    rethrow;
  }
}

Future<PmTilesArchive> openPmtilesArchive(PmtilesSource source) {
  return PmtilesArchivePool.instance.acquire(
    source,
    () => _openPmtilesArchiveRaw(source),
  );
}

Future<void> releasePmtilesArchive(PmtilesSource source) {
  return PmtilesArchivePool.instance.release(source);
}

Future<TileProvider> openPmtilesTileProvider(
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
    await releasePmtilesArchive(source);
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
  final archive = await openPmtilesArchive(source);
  try {
    return await _buildPmtilesMapLayerFromArchive(
      source: source,
      catalogId: catalogId,
      archive: archive,
    );
  } catch (error, stackTrace) {
    await releasePmtilesArchive(source);
    Error.throwWithStackTrace(error, stackTrace);
  }
}

Future<PmtilesMapLayerConfig> _buildPmtilesMapLayerFromArchive({
  required PmtilesSource source,
  required String catalogId,
  required PmTilesArchive archive,
}) async {
  final log = AppLogger.logPmtiles;

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
      log.error(
        '🗺️ Unsupported PMTiles tile type',
        data: archive.tileType.name,
      );
      throw UnsupportedError(
        'Unsupported PMTiles tile type. Use Protomaps vector (.pmtiles with MVT tiles) '
        'or raster tiles (PNG/JPEG/WebP).',
      );
  }
}
