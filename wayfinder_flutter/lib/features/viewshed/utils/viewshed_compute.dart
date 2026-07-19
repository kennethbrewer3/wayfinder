import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../lines/utils/bearing_utils.dart';

class ViewshedRayResult {
  const ViewshedRayResult({
    required this.bearingDegrees,
    required this.farthestVisible,
    required this.visibleSampleCount,
  });

  final double bearingDegrees;
  final LatLng farthestVisible;
  final int visibleSampleCount;
}

/// Cast one radial viewshed ray from ordered distance samples.
///
/// A sample is visible when its elevation angle from the observer eye is
/// greater than or equal to every intervening sample (classic horizon /
/// RF terrain line-of-sight approximation — no Fresnel clearance).
ViewshedRayResult castViewshedRaySamples({
  required LatLng observer,
  required double observerEyeMeters,
  required double bearingDegrees,
  required List<LatLng> samplePoints,
  required List<double> distancesMeters,
  required List<double?> elevationsMeters,
  double targetHeightAglMeters = 0,
}) {
  assert(samplePoints.length == distancesMeters.length);
  assert(samplePoints.length == elevationsMeters.length);

  var maxAngle = double.negativeInfinity;
  var farthestVisible = observer;
  var visibleCount = 0;

  for (var i = 0; i < samplePoints.length; i++) {
    final ground = elevationsMeters[i];
    if (ground == null) {
      continue;
    }
    final distance = distancesMeters[i];
    if (distance <= 0) {
      continue;
    }

    final targetEye = ground + targetHeightAglMeters;
    final angle = math.atan2(targetEye - observerEyeMeters, distance);
    if (angle >= maxAngle) {
      farthestVisible = samplePoints[i];
      visibleCount += 1;
      maxAngle = angle;
    }
  }

  return ViewshedRayResult(
    bearingDegrees: bearingDegrees,
    farthestVisible: farthestVisible,
    visibleSampleCount: visibleCount,
  );
}

/// Convenience wrapper that builds samples with [pointAtTrueBearing] and a
/// synchronous height lookup (used by unit tests).
ViewshedRayResult castViewshedRay({
  required LatLng observer,
  required double observerEyeMeters,
  required double bearingDegrees,
  required double rangeMeters,
  required double stepMeters,
  required double? Function(LatLng point) heightAt,
  double targetHeightAglMeters = 0,
}) {
  final safeRange = rangeMeters.clamp(1.0, 50000.0);
  final safeStep = stepMeters.clamp(5.0, safeRange).toDouble();
  final samplePoints = <LatLng>[];
  final distances = <double>[];
  final elevations = <double?>[];

  for (
    var distance = safeStep;
    distance <= safeRange + 0.5;
    distance += safeStep
  ) {
    final clamped = distance > safeRange ? safeRange : distance;
    final sample = pointAtTrueBearing(
      anchor: observer,
      bearingDegrees: bearingDegrees,
      distanceMeters: clamped,
    );
    samplePoints.add(sample);
    distances.add(clamped);
    elevations.add(heightAt(sample));
  }

  return castViewshedRaySamples(
    observer: observer,
    observerEyeMeters: observerEyeMeters,
    bearingDegrees: bearingDegrees,
    samplePoints: samplePoints,
    distancesMeters: distances,
    elevationsMeters: elevations,
    targetHeightAglMeters: targetHeightAglMeters,
  );
}

/// Build a closed polygon from radial farthest-visible vertices.
List<LatLng> viewshedPolygonFromRays(List<ViewshedRayResult> rays) {
  if (rays.isEmpty) {
    return const [];
  }
  final points = [for (final ray in rays) ray.farthestVisible];
  if (points.length >= 2 && points.first != points.last) {
    points.add(points.first);
  }
  return points;
}

/// Suggested sampling step for [rangeMeters] (keeps ray cost bounded).
double viewshedStepMetersForRange(double rangeMeters) {
  final range = rangeMeters.clamp(100.0, 50000.0);
  return (range / 80).clamp(25.0, 150.0);
}

/// Default antenna height AGL for common RF / observation marker icons.
double defaultAntennaHeightForMarkerIcon(String? iconKey) {
  return switch (iconKey) {
    'radio_repeater' || 'cell_tower' || 'radio_station' || 'ham_shack' => 15,
    'mesh_network_node' => 8,
    'lookout' => 2,
    _ => 2,
  };
}
