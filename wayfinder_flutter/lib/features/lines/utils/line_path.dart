import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/line_geometry.dart';
import 'bearing_utils.dart';
import 'line_distance.dart';

/// Chordal Catmull-Rom (α = 1) hugs the control polyline more tightly than
/// uniform Catmull-Rom, so smooth routes stay closer to the shortest path.
const _catmullRomAlpha = 1.0;

class LineRenderSegment {
  const LineRenderSegment({
    required this.start,
    required this.end,
    required this.controlSegmentIndex,
  });

  final LatLng start;
  final LatLng end;
  final int controlSegmentIndex;
}

List<LatLng> buildLineRenderPoints(
  LineGeometry geometry, {
  int samplesPerSpan = 12,
}) {
  final points = geometry.points;
  if (points.length < 2) {
    return const [];
  }
  if (geometry.pathMode == LinePathMode.straight || points.length == 2) {
    return List<LatLng>.from(points);
  }
  return _catmullRomSpline(points, samplesPerSpan);
}

List<LineRenderSegment> lineRenderSegments(LineGeometry geometry) {
  final controlPoints = geometry.points;
  if (controlPoints.length < 2) {
    return const [];
  }

  if (geometry.pathMode == LinePathMode.straight || controlPoints.length == 2) {
    return [
      for (var index = 0; index < controlPoints.length - 1; index++)
        LineRenderSegment(
          start: controlPoints[index],
          end: controlPoints[index + 1],
          controlSegmentIndex: index,
        ),
    ];
  }

  const samplesPerSpan = 12;
  final samples = _catmullRomSpline(controlPoints, samplesPerSpan);
  final segments = <LineRenderSegment>[];
  if (samples.length < 2) {
    return const [];
  }

  // Map each rendered sample back onto the control segment that produced it.
  for (var index = 0; index < controlPoints.length - 1; index++) {
    final startSample = index * samplesPerSpan;
    final endSample = startSample + samplesPerSpan;
    for (var sample = startSample; sample < endSample; sample++) {
      if (sample + 1 >= samples.length) {
        break;
      }
      segments.add(
        LineRenderSegment(
          start: samples[sample],
          end: samples[sample + 1],
          controlSegmentIndex: index,
        ),
      );
    }
  }

  return segments;
}

List<LatLng> _catmullRomSpline(List<LatLng> points, int samplesPerSpan) {
  final result = <LatLng>[];
  final extended = [points.first, ...points, points.last];

  for (var index = 0; index < points.length - 1; index++) {
    final p0 = extended[index];
    final p1 = extended[index + 1];
    final p2 = extended[index + 2];
    final p3 = extended[index + 3];
    final t0 = 0.0;
    final t1 = _catmullRomKnot(t0, p0, p1);
    final t2 = _catmullRomKnot(t1, p1, p2);
    final t3 = _catmullRomKnot(t2, p2, p3);

    for (var sample = 0; sample < samplesPerSpan; sample++) {
      final t = t1 + (t2 - t1) * (sample / samplesPerSpan);
      result.add(_catmullRomPoint(p0, p1, p2, p3, t0, t1, t2, t3, t));
    }
  }
  result.add(points.last);
  return result;
}

double _catmullRomKnot(double ti, LatLng pi, LatLng pj) {
  final distance = lineLengthMeters(pi, pj);
  // Avoid zero-length knots when consecutive points coincide.
  return ti + math.pow(math.max(distance, 1e-3), _catmullRomAlpha).toDouble();
}

LatLng _catmullRomPoint(
  LatLng p0,
  LatLng p1,
  LatLng p2,
  LatLng p3,
  double t0,
  double t1,
  double t2,
  double t3,
  double t,
) {
  LatLng lerp(LatLng a, LatLng b, double ta, double tb) {
    if ((tb - ta).abs() < 1e-12) {
      return a;
    }
    final u = (t - ta) / (tb - ta);
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * u,
      a.longitude + (b.longitude - a.longitude) * u,
    );
  }

  final a1 = lerp(p0, p1, t0, t1);
  final a2 = lerp(p1, p2, t1, t2);
  final a3 = lerp(p2, p3, t2, t3);
  final b1 = lerp(a1, a2, t0, t2);
  final b2 = lerp(a2, a3, t1, t3);
  return lerp(b1, b2, t1, t2);
}

double linePathLengthMeters(LineGeometry geometry) {
  final renderPoints = buildLineRenderPoints(geometry);
  if (renderPoints.length < 2) {
    return 0;
  }

  var total = 0.0;
  for (var index = 0; index < renderPoints.length - 1; index++) {
    total += lineLengthMeters(renderPoints[index], renderPoints[index + 1]);
  }
  return total;
}

LatLng linePathMidpoint(LineGeometry geometry) {
  final renderPoints = buildLineRenderPoints(geometry);
  if (renderPoints.isEmpty) {
    return const LatLng(0, 0);
  }
  if (renderPoints.length == 1) {
    return renderPoints.first;
  }

  final target = linePathLengthMeters(geometry) / 2;
  var accumulated = 0.0;

  for (var index = 0; index < renderPoints.length - 1; index++) {
    final start = renderPoints[index];
    final end = renderPoints[index + 1];
    final segmentLength = lineLengthMeters(start, end);
    if (accumulated + segmentLength >= target) {
      final remaining = target - accumulated;
      if (segmentLength < 0.5) {
        return start;
      }
      final bearing = lineGeodesicCalculator.bearing(start, end);
      return lineGeodesicCalculator.offset(start, remaining, bearing);
    }
    accumulated += segmentLength;
  }

  return renderPoints.last;
}

