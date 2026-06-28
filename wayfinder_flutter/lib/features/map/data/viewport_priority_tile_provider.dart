import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

/// Tile zoom used by [vector_map_tiles] for a fractional map zoom.
int tileZoomForViewport(double mapZoom) {
  return math.max(1, mapZoom.floor());
}

/// Limits concurrent tile reads and serves closest-to-viewport tiles first.
class ViewportPriorityTileScheduler {
  ViewportPriorityTileScheduler({this.maxConcurrent = 12});

  final int maxConcurrent;
  var _active = 0;
  var _closed = false;
  final _pending = <_PendingRequest<dynamic>>[];

  Future<T> schedule<T>(int priority, Future<T> Function() action) {
    if (_closed) {
      return action();
    }

    final completer = Completer<T>();
    _pending.add(
      _PendingRequest(
        priority,
        () async {
          try {
            completer.complete(await action());
          } catch (error, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          }
        },
      ),
    );
    _pending.sort((a, b) => a.priority.compareTo(b.priority));
    _drain();
    return completer.future;
  }

  void close() {
    _closed = true;
    _pending.clear();
  }

  void _drain() {
    while (!_closed && _active < maxConcurrent && _pending.isNotEmpty) {
      _active++;
      final next = _pending.removeAt(0);
      unawaited(
        next.action().whenComplete(() {
          _active--;
          _drain();
        }),
      );
    }
  }
}

class _PendingRequest<T> {
  const _PendingRequest(this.priority, this.action);

  final int priority;
  final Future<T> Function() action;
}

int tileDistancePriority({
  required TileIdentity tile,
  required LatLng viewportCenter,
}) {
  final center = latLngToTile(viewportCenter, tile.z);
  final zoomPenalty = 0;
  final dx = (tile.x - center.x).abs();
  final dy = (tile.y - center.y).abs();
  return zoomPenalty + dx + dy;
}

TileCoordinates latLngToTile(LatLng point, int zoom) {
  final scale = 1 << zoom;
  final latRad = point.latitude * math.pi / 180;
  final x = ((point.longitude + 180) / 360 * scale)
      .floor()
      .clamp(0, scale - 1)
      .toInt();
  final y = ((1 -
              math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
          2 *
          scale)
      .floor()
      .clamp(0, scale - 1)
      .toInt();
  return TileCoordinates(x, y, zoom);
}

List<TileIdentity> spiralTilesForViewport({
  required LatLngBounds bounds,
  required LatLng center,
  required int zoom,
  int? maxTiles,
}) {
  final scale = 1 << zoom;
  final minX = ((bounds.west + 180) / 360 * scale).floor().clamp(0, scale - 1);
  final maxX = ((bounds.east + 180) / 360 * scale).ceil().clamp(0, scale - 1);
  final minY = _latToTileY(bounds.north, zoom).clamp(0, scale - 1);
  final maxY = _latToTileY(bounds.south, zoom).clamp(0, scale - 1);

  final centerTile = latLngToTile(center, zoom);
  final ranked = <({int x, int y, int distance})>[];
  for (var x = minX; x <= maxX; x++) {
    for (var y = minY; y <= maxY; y++) {
      ranked.add((
        x: x,
        y: y,
        distance: (x - centerTile.x).abs() + (y - centerTile.y).abs(),
      ));
    }
  }

  ranked.sort((a, b) => a.distance.compareTo(b.distance));
  final tiles = [
    for (final tile in ranked)
      TileIdentity(zoom, tile.x, tile.y),
  ];
  if (maxTiles == null || tiles.length <= maxTiles) {
    return tiles;
  }
  return tiles.take(maxTiles).toList(growable: false);
}

int visibleTileCountForViewport({
  required LatLngBounds bounds,
  required int zoom,
}) {
  return spiralTilesForViewport(
    bounds: bounds,
    center: bounds.center,
    zoom: zoom,
  ).length;
}

int _latToTileY(double latitude, int zoom) {
  final scale = 1 << zoom;
  final latRad = latitude * math.pi / 180;
  return ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
          2 *
          scale)
      .floor();
}

/// Wraps a vector PMTiles provider so visible tiles are fetched first.
class ViewportPriorityPmTilesVectorTileProvider extends VectorTileProvider {
  ViewportPriorityPmTilesVectorTileProvider({
    required PmTilesVectorTileProvider delegate,
    required LatLng Function() viewportCenter,
    ViewportPriorityTileScheduler? scheduler,
  })  : _delegate = delegate,
        _viewportCenter = viewportCenter,
        _scheduler = scheduler ?? ViewportPriorityTileScheduler();

  final PmTilesVectorTileProvider _delegate;
  final LatLng Function() _viewportCenter;
  final ViewportPriorityTileScheduler _scheduler;

  @override
  final TileProviderType type = TileProviderType.vector;

  @override
  int get maximumZoom => _delegate.maximumZoom;

  @override
  int get minimumZoom => _delegate.minimumZoom;

  @override
  TileOffset get tileOffset => _delegate.tileOffset;

  PmTilesVectorTileProvider get delegate => _delegate;

  @override
  Future<Uint8List> provide(TileIdentity tile) {
    final priority = tileDistancePriority(
      tile: tile,
      viewportCenter: _viewportCenter(),
    );
    return _scheduler.schedule(
      priority,
      () => _delegate.provide(tile),
    );
  }

  Future<void> warmViewport({
    required LatLngBounds bounds,
    required LatLng center,
    required int zoom,
    int substitutionLevels = 2,
    int? maxTiles,
  }) async {
    final tileLimit = maxTiles ?? math.max(48, visibleTileCountForViewport(
      bounds: bounds,
      zoom: zoom,
    ));
    final tiles = <TileIdentity>{};
    for (var level = 0; level <= substitutionLevels; level++) {
      final tileZoom = zoom - level;
      if (tileZoom < minimumZoom) {
        break;
      }
      tiles.addAll(
        spiralTilesForViewport(
          bounds: bounds,
          center: center,
          zoom: tileZoom,
          maxTiles: tileLimit,
        ),
      );
    }

    await Future.wait(
      tiles.map(
        (tile) => provide(tile).catchError((_) => Uint8List(0)),
      ),
    );
  }

  void dispose() {
    _scheduler.close();
  }
}
