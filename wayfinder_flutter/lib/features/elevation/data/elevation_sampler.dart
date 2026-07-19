import 'dart:math' as math;
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:pmtiles/pmtiles.dart';

import '../../../core/logging/app_logger.dart';
import '../../map/utils/pmtiles_viewport.dart';
import '../../map_atlas/utils/atlas_web_mercator.dart';
import '../../settings/data/pmtiles_archive_pool.dart';
import '../../settings/data/pmtiles_loader.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import '../../settings/models/pmtiles_source.dart';
import '../utils/dem_tile_decode.dart';
import '../utils/elevation_dem_detect.dart';
import '../utils/terrarium_decode.dart';

final _log = AppLogger.logPmtiles;

/// Samples offline DEM PMTiles (Terrarium / Terrain-RGB raster tiles).
class ElevationSampler {
  ElevationSampler({
    required List<PmtilesArchiveEntry> demEntries,
  }) : _entries = List.unmodifiable(_preferRegionalDemEntries(demEntries));

  final List<PmtilesArchiveEntry> _entries;
  final Map<String, DecodedDemTile> _tileCache = {};
  final Map<String, PmTilesArchive> _archives = {};
  final Map<String, PmtilesSource> _heldSources = {};
  final Set<String> _loggedFetchFailures = {};
  final Set<String> _loggedDecodeFailures = {};
  final Set<String> _loggedSampleMisses = {};
  var _loggedSampleHit = false;
  static const _maxCachedTiles = 48;

  /// Drop planet-scale DEM archives when any regional pack is available.
  static List<PmtilesArchiveEntry> _preferRegionalDemEntries(
    List<PmtilesArchiveEntry> entries,
  ) {
    if (entries.length <= 1) {
      return entries;
    }
    const planetArea = 360.0 * 180.0 * 0.9;
    final regional = [
      for (final entry in entries)
        if (!entry.boundsKnown || entry.bounds.geographicArea < planetArea)
          entry,
    ];
    if (regional.isEmpty || regional.length == entries.length) {
      return regional.isEmpty ? entries : regional;
    }
    final regionalIds = {for (final entry in regional) entry.id};
    final skipped = [
      for (final entry in entries)
        if (!regionalIds.contains(entry.id)) entry.name,
    ];
    _log.info(
      '⛰️ Preferring regional DEM over planet-scale archive(s)',
      data:
          'using=${regional.map((e) => e.name).join(', ')} '
          'skipped=${skipped.join(', ')}',
    );
    return regional;
  }

  bool get hasDem => _entries.isNotEmpty;

  List<PmtilesArchiveEntry> get entries => _entries;

  /// Spot elevation in meters, or null when no DEM covers the point.
  Future<double?> elevationAt(
    LatLng point, {
    int? preferredZoom,
  }) async {
    if (_entries.isEmpty) {
      return null;
    }
    try {
      return await _elevationAtUnchecked(point, preferredZoom: preferredZoom);
    } catch (error, stackTrace) {
      _log.warn(
        '⛰️ DEM sample error',
        data: 'lat=${point.latitude} lng=${point.longitude} error=$error',
      );
      assert(() {
        // ignore: avoid_print
        print(stackTrace);
        return true;
      }());
      return null;
    }
  }

  Future<double?> _elevationAtUnchecked(
    LatLng point, {
    int? preferredZoom,
  }) async {
    final entry = _pickEntry(point);
    if (entry == null) {
      _log.debug(
        '⛰️ DEM: no archive covers point',
        data: 'lat=${point.latitude} lng=${point.longitude}',
      );
      return null;
    }

    final archive = await _holdArchive(entry);
    final minZoom = archive.minZoom;
    final maxZoom = math.min(archive.maxZoom, 14);
    final zoom = (preferredZoom ?? maxZoom).clamp(minZoom, maxZoom).toInt();
    final encoding = demEncodingHintForFileName(entry.name);

    for (var z = zoom; z >= minZoom; z--) {
      final sample = await _sampleAtZoom(
        entry: entry,
        archive: archive,
        point: point,
        zoom: z,
        encoding: encoding,
      );
      if (sample != null) {
        if (!_loggedSampleHit) {
          _loggedSampleHit = true;
          _log.info(
            '⛰️ DEM sample ok',
            data:
                'archive=${entry.name} z=$z '
                'lat=${point.latitude.toStringAsFixed(5)} '
                'lng=${point.longitude.toStringAsFixed(5)} '
                'elev=${sample.toStringAsFixed(1)}m',
          );
        }
        return sample;
      }
    }
    final missKey = entry.id;
    if (_loggedSampleMisses.add(missKey)) {
      _log.warn(
        '⛰️ DEM sample miss (no tile / decode) for archive',
        data:
            'archive=${entry.name} tried z=$zoom..$minZoom '
            'lat=${point.latitude.toStringAsFixed(5)} '
            'lng=${point.longitude.toStringAsFixed(5)}',
      );
    }
    return null;
  }

