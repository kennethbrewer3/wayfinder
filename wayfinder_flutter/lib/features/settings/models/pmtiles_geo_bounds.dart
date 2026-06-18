import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Geographic bounds of a PMTiles archive.
class PmtilesGeoBounds {
  const PmtilesGeoBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;

  factory PmtilesGeoBounds.fromPositions(LatLng minPosition, LatLng maxPosition) {
    return PmtilesGeoBounds(
      south: math.min(minPosition.latitude, maxPosition.latitude),
      west: math.min(minPosition.longitude, maxPosition.longitude),
      north: math.max(minPosition.latitude, maxPosition.latitude),
      east: math.max(minPosition.longitude, maxPosition.longitude),
    );
  }

  LatLng get center => LatLng(
        (south + north) / 2,
        (west + east) / 2,
      );

  double get latitudeSpan => (north - south).abs();

  double get longitudeSpan => (east - west).abs();

  double get geographicArea => latitudeSpan * longitudeSpan;

  bool contains(LatLng point) {
    return point.latitude >= south &&
        point.latitude <= north &&
        point.longitude >= west &&
        point.longitude <= east;
  }
}
