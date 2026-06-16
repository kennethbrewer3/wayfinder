import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/utils/line_distance.dart';
import '../models/circle_geometry.dart';

UuidValue? hitTestCircleAtPoint({
  required LatLng point,
  required List<MapZone> zones,
}) {
  UuidValue? closestId;
  var closestDistance = double.infinity;

  for (final zone in zones) {
    if (!zone.visible || zone.type != circleZoneType) {
      continue;
    }
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }

    final distance = lineLengthMeters(geometry.center, point);
    if (distance <= geometry.radiusMeters &&
        distance < closestDistance) {
      closestDistance = distance;
      closestId = zone.id;
    }
  }

  return closestId;
}
