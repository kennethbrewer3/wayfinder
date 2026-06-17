import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/angle_display_format.dart';
import '../models/line_geometry.dart';
import 'line_distance.dart';
import 'line_path.dart';

const _pointMatchToleranceMeters = 2.0;

double normalizeBearing(double degrees) {
  final normalized = degrees % 360;
  return normalized < 0 ? normalized + 360 : normalized;
}

/// Signed angle from [referenceBearing] to [targetBearing], in degrees.
/// Positive is clockwise (starboard relative to reference heading).
double signedRelativeBearing({
  required double referenceBearing,
  required double targetBearing,
}) {
  var delta = normalizeBearing(targetBearing - referenceBearing);
  if (delta > 180) {
    delta -= 360;
  }
  return delta;
}

double absoluteBearingFromRelative({
  required double referenceBearing,
  required double relativeBearing,
}) {
  return normalizeBearing(referenceBearing + relativeBearing);
}

String formatTrueBearing(double degrees) {
  return '${normalizeBearing(degrees).round().toString().padLeft(3, '0')}°T';
}

String formatRelativeBearingLabel(double signedDegrees) {
  return formatRelativeAngle(signedDegrees, AngleDisplayFormat.decimal);
}

String formatRelativeAngle(
  double signedDegrees,
  AngleDisplayFormat format,
) {
  if (signedDegrees.round() == 0) {
    return switch (format) {
      AngleDisplayFormat.decimal => '0.0°',
      AngleDisplayFormat.degreesMinutesSeconds => '000°00\'00"',
    };
  }

  final direction = signedDegrees >= 0 ? 'R' : 'L';
  final absolute = signedDegrees.abs();

  return switch (format) {
    AngleDisplayFormat.decimal =>
      '${absolute.toStringAsFixed(1)}° $direction',
    AngleDisplayFormat.degreesMinutesSeconds =>
      '${_formatDegreesMinutesSeconds(absolute)} $direction',
  };
}

String _formatDegreesMinutesSeconds(double degrees) {
  var totalSeconds = (degrees * 3600).round();
  final d = totalSeconds ~/ 3600;
  totalSeconds -= d * 3600;
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${d.toString().padLeft(3, '0')}°'
      '${m.toString().padLeft(2, '0')}\''
      '${s.toString().padLeft(2, '0')}"';
}

LatLng pointAtTrueBearing({
  required LatLng anchor,
  required double bearingDegrees,
  required double distanceMeters,
}) {
  return lineGeodesicCalculator.offset(anchor, distanceMeters, bearingDegrees);
}

bool arePointsNear(LatLng a, LatLng b, {double toleranceMeters = _pointMatchToleranceMeters}) {
  return lineLengthMeters(a, b) <= toleranceMeters;
}

/// Course of the selected line from [anchor] toward the opposite endpoint.
double? referenceLineBearingAtAnchor({
  required MapZone zone,
  required LatLng anchor,
}) {
  final geometry = LineGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return null;
  }

  final start = geometry.start!;
  final end = geometry.end!;

  if (arePointsNear(anchor, start)) {
    return linePathBearingAtPoint(geometry, start) ??
        lineGeodesicCalculator.bearing(start, end);
  }
  if (arePointsNear(anchor, end)) {
    final forward = linePathBearingAtPoint(geometry, end) ??
        lineGeodesicCalculator.bearing(start, end);
    return normalizeBearing(forward + 180);
  }
  return null;
}

/// Screen-space angle (radians) from [anchor] toward geographic north.
double northScreenAngle({
  required LatLng anchor,
  required MapCamera camera,
  double sampleMeters = 500,
}) {
  final anchorScreen = camera.latLngToScreenOffset(anchor);
  final northScreen = camera.latLngToScreenOffset(
    lineGeodesicCalculator.offset(anchor, sampleMeters, 0),
  );
  final delta = northScreen - anchorScreen;
  return math.atan2(delta.dx, -delta.dy);
}

/// Converts a true bearing to a screen-space angle for map overlays.
double bearingToScreenAngle({
  required double trueBearing,
  required double northAngle,
}) {
  return northAngle + (trueBearing * math.pi / 180);
}
