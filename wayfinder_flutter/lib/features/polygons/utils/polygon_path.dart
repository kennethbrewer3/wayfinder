import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_path.dart';
import '../models/polygon_geometry.dart';

int? hitTestPolygonVertexIndex({
  required PolygonGeometry geometry,
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

PolygonGeometry? movePolygonVertex({
  required PolygonGeometry geometry,
  required int vertexIndex,
  required LatLng point,
}) {
  if (vertexIndex < 0 || vertexIndex >= geometry.points.length) {
    return null;
  }
  final updated = [...geometry.points];
  updated[vertexIndex] = point;
  return geometry.copyWith(points: updated);
}

class _PolygonEdgeHit {
  const _PolygonEdgeHit({
    required this.edgeIndex,
    required this.distancePx,
    required this.projected,
  });

  final int edgeIndex;
  final double distancePx;
  final LatLng projected;
}

bool isNearPolygonEdge({
  required PolygonGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 22,
}) {
  return _closestPolygonEdge(
        geometry: geometry,
        tap: tap,
        camera: camera,
        hitRadiusPx: hitRadiusPx,
      ) !=
      null;
}

_PolygonEdgeHit? _closestPolygonEdge({
  required PolygonGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 22,
}) {
  final points = geometry.points;
  if (points.length < 3) {
    return null;
  }
  final tapScreen = camera.latLngToScreenOffset(tap);
  _PolygonEdgeHit? closest;

  for (var i = 0; i < points.length; i++) {
    final start = points[i];
    final end = points[(i + 1) % points.length];
    final distance = distanceToSegmentPx(
      tapScreen,
      camera.latLngToScreenOffset(start),
      camera.latLngToScreenOffset(end),
    );
    if (distance > hitRadiusPx) {
      continue;
    }
    if (closest == null || distance < closest.distancePx) {
      closest = _PolygonEdgeHit(
        edgeIndex: i,
        distancePx: distance,
        projected: projectPointOnSegment(start, end, tap),
      );
    }
  }
  return closest;
}

PolygonGeometry? insertPolygonVertex({
  required PolygonGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
}) {
  final hit = _closestPolygonEdge(
    geometry: geometry,
    tap: tap,
    camera: camera,
  );
  if (hit == null) {
    return null;
  }
  final updated = [...geometry.points]..insert(hit.edgeIndex + 1, hit.projected);
  return geometry.copyWith(points: updated);
}

PolygonGeometry? removePolygonVertex({
  required PolygonGeometry geometry,
  required int vertexIndex,
}) {
  if (vertexIndex < 0 ||
      vertexIndex >= geometry.points.length ||
      geometry.points.length <= 3) {
    return null;
  }
  final updated = [...geometry.points]..removeAt(vertexIndex);
  return geometry.copyWith(points: updated);
}
