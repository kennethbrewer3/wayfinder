import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// Geographic bounding box used when tiling printable map sheets.
class AtlasBounds {
  const AtlasBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;

  double get centerLatitude => (south + north) / 2;
  double get centerLongitude => (west + east) / 2;

  LatLng get center => LatLng(centerLatitude, centerLongitude);

  double get latSpan => north - south;
  double get lngSpan => east - west;

  bool get isValid => south < north && west < east;

  bool contains(LatLng point) {
    return point.latitude >= south &&
        point.latitude <= north &&
        point.longitude >= west &&
        point.longitude <= east;
  }

  AtlasBounds padded(double fraction) {
    final latPad = latSpan * fraction;
    final lngPad = lngSpan * fraction;
    return AtlasBounds(
      south: (south - latPad).clamp(-90.0, 90.0),
      west: (west - lngPad).clamp(-180.0, 180.0),
      north: (north + latPad).clamp(-90.0, 90.0),
      east: (east + lngPad).clamp(-180.0, 180.0),
    );
  }

  static AtlasBounds? fromMarkers(Iterable<MapMarker> markers) {
    final visible = markers.where((marker) => marker.visible).toList();
    if (visible.isEmpty) {
      return null;
    }

    var south = visible.first.latitude;
    var north = visible.first.latitude;
    var west = visible.first.longitude;
    var east = visible.first.longitude;
    for (final marker in visible.skip(1)) {
      south = math.min(south, marker.latitude);
      north = math.max(north, marker.latitude);
      west = math.min(west, marker.longitude);
      east = math.max(east, marker.longitude);
    }

    // Degenerate single-point / collinear sets need a minimum footprint.
    if ((north - south).abs() < 1e-5) {
      south -= 0.01;
      north += 0.01;
    }
    if ((east - west).abs() < 1e-5) {
      west -= 0.01;
      east += 0.01;
    }

    return AtlasBounds(
      south: south,
      west: west,
      north: north,
      east: east,
    ).padded(0.08);
  }
}
