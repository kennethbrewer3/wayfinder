import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_distance.dart';

/// Default corridor width before the follow UI treats the user as off-route.
const routeFollowOffRouteThresholdMeters = 35.0;

/// How far ahead along the path to aim the guide line when no turn is near.
const routeFollowLookaheadMeters = 40.0;

/// Absolute path-heading change that counts as a left/right turn.
const routeFollowTurnThresholdDegrees = 30.0;

/// Spacing used when scanning the densified polyline for heading changes.
const routeFollowTurnScanStepMeters = 8.0;

/// Next action the follow HUD should describe.
enum RouteFollowManeuverKind {
  continueStraight,
  turnLeft,
  turnRight,
  arrive,
}

/// Progress of a device position along a route polyline (render points).
class RouteFollowProgress {
  const RouteFollowProgress({
    required this.totalMeters,
    required this.traveledMeters,
    required this.remainingMeters,
    required this.offRouteMeters,
    required this.snapPoint,
    required this.nextPoint,
    required this.metersToNextManeuver,
    required this.nextManeuver,
    required this.turnDegrees,
    required this.completed,
  });

  final double totalMeters;
  final double traveledMeters;
  final double remainingMeters;
  final double offRouteMeters;
  final LatLng snapPoint;
  final LatLng nextPoint;
  final double metersToNextManeuver;
  final RouteFollowManeuverKind nextManeuver;

  /// Absolute heading change for [nextManeuver] turns; 0 when not a turn.
  final double turnDegrees;
  final bool completed;

  bool get isOffRoute =>
      !completed && offRouteMeters > routeFollowOffRouteThresholdMeters;
}

LatLng? pointAlongPolyline(List<LatLng> path, double distanceMeters) {
  if (path.isEmpty) {
    return null;
  }
  if (distanceMeters <= 0) {
    return path.first;
  }

  var remaining = distanceMeters;
  for (var i = 0; i < path.length - 1; i++) {
    final start = path[i];
    final end = path[i + 1];
    final segmentLength = lineLengthMeters(start, end);
    if (remaining <= segmentLength) {
      if (segmentLength < 0.5) {
        return start;
      }
      final bearing = lineGeodesicCalculator.bearing(start, end);
      return lineGeodesicCalculator.offset(start, remaining, bearing);
    }
    remaining -= segmentLength;
  }
  return path.last;
}

/// Path heading (degrees clockwise from true north) at [distanceMeters].
double? bearingAlongPolyline(List<LatLng> path, double distanceMeters) {
  if (path.length < 2) {
    return null;
  }

  var remaining = distanceMeters.clamp(0.0, double.infinity);
  for (var i = 0; i < path.length - 1; i++) {
    final start = path[i];
    final end = path[i + 1];
    final segmentLength = lineLengthMeters(start, end);
    if (segmentLength < 0.5) {
      continue;
    }
    if (remaining <= segmentLength) {
      return lineGeodesicCalculator.bearing(start, end);
    }
    remaining -= segmentLength;
  }

  final start = path[path.length - 2];
  final end = path.last;
  if (lineLengthMeters(start, end) < 0.5) {
    return null;
  }
  return lineGeodesicCalculator.bearing(start, end);
}

/// Signed heading change in [-180, 180]. Positive = turn right.
double signedBearingDeltaDegrees(double fromDegrees, double toDegrees) {
  var delta = (toDegrees - fromDegrees) % 360.0;
  if (delta > 180) {
    delta -= 360;
  } else if (delta < -180) {
    delta += 360;
  }
  return delta;
}

/// Finds the next notable turn (or continue/arrive) ahead of [traveledMeters].
({
  RouteFollowManeuverKind kind,
  double distanceMeters,
  double turnDegrees,
})
findNextRouteFollowManeuver({
  required List<LatLng> path,
  required double traveledMeters,
  required double totalMeters,
  double turnThresholdDegrees = routeFollowTurnThresholdDegrees,
  double scanStepMeters = routeFollowTurnScanStepMeters,
}) {
  final remaining = (totalMeters - traveledMeters).clamp(0.0, totalMeters);
  if (remaining <= 5) {
    return (
      kind: RouteFollowManeuverKind.arrive,
      distanceMeters: remaining,
      turnDegrees: 0,
    );
  }

  final legBearing = bearingAlongPolyline(path, traveledMeters);
  if (legBearing == null) {
    return (
      kind: RouteFollowManeuverKind.continueStraight,
      distanceMeters: remaining,
      turnDegrees: 0,
    );
  }

  // Skip a little noise immediately underfoot, then scan for heading change.
  var scan = traveledMeters + math.max(scanStepMeters, 12.0);
  while (scan < totalMeters - 2) {
    final aheadBearing = bearingAlongPolyline(path, scan);
    if (aheadBearing != null) {
      final delta = signedBearingDeltaDegrees(legBearing, aheadBearing);
      if (delta.abs() >= turnThresholdDegrees) {
        final distance = (scan - traveledMeters).clamp(0.0, remaining);
        final peakDelta = _peakTurnDeltaDegrees(
          path: path,
          legBearing: legBearing,
          fromDistanceMeters: scan,
          totalMeters: totalMeters,
          initialDelta: delta,
          scanStepMeters: scanStepMeters,
        );
        return (
          kind: peakDelta > 0
              ? RouteFollowManeuverKind.turnRight
              : RouteFollowManeuverKind.turnLeft,
          distanceMeters: distance,
          turnDegrees: peakDelta.abs(),
        );
      }
    }
    scan += scanStepMeters;
  }

  return (
    kind: RouteFollowManeuverKind.continueStraight,
    distanceMeters: remaining,
    turnDegrees: 0,
  );
}

