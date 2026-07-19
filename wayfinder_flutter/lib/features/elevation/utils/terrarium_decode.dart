import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'elevation_dem_detect.dart';

/// Decoded DEM tile heights in meters (row-major).
class DecodedDemTile {
  const DecodedDemTile({
    required this.width,
    required this.height,
    required this.elevations,
  });

  final int width;
  final int height;
  final Float32List elevations;

  double? elevationAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return null;
    }
    final value = elevations[y * width + x];
    if (!_isPlausible(value)) {
      return null;
    }
    return value;
  }

  /// Bilinear sample at fractional pixel coordinates.
  double? sample(double x, double y) {
    if (width < 1 || height < 1) {
      return null;
    }
    final x0 = x.floor().clamp(0, width - 1);
    final y0 = y.floor().clamp(0, height - 1);
    final x1 = (x0 + 1).clamp(0, width - 1);
    final y1 = (y0 + 1).clamp(0, height - 1);
    final fx = (x - x0).clamp(0.0, 1.0);
    final fy = (y - y0).clamp(0.0, 1.0);

    final v00 = elevationAt(x0, y0);
    final v10 = elevationAt(x1, y0);
    final v01 = elevationAt(x0, y1);
    final v11 = elevationAt(x1, y1);
    if (v00 == null || v10 == null || v01 == null || v11 == null) {
      return v00 ?? v10 ?? v01 ?? v11;
    }

    final top = v00 * (1 - fx) + v10 * fx;
    final bottom = v01 * (1 - fx) + v11 * fx;
    return top * (1 - fy) + bottom * fy;
  }
}

/// Terrarium: `height = R * 256 + G + B / 256 - 32768`
double decodeTerrariumMeters(num r, num g, num b) {
  return r * 256 + g + b / 256 - 32768;
}

/// Mapbox Terrain-RGB: `height = -10000 + (R*65536 + G*256 + B) * 0.1`
double decodeMapboxTerrainRgbMeters(num r, num g, num b) {
  return -10000 + (r * 256 * 256 + g * 256 + b) * 0.1;
}

DecodedDemTile? decodeDemTilePng(
  Uint8List bytes, {
  DemEncodingHint encoding = DemEncodingHint.terrarium,
}) {
  return decodeDemTileBytes(bytes, encoding: encoding);
}

/// Decode DEM raster bytes (PNG preferred; falls back to general image decode).
DecodedDemTile? decodeDemTileBytes(
  Uint8List bytes, {
  DemEncodingHint encoding = DemEncodingHint.terrarium,
}) {
  final image = img.decodePng(bytes) ?? img.decodeImage(bytes);
  if (image == null || image.width <= 0 || image.height <= 0) {
    return null;
  }

  final decoder = encoding == DemEncodingHint.mapbox
      ? decodeMapboxTerrainRgbMeters
      : decodeTerrariumMeters;
  final elevations = Float32List(image.width * image.height);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      elevations[y * image.width + x] = decoder(pixel.r, pixel.g, pixel.b);
    }
  }
  return DecodedDemTile(
    width: image.width,
    height: image.height,
    elevations: elevations,
  );
}

bool _isPlausible(double meters) {
  // Rough Earth surface bounds; filters NODATA / decode garbage.
  return meters >= -500 && meters <= 9000 && !meters.isNaN;
}
