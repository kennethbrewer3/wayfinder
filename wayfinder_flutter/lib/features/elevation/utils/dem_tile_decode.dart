import 'dart:typed_data';
import 'dart:ui' as ui;

import 'elevation_dem_detect.dart';
import 'terrarium_decode.dart';

/// Decode DEM raster bytes for elevation sampling.
///
/// Prefers Flutter/`dart:ui` codecs (browser-native WebP on web), then falls
/// back to `package:image`.
Future<DecodedDemTile?> decodeDemTileBytesAsync(
  Uint8List bytes, {
  DemEncodingHint encoding = DemEncodingHint.terrarium,
}) async {
  if (bytes.isEmpty) {
    return null;
  }

  try {
    final fromFlutter = await _decodeWithFlutterCodec(bytes, encoding);
    if (fromFlutter != null) {
      return fromFlutter;
    }
  } catch (_) {
    // Fall through to package:image.
  }

  try {
    return decodeDemTileBytes(bytes, encoding: encoding);
  } catch (_) {
    return null;
  }
}

Future<DecodedDemTile?> _decodeWithFlutterCodec(
  Uint8List bytes,
  DemEncodingHint encoding,
) async {
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        return null;
      }
      return _elevationsFromRgba(
        width: image.width,
        height: image.height,
        rgba: byteData.buffer.asUint8List(),
        encoding: encoding,
      );
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

DecodedDemTile? _elevationsFromRgba({
  required int width,
  required int height,
  required Uint8List rgba,
  required DemEncodingHint encoding,
}) {
  if (width <= 0 || height <= 0) {
    return null;
  }
  final expected = width * height * 4;
  if (rgba.length < expected) {
    return null;
  }

  final decoder = encoding == DemEncodingHint.mapbox
      ? decodeMapboxTerrainRgbMeters
      : decodeTerrariumMeters;
  final elevations = Float32List(width * height);
  var i = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final o = (y * width + x) * 4;
      elevations[i++] = decoder(rgba[o], rgba[o + 1], rgba[o + 2]);
    }
  }
  return DecodedDemTile(
    width: width,
    height: height,
    elevations: elevations,
  );
}
