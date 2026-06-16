import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../presentation/map_marker_icon.dart';

const markerHitRadiusPx = 20.0;

bool markerBoundsContainsScreenPoint({
  required Offset tapScreen,
  required Offset anchorScreen,
  double width = mapMarkerWidth,
  double height = mapMarkerHeight,
}) {
  return tapScreen.dx >= anchorScreen.dx - width / 2 &&
      tapScreen.dx <= anchorScreen.dx + width / 2 &&
      tapScreen.dy >= anchorScreen.dy - height &&
      tapScreen.dy <= anchorScreen.dy;
}

UuidValue? hitTestMarkerAtPoint({
  required LatLng point,
  required List<MapMarker> markers,
  required MapCamera camera,
}) {
  final tapScreen = camera.latLngToScreenOffset(point);
  UuidValue? hitId;
  var closestDistance = double.infinity;

  for (final marker in markers) {
    if (!marker.visible) {
      continue;
    }
    final anchorScreen = camera.latLngToScreenOffset(
      LatLng(marker.latitude, marker.longitude),
    );
    if (!markerBoundsContainsScreenPoint(
      tapScreen: tapScreen,
      anchorScreen: anchorScreen,
    )) {
      continue;
    }

    final distance = (tapScreen - anchorScreen).distance;
    if (distance < closestDistance) {
      closestDistance = distance;
      hitId = marker.id;
    }
  }

  return hitId;
}