/// Continues past the first threshold crossing to measure the full turn size.
double _peakTurnDeltaDegrees({
  required List<LatLng> path,
  required double legBearing,
  required double fromDistanceMeters,
  required double totalMeters,
  required double initialDelta,
  required double scanStepMeters,
}) {
  var peakDelta = initialDelta;
  var scan = fromDistanceMeters + scanStepMeters;
  while (scan < totalMeters - 2) {
    final aheadBearing = bearingAlongPolyline(path, scan);
    if (aheadBearing == null) {
      break;
    }
    final delta = signedBearingDeltaDegrees(legBearing, aheadBearing);
    // Stop if the bend reverses relative to the initial turn direction.
    if (delta.sign != 0 &&
        initialDelta.sign != 0 &&
        delta.sign != initialDelta.sign) {
      break;
    }
    if (delta.abs() > peakDelta.abs()) {
      peakDelta = delta;
    } else if (delta.abs() < peakDelta.abs() - 8) {
      // Heading is settling onto a new course past the apex.
      break;
    }
    scan += scanStepMeters;
  }
  return peakDelta;
}

/// Snaps [position] onto [path] and computes remaining distance / off-route.
///
/// [path] should be the rendered polyline (smooth samples or control points).
RouteFollowProgress? computeRouteFollowProgress({
  required List<LatLng> path,
  required LatLng position,
  double lookaheadMeters = routeFollowLookaheadMeters,
}) {
  if (path.length < 2) {
    return null;
  }

  final total = lineLengthMetersForPoints(path);
  if (total <= 0) {
    return null;
  }

  var bestOffRoute = double.infinity;
  var bestTraveled = 0.0;
  var bestSnap = path.first;
  var traveledBeforeSegment = 0.0;

  for (var i = 0; i < path.length - 1; i++) {
    final start = path[i];
    final end = path[i + 1];
    final segmentLength = lineLengthMeters(start, end);
    final projected = _projectOntoSegment(start, end, position);
    final off = lineLengthMeters(position, projected.point);
    if (off < bestOffRoute) {
      bestOffRoute = off;
      bestTraveled = traveledBeforeSegment + projected.distanceAlongSegment;
      bestSnap = projected.point;
    }
    traveledBeforeSegment += segmentLength;
  }

  final traveled = bestTraveled.clamp(0.0, total);
  final remaining = (total - traveled).clamp(0.0, total);
  final completed = remaining <= 5;
  final maneuver = completed
      ? (
          kind: RouteFollowManeuverKind.arrive,
          distanceMeters: remaining,
          turnDegrees: 0.0,
        )
      : findNextRouteFollowManeuver(
          path: path,
          traveledMeters: traveled,
          totalMeters: total,
        );
  final next = completed
      ? path.last
      : pointAlongPolyline(
              path,
              traveled +
                  (maneuver.kind == RouteFollowManeuverKind.continueStraight
                      ? math.min(lookaheadMeters, remaining)
                      : maneuver.distanceMeters),
            ) ??
            path.last;

  return RouteFollowProgress(
    totalMeters: total,
    traveledMeters: traveled,
    remainingMeters: remaining,
    offRouteMeters: bestOffRoute.isFinite ? bestOffRoute : 0,
    snapPoint: bestSnap,
    nextPoint: next,
    metersToNextManeuver: maneuver.distanceMeters,
    nextManeuver: maneuver.kind,
    turnDegrees: maneuver.turnDegrees,
    completed: completed,
  );
}

class _SegmentProjection {
  const _SegmentProjection({
    required this.point,
    required this.distanceAlongSegment,
  });

  final LatLng point;
  final double distanceAlongSegment;
}

_SegmentProjection _projectOntoSegment(
  LatLng start,
  LatLng end,
  LatLng position,
) {
  final segmentLength = lineLengthMeters(start, end);
  if (segmentLength < 0.5) {
    return _SegmentProjection(point: start, distanceAlongSegment: 0);
  }

  // Local ENU-ish projection in meters around [start].
  final startLatRad = start.latitude * math.pi / 180;
  final metersPerDegLat = 111320.0;
  final metersPerDegLng = 111320.0 * math.cos(startLatRad);

  final endE = (end.longitude - start.longitude) * metersPerDegLng;
  final endN = (end.latitude - start.latitude) * metersPerDegLat;
  final posE = (position.longitude - start.longitude) * metersPerDegLng;
  final posN = (position.latitude - start.latitude) * metersPerDegLat;

  final denom = endE * endE + endN * endN;
  if (denom <= 0) {
    return _SegmentProjection(point: start, distanceAlongSegment: 0);
  }
  final t = ((posE * endE + posN * endN) / denom).clamp(0.0, 1.0);
  final point = LatLng(
    start.latitude + (end.latitude - start.latitude) * t,
    start.longitude + (end.longitude - start.longitude) * t,
  );
  return _SegmentProjection(
    point: point,
    distanceAlongSegment: segmentLength * t,
  );
}
