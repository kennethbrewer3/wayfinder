import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/evac_kit_geometry.dart';

/// Returns true when [tap] is near any route polyline in the kit.
bool isNearEvacKit({
  required EvacKitGeometry geometry,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 16,
}) {
  for (final route in geometry.routes) {
    if (!route.isValid) {
      continue;
    }
    if (isNearPolyline(
      points: route.pathPoints,
      tap: tap,
      camera: camera,
      hitRadiusPx: hitRadiusPx,
    )) {
      return true;
    }
  }
  return false;
}

MapZone? findEvacKitAtPoint({
  required List<MapZone> zones,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 16,
}) {
  for (final zone in zones.reversed) {
    if (zone.type != evacKitZoneType || !zone.visible) {
      continue;
    }
    final geometry = EvacKitGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    if (isNearEvacKit(
      geometry: geometry,
      tap: tap,
      camera: camera,
      hitRadiusPx: hitRadiusPx,
    )) {
      return zone;
    }
  }
  return null;
}

bool isNearPolyline({
  required List<LatLng> points,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 16,
}) {
  if (points.length < 2) {
    return false;
  }
  final tapOffset = camera.latLngToScreenOffset(tap);
  final radiusSq = hitRadiusPx * hitRadiusPx;
  for (var i = 0; i < points.length - 1; i++) {
    final a = camera.latLngToScreenOffset(points[i]);
    final b = camera.latLngToScreenOffset(points[i + 1]);
    final distSq = _distanceToSegmentSq(
      tapOffset.dx,
      tapOffset.dy,
      a.dx,
      a.dy,
      b.dx,
      b.dy,
    );
    if (distSq <= radiusSq) {
      return true;
    }
  }
  return false;
}

double _distanceToSegmentSq(
  double px,
  double py,
  double ax,
  double ay,
  double bx,
  double by,
) {
  final abx = bx - ax;
  final aby = by - ay;
  final apx = px - ax;
  final apy = py - ay;
  final abLenSq = abx * abx + aby * aby;
  if (abLenSq <= 0) {
    return apx * apx + apy * apy;
  }
  var t = (apx * abx + apy * aby) / abLenSq;
  t = t.clamp(0.0, 1.0);
  final cx = ax + abx * t;
  final cy = ay + aby * t;
  final dx = px - cx;
  final dy = py - cy;
  return dx * dx + dy * dy;
}
