import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../map/utils/pmtiles_viewport.dart';
import '../models/atlas_bounds.dart';

/// Web Mercator latitude limit used by XYZ tiles.
const atlasMercatorMaxLat = 85.05112878;

/// Normalized mercator X in \[0, 1\] (0 = west / -180°).
double lngToMercatorX(double longitude) {
  return (longitude + 180.0) / 360.0;
}

/// Normalized mercator Y in \[0, 1\] (0 = north pole side).
double latToMercatorY(double latitude) {
  final lat = latitude.clamp(-atlasMercatorMaxLat, atlasMercatorMaxLat);
  final latRad = lat * math.pi / 180.0;
  final y =
      (1 -
          math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
      2;
  return y.clamp(0.0, 1.0);
}

/// Inclusive XYZ tile range covering [bounds] at [zoom].
({int minX, int maxX, int minY, int maxY, int zoom}) tileRangeForBounds({
  required AtlasBounds bounds,
  required int zoom,
}) {
  final sw = latLngToTile(
    LatLng(
      bounds.south.clamp(-atlasMercatorMaxLat, atlasMercatorMaxLat),
      bounds.west,
    ),
    zoom,
  );
  final ne = latLngToTile(
    LatLng(
      bounds.north.clamp(-atlasMercatorMaxLat, atlasMercatorMaxLat),
      bounds.east,
    ),
    zoom,
  );
  final maxIndex = (1 << zoom) - 1;
  return (
    minX: math.min(sw.x, ne.x).clamp(0, maxIndex),
    maxX: math.max(sw.x, ne.x).clamp(0, maxIndex),
    minY: math.min(sw.y, ne.y).clamp(0, maxIndex),
    maxY: math.max(sw.y, ne.y).clamp(0, maxIndex),
    zoom: zoom,
  );
}

/// Chooses a tile zoom that yields roughly [targetTilesAcross] tiles.
int pickAtlasTileZoom(
  AtlasBounds bounds, {
  int minZoom = 1,
  int maxZoom = 15,
  int targetTilesAcross = 6,
  int maxTiles = 48,
}) {
  final lngSpan = math.max(bounds.lngSpan, 1e-6);
  var zoom = (math.log(targetTilesAcross * 360.0 / lngSpan) / math.ln2)
      .floor()
      .clamp(minZoom, maxZoom);

  while (zoom > minZoom) {
    final range = tileRangeForBounds(bounds: bounds, zoom: zoom);
    final count =
        (range.maxX - range.minX + 1) * (range.maxY - range.minY + 1);
    if (count <= maxTiles) {
      break;
    }
    zoom -= 1;
  }
  return zoom;
}