double? linePathBearingAtPoint(LineGeometry geometry, LatLng anchor) {
  final renderPoints = buildLineRenderPoints(geometry);
  if (renderPoints.length < 2) {
    return null;
  }

  for (var index = 0; index < renderPoints.length - 1; index++) {
    final start = renderPoints[index];
    final end = renderPoints[index + 1];
    if (arePointsNear(anchor, start) || arePointsNear(anchor, end)) {
      return lineGeodesicCalculator.bearing(start, end);
    }
  }

  return null;
}

LineRenderSegment? closestLineRenderSegment({
  required LineGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 14,
}) {
  final tapScreen = camera.latLngToScreenOffset(tap);
  LineRenderSegment? closest;
  var closestDistance = hitRadiusPx;

  for (final segment in lineRenderSegments(geometry)) {
    final distance = distanceToSegmentPx(
      tapScreen,
      camera.latLngToScreenOffset(segment.start),
      camera.latLngToScreenOffset(segment.end),
    );
    if (distance <= closestDistance) {
      closestDistance = distance;
      closest = segment;
    }
  }

  return closest;
}

LatLng projectPointOnSegment(LatLng start, LatLng end, LatLng tap) {
  final startLat = start.latitude;
  final startLng = start.longitude;
  final deltaLat = end.latitude - startLat;
  final deltaLng = end.longitude - startLng;
  final denominator = deltaLat * deltaLat + deltaLng * deltaLng;
  if (denominator == 0) {
    return start;
  }

  final t =
      (((tap.latitude - startLat) * deltaLat) +
          ((tap.longitude - startLng) * deltaLng)) /
      denominator;
  final clamped = t.clamp(0.0, 1.0);
  return LatLng(
    startLat + deltaLat * clamped,
    startLng + deltaLng * clamped,
  );
}

double distanceToSegmentPx(Offset point, Offset start, Offset end) {
  final segment = end - start;
  final toPoint = point - start;
  final lengthSquared = segment.distanceSquared;
  if (lengthSquared == 0) {
    return toPoint.distance;
  }

  final t =
      ((toPoint.dx * segment.dx + toPoint.dy * segment.dy) / lengthSquared)
          .clamp(0.0, 1.0);
  final projection = Offset(
    start.dx + segment.dx * t,
    start.dy + segment.dy * t,
  );
  return (point - projection).distance;
}

LineGeometry? insertLineControlPoint({
  required LineGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
}) {
  final segment = closestLineRenderSegment(
    geometry: geometry,
    tap: tap,
    camera: camera,
  );
  if (segment == null) {
    return null;
  }

  final insertionPoint = projectPointOnSegment(
    segment.start,
    segment.end,
    tap,
  );
  final insertIndex = segment.controlSegmentIndex + 1;
  final updatedPoints = [...geometry.points]
    ..insert(insertIndex, insertionPoint);

  return geometry.copyWith(
    points: updatedPoints,
    pathMode: LinePathMode.smooth,
  );
}

LineGeometry? removeLineControlPoint({
  required LineGeometry geometry,
  required int controlPointIndex,
}) {
  if (controlPointIndex <= 0 ||
      controlPointIndex >= geometry.points.length - 1) {
    return null;
  }

  final updatedPoints = [...geometry.points]..removeAt(controlPointIndex);
  return geometry.copyWith(
    points: updatedPoints,
    pathMode: updatedPoints.length > 2
        ? geometry.pathMode
        : LinePathMode.straight,
  );
}

LineGeometry? moveLineControlPoint({
  required LineGeometry geometry,
  required int controlPointIndex,
  required LatLng point,
}) {
  if (controlPointIndex < 0 || controlPointIndex >= geometry.points.length) {
    return null;
  }

  final updatedPoints = [...geometry.points];
  updatedPoints[controlPointIndex] = point;
  return geometry.copyWith(points: updatedPoints);
}

int? hitTestLineControlPointIndex({
  required LineGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 18,
}) {
  final tapScreen = camera.latLngToScreenOffset(tap);
  int? closestIndex;
  var closestDistance = hitRadiusPx;

  for (var index = 0; index < geometry.points.length; index++) {
    final pointScreen = camera.latLngToScreenOffset(geometry.points[index]);
    final distance = (tapScreen - pointScreen).distance;
    if (distance <= closestDistance) {
      closestDistance = distance;
      closestIndex = index;
    }
  }

  return closestIndex;
}

bool isInteriorLineControlPoint(LineGeometry geometry, int index) {
  return index > 0 && index < geometry.points.length - 1;
}

extension LineGeometryPath on LineGeometry {
  List<LatLng> get renderPoints => buildLineRenderPoints(this);

  double get pathLengthMeters => linePathLengthMeters(this);
}

LatLng? lineZoneCenter(MapZone zone) {
  final geometry = LineGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return null;
  }
  return linePathMidpoint(geometry);
}
