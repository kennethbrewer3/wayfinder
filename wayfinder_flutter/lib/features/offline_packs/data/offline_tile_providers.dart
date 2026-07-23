import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../../map/data/protomaps_offline_assets.dart';
import '../../settings/models/pmtiles_map_layer.dart';
import '../models/offline_pack.dart';
import 'offline_tile_cache.dart';

/// Raster tiles served only from the prepared offline AOI cache.
class OfflineCachedRasterTileProvider extends TileProvider {
  OfflineCachedRasterTileProvider({
    required this.catalogId,
    required this.cache,
  });

  final String catalogId;
  final OfflineTileCache cache;

  @override
  bool get supportsCancelLoading => false;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return OfflineCachedTileImageProvider(
      catalogId: catalogId,
      cache: cache,
      z: coordinates.z,
      x: coordinates.x,
      y: coordinates.y,
    );
  }
}

class OfflineCachedTileImageProvider
    extends ImageProvider<OfflineCachedTileImageProvider> {
  OfflineCachedTileImageProvider({
    required this.catalogId,
    required this.cache,
    required this.z,
    required this.x,
    required this.y,
  });

  final String catalogId;
  final OfflineTileCache cache;
  final int z;
  final int x;
  final int y;

  @override
  Future<OfflineCachedTileImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    OfflineCachedTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: 1,
      debugLabel: '$catalogId/$z/$x/$y',
    );
  }

  Future<ui.Codec> _loadAsync(
    OfflineCachedTileImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    try {
      final bytes = await key.cache.getTile(
        catalogId: key.catalogId,
        z: key.z,
        x: key.x,
        y: key.y,
      );
      if (bytes == null || bytes.isEmpty) {
        throw StateError(
          'Offline tile missing: ${key.catalogId}/${key.z}/${key.x}/${key.y}',
        );
      }
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    return other is OfflineCachedTileImageProvider &&
        other.catalogId == catalogId &&
        other.z == z &&
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode => Object.hash(catalogId, z, x, y);
}

/// Vector tiles served only from the prepared offline AOI cache.
class OfflineCachedVectorTileProvider extends VectorTileProvider {
  OfflineCachedVectorTileProvider({
    required this.catalogId,
    required this.cache,
    required this.minZoom,
    required this.maxZoom,
    this.tileOffset = TileOffset.DEFAULT,
  });

  final String catalogId;
  final OfflineTileCache cache;
  final int minZoom;
  final int maxZoom;

  @override
  final TileOffset tileOffset;

  @override
  TileProviderType get type => TileProviderType.vector;

  @override
  int get minimumZoom => minZoom;

  @override
  int get maximumZoom => maxZoom;

  @override
  Future<Uint8List> provide(TileIdentity tile) async {
    final bytes = await cache.getTile(
      catalogId: catalogId,
      z: tile.z,
      x: tile.x,
      y: tile.y,
    );
    if (bytes == null || bytes.isEmpty) {
      throw ProviderException(
        message: 'Offline tile not found: $tile',
        retryable: Retryable.none,
        statusCode: 404,
      );
    }
    return bytes;
  }
}

Future<PmtilesMapLayerConfig> buildOfflineCachedMapLayer({
  required OfflinePackBasemap basemap,
  required OfflineTileCache cache,
}) async {
  final tileType = TileType.values.firstWhere(
    (value) => value.name == basemap.tileType,
    orElse: () => TileType.mvt,
  );

  switch (tileType) {
    case TileType.mvt:
    case TileType.unknown:
      final style = await ProtomapsOfflineAssets.loadLightV4();
      return PmtilesVectorMapLayerConfig(
        catalogId: basemap.catalogId,
        minZoom: basemap.minZoom,
        maxZoom: basemap.maxZoom,
        tileType: TileType.mvt,
        tileProvider: OfflineCachedVectorTileProvider(
          catalogId: basemap.catalogId,
          cache: cache,
          minZoom: basemap.minZoom,
          maxZoom: basemap.maxZoom,
        ),
        theme: style.theme,
        backgroundTheme: style.backgroundTheme,
        sprites: style.sprites,
      );
    case TileType.png:
    case TileType.jpeg:
    case TileType.webp:
    case TileType.avif:
      return PmtilesRasterMapLayerConfig(
        catalogId: basemap.catalogId,
        minZoom: basemap.minZoom,
        maxZoom: basemap.maxZoom,
        tileType: tileType,
        tileProvider: OfflineCachedRasterTileProvider(
          catalogId: basemap.catalogId,
          cache: cache,
        ),
      );
  }
}
