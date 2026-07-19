import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/polygon_geometry.dart';

List<Polygon> buildSavedPolygonPolygons(List<MapZone> zones) {
  final polygons = <Polygon>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != polygonZoneType) {
      continue;
    }
    final geometry = PolygonGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    polygons.add(
      Polygon(
        points: geometry.points,
        color: parseMarkerColor(zone.fillColor),
        borderColor: parseMarkerColor(zone.borderColor),
        borderStrokeWidth: 2.5,
        pattern: const StrokePattern.solid(),
      ),
    );
  }
  return polygons;
}

Polygon? buildPreviewPolygon({
  required List<LatLng> points,
  LatLng? previewPoint,
  required Color borderColor,
  required Color fillColor,
}) {
  final ring = <LatLng>[
    ...points,
    ?previewPoint,
  ];
  if (ring.length < 2) {
    return null;
  }
  // Need 3+ points for a filled polygon; with 2 draw a thin closed strip
  // by duplicating so flutter_map still paints a border path.
  if (ring.length < 3) {
    return Polygon(
      points: [...ring, ring.first],
      color: fillColor.withValues(alpha: 0.05),
      borderColor: borderColor,
      borderStrokeWidth: 2,
      pattern: StrokePattern.dashed(segments: const [8, 6]),
    );
  }
  return Polygon(
    points: ring,
    color: fillColor,
    borderColor: borderColor,
    borderStrokeWidth: 2,
    pattern: StrokePattern.dashed(segments: const [10, 6]),
  );
}

List<Marker> buildPreviewPolygonVertexMarkers({
  required List<LatLng> points,
  required Color color,
}) {
  return [
    for (final point in points)
      Marker(
        point: point,
        width: 14,
        height: 14,
        alignment: Alignment.center,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
  ];
}
