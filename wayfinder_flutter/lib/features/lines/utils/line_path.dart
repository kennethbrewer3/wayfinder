import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/line_geometry.dart';
import 'bearing_utils.dart';
import 'line_distance.dart';

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
  final extended = [controlPoints.first, ...controlPoints, controlPoints.last];
  final segments = <LineRenderSegment>[];

  for (var index = 0; index < controlPoints.length - 1; index++) {
    final p0 = extended[index];
    final p1 = extended[index + 1];
    final p2 = extended[index + 2];
    final p3 = extended[index + 3];
    var previous = p1;

    for (var sample = 1; sample <= samplesPerSpan; sample++) {
      final t = sample / samplesPerSpan;
      final next = _catmullRomPoint(p0, p1, p2, p3, t);
      segments.add(
        LineRenderSegment(
          start: previous,
          end: next,
          controlSegmentIndex: index,
        ),
      );
      previous = next;
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

    for (var sample = 0; sample < samplesPerSpan; sample++) {
      final t = sample / samplesPerSpan;
      result.add(_catmullRomPoint(p0, p1, p2, p3, t));
    }
  }
  result.add(points.last);
  return result;
}

LatLng _catmullRomPoint(LatLng p0, LatLng p1, LatLng p2, LatLng p3, double t) {
  final t2 = t * t;
  final t3 = t2 * t;

  double blend(double v0, double v1, double v2, double v3) {
    return 0.5 *
        ((2 * v1) +
            (-v0 + v2) * t +
            (2 * v0 - 5 * v1 + 4 * v2 - v3) * t2 +
            (-v0 + 3 * v1 - 3 * v2 + v3) * t3);
  }

  return LatLng(
    blend(p0.latitude, p1.latitude, p2.latitude, p3.latitude),
    blend(p0.longitude, p1.longitude, p2.longitude, p3.longitude),
  );
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

  final t = (((tap.latitude - startLat) * deltaLat) +
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

  final t = ((toPoint.dx * segment.dx + toPoint.dy * segment.dy) / lengthSquared)
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
  final updatedPoints = [...geometry.points]..insert(insertIndex, insertionPoint);

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
    pathMode:
        updatedPoints.length > 2 ? geometry.pathMode : LinePathMode.straight,
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
