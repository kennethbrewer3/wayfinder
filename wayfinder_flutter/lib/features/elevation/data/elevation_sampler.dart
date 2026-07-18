import 'dart:math' as math;
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:pmtiles/pmtiles.dart';

import '../../../core/logging/app_logger.dart';
import '../../map/utils/pmtiles_viewport.dart';
import '../../map_atlas/utils/atlas_web_mercator.dart';
import '../../settings/data/pmtiles_loader.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import '../utils/elevation_dem_detect.dart';
import '../utils/terrarium_decode.dart';

final _log = AppLogger.logPmtiles;

/// Samples offline DEM PMTiles (Terrarium / Terrain-RGB PNG tiles).
class ElevationSampler {
  ElevationSampler({
    required List<PmtilesArchiveEntry> demEntries,
  }) : _entries = List.unmodifiable(demEntries);

  final List<PmtilesArchiveEntry> _entries;
  final Map<String, DecodedDemTile> _tileCache = {};
  static const _maxCachedTiles = 48;

  bool get hasDem => _entries.isNotEmpty;

  /// Spot elevation in meters, or null when no DEM covers the point.
  Future<double?> elevationAt(
    LatLng point, {
    int? preferredZoom,
  }) async {
    if (_entries.isEmpty) {
      return null;
    }
    final entry = _pickEntry(point);
    if (entry == null) {
      return null;
    }

    final zoom = (preferredZoom ?? entry.maxZoom)
        .clamp(entry.minZoom, math.min(entry.maxZoom, 14))
        .toInt();
    final encoding = demEncodingHintForFileName(entry.name);

    for (var z = zoom; z >= entry.minZoom; z--) {
      final sample = await _sampleAtZoom(
        entry: entry,
        point: point,
        zoom: z,
        encoding: encoding,
      );
      if (sample != null) {
        return sample;
      }
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

  Future<double?> _sampleAtZoom({
    required PmtilesArchiveEntry entry,
    required LatLng point,
    required int zoom,
    required DemEncodingHint encoding,
  }) async {
    final coords = latLngToTile(point, zoom);
    final cacheKey = '${entry.id}/$zoom/${coords.x}/${coords.y}';
    var tile = _tileCache[cacheKey];
    if (tile == null) {
      final bytes = await _fetchTileBytes(entry, coords.z, coords.x, coords.y);
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      tile = decodeDemTilePng(bytes, encoding: encoding);
      if (tile == null) {
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

  Future<Uint8List?> _fetchTileBytes(
    PmtilesArchiveEntry entry,
    int z,
    int x,
    int y,
  ) async {
    final archive = await openPmtilesArchive(entry.source);
    try {
      final tileId = ZXY(z, x, y).toTileId();
      final tile = await archive.tile(tileId);
      return Uint8List.fromList(tile.bytes());
    } on TileNotFoundException {
      return null;
    } catch (error) {
      _log.debug(
        '⛰️ DEM tile fetch failed',
        data: 'archive=${entry.name} z=$z x=$x y=$y error=$error',
      );
      return null;
    } finally {
      await releasePmtilesArchive(entry.source);
    }
  }

  void _rememberTile(String key, DecodedDemTile tile) {
    if (_tileCache.length >= _maxCachedTiles) {
      _tileCache.remove(_tileCache.keys.first);
    }
    _tileCache[key] = tile;
  }
}