  /// Samples many points; reuses open archives and tile cache.
  Future<List<double?>> elevationsAlong(
    List<LatLng> points, {
    int? preferredZoom,
  }) async {
    final results = <double?>[];
    for (final point in points) {
      results.add(await elevationAt(point, preferredZoom: preferredZoom));
    }
    return results;
  }

  /// Releases pool references acquired by this sampler.
  Future<void> dispose() async {
    final sources = List<PmtilesSource>.from(_heldSources.values);
    _heldSources.clear();
    _archives.clear();
    _tileCache.clear();
    for (final source in sources) {
      await releasePmtilesArchive(source);
    }
  }

  PmtilesArchiveEntry? _pickEntry(LatLng point) {
    PmtilesArchiveEntry? best;
    var bestArea = double.infinity;
    for (final entry in _entries) {
      if (entry.boundsKnown && !entry.bounds.contains(point)) {
        continue;
      }
      final area = entry.bounds.geographicArea;
      if (area < bestArea) {
        bestArea = area;
        best = entry;
      }
    }
    return best ?? (_entries.length == 1 ? _entries.first : null);
  }

  Future<PmTilesArchive> _holdArchive(PmtilesArchiveEntry entry) async {
    final key = pmtilesSourceKey(entry.source);
    final existing = _archives[key];
    if (existing != null) {
      return existing;
    }
    final archive = await openPmtilesArchive(entry.source);
    _archives[key] = archive;
    _heldSources[key] = entry.source;
    _log.info(
      '⛰️ DEM archive ready',
      data:
          'name=${entry.name} tileType=${archive.tileType} '
          'tileCompression=${archive.tileCompression} '
          'zoom=${archive.minZoom}-${archive.maxZoom}',
    );
    return archive;
  }

  Future<double?> _sampleAtZoom({
    required PmtilesArchiveEntry entry,
    required PmTilesArchive archive,
    required LatLng point,
    required int zoom,
    required DemEncodingHint encoding,
  }) async {
    final coords = latLngToTile(point, zoom);
    final cacheKey = '${entry.id}/$zoom/${coords.x}/${coords.y}';
    var tile = _tileCache[cacheKey];
    if (tile == null) {
      final bytes = await _fetchTileBytes(
        entry: entry,
        archive: archive,
        z: coords.z,
        x: coords.x,
        y: coords.y,
      );
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      tile = await decodeDemTileBytesAsync(bytes, encoding: encoding);
      if (tile == null) {
        final failKey = '${entry.id}:${archive.tileType}';
        if (_loggedDecodeFailures.add(failKey)) {
          final magic = bytes.length >= 4
              ? bytes.sublist(0, 4).toList()
              : bytes;
          _log.warn(
            '⛰️ DEM tile decode failed',
            data:
                'archive=${entry.name} tileType=${archive.tileType} '
                'bytes=${bytes.length} magic=$magic encoding=$encoding',
          );
        }
        return null;
      }
      _rememberTile(cacheKey, tile);
    }

    final n = 1 << zoom;
    final worldX = lngToMercatorX(point.longitude) * n;
    final worldY = latToMercatorY(point.latitude) * n;
    final pixelX = (worldX - coords.x) * tile.width;
    final pixelY = (worldY - coords.y) * tile.height;
    return tile.sample(pixelX, pixelY);
  }

  Future<Uint8List?> _fetchTileBytes({
    required PmtilesArchiveEntry entry,
    required PmTilesArchive archive,
    required int z,
    required int x,
    required int y,
  }) async {
    try {
      final tileId = ZXY(z, x, y).toTileId();
      final tile = await archive.tile(tileId);
      return Uint8List.fromList(tile.bytes());
    } on TileNotFoundException {
      return null;
    } catch (error) {
      final failKey = '${entry.id}:$error';
      if (_loggedFetchFailures.add(failKey)) {
        _log.warn(
          '⛰️ DEM tile fetch failed',
          data: 'archive=${entry.name} z=$z x=$x y=$y error=$error',
        );
      }
      return null;
    }
  }

  void _rememberTile(String key, DecodedDemTile tile) {
    if (_tileCache.length >= _maxCachedTiles) {
      _tileCache.remove(_tileCache.keys.first);
    }
    _tileCache[key] = tile;
  }
}
