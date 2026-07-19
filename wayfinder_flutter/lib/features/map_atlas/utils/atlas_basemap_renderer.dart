import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_map/flutter_map.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../../../core/logging/app_logger.dart';
import '../../map/data/protomaps_offline_assets.dart';
import '../../map/utils/pmtiles_archive_selection.dart';
import '../../settings/data/pmtiles_loader.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import '../models/atlas_bounds.dart';
import 'atlas_web_mercator.dart';

final _log = AppLogger.logPmtiles;

const _tilePixelSize = 256;
const _renderScale = 2; // 512px rendered tiles for sharper print

/// Renders a Web Mercator basemap mosaic for [bounds] as PNG bytes.
///
/// Returns `null` when no enabled archive covers the area or rendering fails.
Future<Uint8List?> renderAtlasBasemapPng({
  required AtlasBounds bounds,
  required List<PmtilesArchiveEntry> enabledEntries,
}) async {
  if (!bounds.isValid || enabledEntries.isEmpty) {
    return null;
  }

  final viewportBounds = LatLngBounds.unsafe(
    south: bounds.south,
    west: bounds.west,
    north: bounds.north,
    east: bounds.east,
  );
  final estimatedZoom = pickAtlasTileZoom(bounds);
  final selection = await resolveActiveArchiveForViewport(
    entries: enabledEntries,
    viewportBounds: viewportBounds,
    viewportCenter: bounds.center,
    viewportZoom: estimatedZoom.toDouble(),
  );
  final entry = selection.entry;
  if (entry == null) {
    _log.warn('🗺️ Atlas basemap: no archive for sheet center');
    return null;
  }

  final zoom = pickAtlasTileZoom(
    bounds,
    minZoom: entry.minZoom,
    maxZoom: math.min(entry.maxZoom, 15),
  );
  final range = tileRangeForBounds(bounds: bounds, zoom: zoom);
  final tilesX = range.maxX - range.minX + 1;
  final tilesY = range.maxY - range.minY + 1;
  if (tilesX <= 0 || tilesY <= 0) {
    return null;
  }

  _log.info(
    '🗺️ Atlas basemap rendering',
    data:
        'archive=${entry.name} z=$zoom tiles=${tilesX}x$tilesY '
        'sheet=${bounds.south.toStringAsFixed(4)},${bounds.west.toStringAsFixed(4)}',
  );

  final archive = await openPmtilesArchive(entry.source);
  try {
    final renderedTiles = <_RenderedTile>[];
    try {
      if (archive.tileType == TileType.mvt) {
        final style = await ProtomapsOfflineAssets.loadLightV4();
        final spriteBytes = await style.sprites.atlasProvider();
        final spriteAtlas = await _decodeImage(spriteBytes);
        try {
          final renderer = ImageRenderer(
            theme: style.theme,
            scale: _renderScale.toDouble(),
          );
          final tileFactory = TileFactory(style.theme, const Logger.noop());
          final preprocessor = TilesetPreprocessor(style.theme);

          for (var y = range.minY; y <= range.maxY; y++) {
            for (var x = range.minX; x <= range.maxX; x++) {
              final image = await _renderVectorTile(
                archive: archive,
                x: x,
                y: y,
                zoom: zoom,
                renderer: renderer,
                tileFactory: tileFactory,
                preprocessor: preprocessor,
                spriteIndex: style.sprites.index,
                spriteAtlas: spriteAtlas,
              );
              if (image != null) {
                renderedTiles.add(
                  _RenderedTile(x: x, y: y, image: image),
                );
              }
            }
          }
        } finally {
          spriteAtlas.dispose();
        }
      } else if (_isRasterTileType(archive.tileType)) {
        for (var y = range.minY; y <= range.maxY; y++) {
          for (var x = range.minX; x <= range.maxX; x++) {
            final image = await _loadRasterTile(
              archive: archive,
              x: x,
              y: y,
              zoom: zoom,
            );
            if (image != null) {
              renderedTiles.add(
                _RenderedTile(x: x, y: y, image: image),
              );
            }
          }
        }
      } else {
        _log.warn(
          '🗺️ Atlas basemap: unsupported tile type',
          data: archive.tileType.name,
        );
        return null;
      }

      if (renderedTiles.isEmpty) {
        return null;
      }

      return _stitchAndCrop(
        tiles: renderedTiles,
        range: range,
        bounds: bounds,
        tileDrawSize: archive.tileType == TileType.mvt
            ? _tilePixelSize * _renderScale
            : _tilePixelSize,
      );
    } finally {
      for (final tile in renderedTiles) {
        tile.image.dispose();
      }
    }
  } catch (error, stackTrace) {
    _log.error(
      '🗺️ Atlas basemap render failed',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  } finally {
    await releasePmtilesArchive(entry.source);
  }
}

bool _isRasterTileType(TileType type) {
  return type == TileType.png ||
      type == TileType.jpeg ||
      type == TileType.webp ||
      type == TileType.avif;
}

Future<ui.Image?> _renderVectorTile({
  required PmTilesArchive archive,
  required int x,
  required int y,
  required int zoom,
  required ImageRenderer renderer,
  required TileFactory tileFactory,
  required TilesetPreprocessor preprocessor,
  required SpriteIndex spriteIndex,
  required ui.Image spriteAtlas,
}) async {
  try {
    final tileId = ZXY(zoom, x, y).toTileId();
    final tile = await archive.tile(tileId);
    final bytes = Uint8List.fromList(tile.bytes());
    if (bytes.isEmpty) {
      return null;
    }
    final model = tileFactory.create(VectorTileReader().read(bytes));
    final tileset = preprocessor.preprocess(
      Tileset({'protomaps': model}),
      zoom: zoom.toDouble(),
    );
    return renderer.render(
      TileSource(
        tileset: tileset,
        spriteIndex: spriteIndex,
        spriteAtlas: spriteAtlas,
      ),
      zoom: zoom.toDouble(),
    );
  } on TileNotFoundException {
    return null;
  } catch (error) {
    _log.debug(
      '🗺️ Atlas skipped vector tile',
      data: 'z=$zoom x=$x y=$y error=$error',
    );
    return null;
  }
}

Future<ui.Image?> _loadRasterTile({
  required PmTilesArchive archive,
  required int x,
  required int y,
  required int zoom,
}) async {
  try {
    final tileId = ZXY(zoom, x, y).toTileId();
    final tile = await archive.tile(tileId);
    final bytes = Uint8List.fromList(tile.bytes());
    if (bytes.isEmpty) {
      return null;
    }
    return _decodeImage(bytes);
  } on TileNotFoundException {
    return null;
  } catch (error) {
    _log.debug(
      '🗺️ Atlas skipped raster tile',
      data: 'z=$zoom x=$x y=$y error=$error',
    );
    return null;
  }
}

Future<ui.Image> _decodeImage(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<Uint8List> _stitchAndCrop({
  required List<_RenderedTile> tiles,
  required ({int minX, int maxX, int minY, int maxY, int zoom}) range,
  required AtlasBounds bounds,
  required int tileDrawSize,
}) async {
  final mosaicWidth = (range.maxX - range.minX + 1) * tileDrawSize;
  final mosaicHeight = (range.maxY - range.minY + 1) * tileDrawSize;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(const ui.Color(0xFFE0E0E0), ui.BlendMode.src);

  for (final tile in tiles) {
    final dx = (tile.x - range.minX) * tileDrawSize.toDouble();
    final dy = (tile.y - range.minY) * tileDrawSize.toDouble();
    canvas.drawImageRect(
      tile.image,
      ui.Rect.fromLTWH(
        0,
        0,
        tile.image.width.toDouble(),
        tile.image.height.toDouble(),
      ),
      ui.Rect.fromLTWH(
        dx,
        dy,
        tileDrawSize.toDouble(),
        tileDrawSize.toDouble(),
      ),
      ui.Paint(),
    );
  }

  final mosaic = await recorder.endRecording().toImage(
    mosaicWidth,
    mosaicHeight,
  );
  try {
    final worldPixels = (1 << range.zoom) * tileDrawSize;
    final mosaicOriginX = range.minX * tileDrawSize.toDouble();
    final mosaicOriginY = range.minY * tileDrawSize.toDouble();
    final left = lngToMercatorX(bounds.west) * worldPixels - mosaicOriginX;
    final right = lngToMercatorX(bounds.east) * worldPixels - mosaicOriginX;
    final top = latToMercatorY(bounds.north) * worldPixels - mosaicOriginY;
    final bottom = latToMercatorY(bounds.south) * worldPixels - mosaicOriginY;
    final cropLeft = left.clamp(0.0, mosaicWidth.toDouble());
    final cropTop = top.clamp(0.0, mosaicHeight.toDouble());
    final cropRight = right.clamp(0.0, mosaicWidth.toDouble());
    final cropBottom = bottom.clamp(0.0, mosaicHeight.toDouble());
    final cropWidth = math.max(1, (cropRight - cropLeft).round());
    final cropHeight = math.max(1, (cropBottom - cropTop).round());

    final cropRecorder = ui.PictureRecorder();
    final cropCanvas = ui.Canvas(cropRecorder);
    cropCanvas.drawImageRect(
      mosaic,
      ui.Rect.fromLTWH(
        cropLeft,
        cropTop,
        cropWidth.toDouble(),
        cropHeight.toDouble(),
      ),
      ui.Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
      ui.Paint(),
    );
    final cropped = await cropRecorder.endRecording().toImage(
      cropWidth,
      cropHeight,
    );
    try {
      final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode atlas basemap PNG');
      }
      return byteData.buffer.asUint8List();
    } finally {
      cropped.dispose();
    }
  } finally {
    mosaic.dispose();
  }
}

class _RenderedTile {
  const _RenderedTile({
    required this.x,
    required this.y,
    required this.image,
  });

  final int x;
  final int y;
  final ui.Image image;
}
