import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../viewshed/presentation/map_viewshed_layer.dart';

List<OverlayImage> buildSlopeOverlayImages({
  required MemoryImage? image,
  required LatLngBounds? bounds,
  required double opacity,
}) {
  if (image == null || bounds == null) {
    return const [];
  }
  return [
    OverlayImage(
      bounds: bounds,
      imageProvider: image,
      opacity: opacity,
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
    ),
  ];
}

Polygon? buildSlopeRangeRingPolygon({
  required List<LatLng> points,
  required Color borderColor,
}) {
  return buildViewshedRangeRingPolygon(
    points: points,
    borderColor: borderColor,
  );
}

Marker buildSlopeCenterMarker({
  required LatLng center,
  required Color color,
}) {
  return buildViewshedObserverMarker(observer: center, color: color);
}
