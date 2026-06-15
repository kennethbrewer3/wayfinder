import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/line_geometry.dart';
import 'line_distance.dart';

const lineSnapRadiusPx = 18.0;
const lineHitRadiusPx = 14.0;

List<LatLng> collectLineEndpointSnapCandidates(List<MapZone> zones) {
  final points = <LatLng>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != lineZoneType) {
      continue;
    }
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    points.add(geometry.start!);
    points.add(geometry.end!);
  }
  return points;
}

LatLng snapLinePoint({
  required LatLng point,
  required MapCamera camera,
  required List<LatLng> candidates,
  double radiusPx = lineSnapRadiusPx,
}) {
  if (candidates.isEmpty) {
    return point;
  }

  final pointScreen = camera.latLngToScreenOffset(point);
  LatLng? closest;
  var closestDistance = radiusPx;

  for (final candidate in candidates) {
    final candidateScreen = camera.latLngToScreenOffset(candidate);
    final distance = (pointScreen - candidateScreen).distance;
    if (distance <= closestDistance) {
      closestDistance = distance;
      closest = candidate;
    }
  }

  return closest ?? point;
}

bool areLinePointsTooClose(LatLng start, LatLng end, {double minMeters = 1}) {
  return lineLengthMeters(start, end) < minMeters;
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

UuidValue? hitTestLineAtPoint({
  required LatLng point,
  required List<MapZone> zones,
  required MapCamera camera,
  double hitRadiusPx = lineHitRadiusPx,
}) {
  final tapScreen = camera.latLngToScreenOffset(point);
  UuidValue? closestId;
  var closestDistance = hitRadiusPx;

  for (final zone in zones) {
    if (!zone.visible || zone.type != lineZoneType) {
      continue;
    }
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }

    final distance = distanceToSegmentPx(
      tapScreen,
      camera.latLngToScreenOffset(geometry.start!),
      camera.latLngToScreenOffset(geometry.end!),
    );
    if (distance <= closestDistance) {
      closestDistance = distance;
      closestId = zone.id;
    }
  }

  return closestId;
}
