import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Mean Earth radius in meters for the spherical law of cosines.
const earthRadiusMeters = 6371000.0;

/// Bearing and geodesic interpolation along a segment. Line lengths use the
/// spherical law of cosines via [lineLengthMeters] instead.
const lineGeodesicCalculator = Distance();

double lineLengthMeters(LatLng start, LatLng end) {
  return sphericalLawOfCosinesDistanceMeters(start, end);
}

/// Great-circle distance using the spherical law of cosines:
/// d = R · acos(sin φ1 sin φ2 + cos φ1 cos φ2 cos Δλ)
double sphericalLawOfCosinesDistanceMeters(LatLng start, LatLng end) {
  final lat1 = start.latitudeInRad;
  final lat2 = end.latitudeInRad;
  final deltaLon = end.longitudeInRad - start.longitudeInRad;

  final centralAngle = math.sin(lat1) * math.sin(lat2) +
      math.cos(lat1) * math.cos(lat2) * math.cos(deltaLon);

  return earthRadiusMeters * math.acos(centralAngle.clamp(-1.0, 1.0));
}

double lineLengthMetersForPoints(List<LatLng> points) {
  if (points.length < 2) {
    return 0;
  }
  var total = 0.0;
  for (var index = 0; index < points.length - 1; index++) {
    total += lineLengthMeters(points[index], points[index + 1]);
  }
  return total;
}

LatLng lineSegmentMidpoint(LatLng start, LatLng end) {
  final meters = lineLengthMeters(start, end);
  if (meters < 0.5) {
    return start;
  }

  final bearing = lineGeodesicCalculator.bearing(start, end);
  return lineGeodesicCalculator.offset(start, meters / 2, bearing);
}
