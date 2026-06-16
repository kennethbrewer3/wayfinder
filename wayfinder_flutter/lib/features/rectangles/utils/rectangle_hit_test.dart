import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/rectangle_geometry.dart';
import '../utils/rectangle_bounds.dart';

bool _pointInPolygon(Offset point, List<Offset> polygon) {
  if (polygon.length < 3) {
    return false;
  }
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].dx;
    final yi = polygon[i].dy;
    final xj = polygon[j].dx;
    final yj = polygon[j].dy;
    if (((yi > point.dy) != (yj > point.dy)) &&
        (point.dx < (xj - xi) * (point.dy - yi) / (yj - yi) + xi)) {
      inside = !inside;
    }
  }
  return inside;
}

UuidValue? hitTestRectangleAtPoint({
  required LatLng point,
  required List<MapZone> zones,
  required MapCamera camera,
}) {
  final tapScreen = camera.latLngToScreenOffset(point);
  UuidValue? hitId;
  var smallestArea = double.infinity;

  for (final zone in zones) {
    if (!zone.visible || zone.type != rectangleZoneType) {
      continue;
    }
    final geometry = RectangleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }

    final polygon = rectanglePolygonPoints(geometry.bounds)
        .map(camera.latLngToScreenOffset)
        .toList();
    if (!_pointInPolygon(tapScreen, polygon)) {
      continue;
    }

    final bounds = geometry.bounds;
    final area = (bounds.north - bounds.south).abs() *
        (bounds.east - bounds.west).abs();
    if (area < smallestArea) {
      smallestArea = area;
      hitId = zone.id;
    }
  }

  return hitId;
}
