import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

/// Resolved map layer configuration for an active PMTiles archive.
sealed class PmtilesMapLayerConfig {
  const PmtilesMapLayerConfig({
    required this.catalogId,
    required this.minZoom,
    required this.maxZoom,
    required this.tileType,
  });

  final String catalogId;
  final int minZoom;
  final int maxZoom;
  final TileType tileType;
}

class PmtilesRasterMapLayerConfig extends PmtilesMapLayerConfig {
  const PmtilesRasterMapLayerConfig({
    required super.catalogId,
    required super.minZoom,
    required super.maxZoom,
    required super.tileType,
    required this.tileProvider,
  });

  final PmTilesTileProvider tileProvider;
}

class PmtilesVectorMapLayerConfig extends PmtilesMapLayerConfig {
  const PmtilesVectorMapLayerConfig({
    required super.catalogId,
    required super.minZoom,
    required super.maxZoom,
    required super.tileType,
    required this.tileProvider,
    required this.theme,
    required this.sprites,
  });

  final PmTilesVectorTileProvider tileProvider;
  final Theme theme;
  final SpriteStyle sprites;
}
