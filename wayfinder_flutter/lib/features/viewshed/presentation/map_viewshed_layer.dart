import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Polygon? buildViewshedVisiblePolygon({
  required List<LatLng> points,
  required Color borderColor,
  required Color fillColor,
}) {
  if (points.length < 3) {
    return null;
  }
  return Polygon(
    points: points,
    color: fillColor,
    borderColor: borderColor,
    borderStrokeWidth: 2,
  );
}

Polygon? buildViewshedRangeRingPolygon({
  required List<LatLng> points,
  required Color borderColor,
}) {
  if (points.length < 3) {
    return null;
  }
  return Polygon(
    points: points,
    color: Colors.transparent,
    borderColor: borderColor,
    borderStrokeWidth: 1.5,
    pattern: const StrokePattern.dotted(spacingFactor: 1.8),
  );
}

Marker buildViewshedObserverMarker({
  required LatLng observer,
  required Color color,
}) {
  return Marker(
    point: observer,
    width: 28,
    height: 28,
    child: Icon(Icons.visibility, color: color, size: 26),
  );
}
