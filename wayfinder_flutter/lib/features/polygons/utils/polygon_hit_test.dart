import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/polygon_geometry.dart';

bool pointInPolygonScreen(Offset point, List<Offset> polygon) {
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

/// Rough area proxy for preferring the smallest AOI under the tap.
double polygonAreaProxy(List<LatLng> points) {
  if (points.length < 3) {
    return double.infinity;
  }
  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;
  for (final point in points.skip(1)) {
    minLat = point.latitude < minLat ? point.latitude : minLat;
    maxLat = point.latitude > maxLat ? point.latitude : maxLat;
    minLng = point.longitude < minLng ? point.longitude : minLng;
    maxLng = point.longitude > maxLng ? point.longitude : maxLng;
  }
  return (maxLat - minLat).abs() * (maxLng - minLng).abs();
}

UuidValue? hitTestPolygonAtPoint({
  required LatLng point,
  required List<MapZone> zones,
  required MapCamera camera,
}) {
  final tapScreen = camera.latLngToScreenOffset(point);
  UuidValue? hitId;
  var smallestArea = double.infinity;

  for (final zone in zones) {
    if (!zone.visible || zone.type != polygonZoneType) {
      continue;
    }
    final geometry = PolygonGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }

    final polygon = geometry.points
        .map(camera.latLngToScreenOffset)
        .toList(growable: false);
    if (!pointInPolygonScreen(tapScreen, polygon)) {
      continue;
    }

    final area = polygonAreaProxy(geometry.points);
    if (area < smallestArea) {
      smallestArea = area;
      hitId = zone.id;
    }
  }

  return hitId;
}
