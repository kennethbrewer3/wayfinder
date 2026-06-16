import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/rectangle_geometry.dart';
import '../utils/rectangle_bounds.dart';

List<Polygon> buildSavedRectanglePolygons(List<MapZone> zones) {
  final polygons = <Polygon>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != rectangleZoneType) {
      continue;
    }
    final geometry = RectangleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    polygons.add(_polygonForRectangle(zone: zone, geometry: geometry));
  }
  return polygons;
}

List<Marker> buildSavedRectangleCenterMarkers(List<MapZone> zones) {
  final markers = <Marker>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != rectangleZoneType) {
      continue;
    }
    final geometry = RectangleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final center = geometry.centerMarkerPoint;
    if (center == null) {
      continue;
    }
    markers.add(
      _centerMarker(
        color: parseMarkerColor(zone.color),
        center: center,
      ),
    );
  }
  return markers;
}

Polygon? buildPreviewRectanglePolygon({
  required RectangleBounds bounds,
  required Color borderColor,
  required Color fillColor,
}) {
  if (!bounds.isValid) {
    return null;
  }
  return Polygon(
    points: rectanglePolygonPoints(bounds),
    color: fillColor,
    borderColor: borderColor,
    borderStrokeWidth: 2,
    pattern: const StrokePattern.solid(),
  );
}

Marker? buildPreviewRectangleCenterMarker({
  required LatLng? center,
  required Color color,
}) {
  if (center == null) {
    return null;
  }
  return _centerMarker(color: color, center: center);
}

Polygon _polygonForRectangle({
  required MapZone zone,
  required RectangleGeometry geometry,
}) {
  return Polygon(
    points: rectanglePolygonPoints(geometry.bounds),
    color: parseMarkerColor(zone.fillColor),
    borderColor: parseMarkerColor(zone.borderColor),
    borderStrokeWidth: 2.5,
    pattern: const StrokePattern.solid(),
  );
}

Marker _centerMarker({
  required Color color,
  required LatLng center,
}) {
  return Marker(
    point: center,
    width: 18,
    height: 18,
    alignment: Alignment.center,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    ),
  );
}

RectangleBounds? previewRectangleBounds(RectangleDrawingPreview preview) {
  if (preview.anchor == null || preview.previewPoint == null) {
    return null;
  }
  return switch (preview.mode) {
    RectangleCreationMode.centerExtent =>
      boundsFromCenterExtent(preview.anchor!, preview.previewPoint!),
    RectangleCreationMode.corners =>
      boundsFromCorners(preview.anchor!, preview.previewPoint!),
  };
}

class RectangleDrawingPreview {
  const RectangleDrawingPreview({
    required this.mode,
    required this.anchor,
    required this.previewPoint,
  });

  final RectangleCreationMode mode;
  final LatLng? anchor;
  final LatLng? previewPoint;
}
