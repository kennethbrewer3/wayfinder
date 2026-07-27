import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_distance.dart';

/// Default corridor width before the follow UI treats the user as off-route.
const routeFollowOffRouteThresholdMeters = 35.0;

/// How far ahead along the path to aim the “next” cue.
const routeFollowLookaheadMeters = 40.0;

/// Progress of a device position along a route polyline (render points).
class RouteFollowProgress {
  const RouteFollowProgress({
    required this.totalMeters,
    required this.traveledMeters,
    required this.remainingMeters,
    required this.offRouteMeters,
    required this.snapPoint,
    required this.nextPoint,
    required this.bearingToNextDegrees,
    required this.completed,
  });

  final double totalMeters;
  final double traveledMeters;
  final double remainingMeters;
  final double offRouteMeters;
  final LatLng snapPoint;
  final LatLng nextPoint;
  final double? bearingToNextDegrees;
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
  final next = completed
      ? path.last
      : pointAlongPolyline(path, traveled + lookaheadMeters) ?? path.last;
  final bearing = completed
      ? null
      : lineGeodesicCalculator.bearing(position, next);

  return RouteFollowProgress(
    totalMeters: total,
    traveledMeters: traveled,
    remainingMeters: remaining,
    offRouteMeters: bestOffRoute.isFinite ? bestOffRoute : 0,
    snapPoint: bestSnap,
    nextPoint: next,
    bearingToNextDegrees: bearing,
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
