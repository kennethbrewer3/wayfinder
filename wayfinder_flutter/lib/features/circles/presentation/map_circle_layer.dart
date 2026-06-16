import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/utils/bearing_utils.dart';
import '../../lines/utils/line_distance.dart';
import '../../markers/models/marker_color.dart';
import '../models/circle_size_display.dart';
import '../models/circle_geometry.dart';

const _circlePolygonSteps = 72;

List<LatLng> circleBoundaryPoints({
  required LatLng center,
  required double radiusMeters,
  int steps = _circlePolygonSteps,
}) {
  final points = <LatLng>[];
  for (var i = 0; i <= steps; i++) {
    final bearing = i * 360.0 / steps;
    points.add(lineGeodesicCalculator.offset(center, radiusMeters, bearing));
  }
  return points;
}

LatLng circleRadiusLineEdge(CircleGeometry geometry) {
  return pointAtTrueBearing(
    anchor: geometry.center,
    bearingDegrees: geometry.radiusLineBearing,
    distanceMeters: geometry.radiusMeters,
  );
}

LatLng circleDiameterLineOppositeEdge(CircleGeometry geometry) {
  return pointAtTrueBearing(
    anchor: geometry.center,
    bearingDegrees: geometry.radiusLineBearing + 180,
    distanceMeters: geometry.radiusMeters,
  );
}

List<LatLng> circleSizeLinePoints(CircleGeometry geometry) {
  return switch (geometry.sizeDisplay) {
    CircleSizeDisplay.none => const [],
    CircleSizeDisplay.radius => [
        geometry.center,
        circleRadiusLineEdge(geometry),
      ],
    CircleSizeDisplay.diameter => [
        circleRadiusLineEdge(geometry),
        circleDiameterLineOppositeEdge(geometry),
      ],
  };
}

LatLng circleSizeLineMidpoint(CircleGeometry geometry) {
  final edge = circleRadiusLineEdge(geometry);
  return switch (geometry.sizeDisplay) {
    CircleSizeDisplay.diameter =>
      lineSegmentMidpoint(geometry.center, edge),
    CircleSizeDisplay.none ||
    CircleSizeDisplay.radius =>
      lineSegmentMidpoint(geometry.center, edge),
  };
}

List<Polygon> buildSavedCirclePolygons(List<MapZone> zones) {
  final polygons = <Polygon>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != circleZoneType) {
      continue;
    }
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    polygons.add(_polygonForCircle(zone: zone, geometry: geometry));
  }
  return polygons;
}

List<Polyline> buildSavedCircleRadiusLines(List<MapZone> zones) {
  final polylines = <Polyline>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != circleZoneType) {
      continue;
    }
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final line = _sizeLineForCircle(zone: zone, geometry: geometry);
    if (line != null) {
      polylines.add(line);
    }
  }
  return polylines;
}

List<Marker> buildSavedCircleCenterMarkers(List<MapZone> zones) {
  final markers = <Marker>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != circleZoneType) {
      continue;
    }
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    markers.add(_centerMarker(zone: zone, center: geometry.center));
  }
  return markers;
}

Polygon? buildPreviewCirclePolygon({
  required LatLng center,
  required double? radiusMeters,
  required Color borderColor,
  required Color fillColor,
}) {
  if (radiusMeters == null || radiusMeters < 1) {
    return null;
  }
  return Polygon(
    points: circleBoundaryPoints(center: center, radiusMeters: radiusMeters),
    color: fillColor,
    borderColor: borderColor,
    borderStrokeWidth: 2,
    pattern: const StrokePattern.solid(),
  );
}

Polyline? buildPreviewCircleRadiusLine({
  required LatLng center,
  required double? radiusMeters,
  required Color color,
  double bearingDegrees = defaultCircleRadiusLineBearing,
}) {
  if (radiusMeters == null || radiusMeters < 1) {
    return null;
  }
  final edge = pointAtTrueBearing(
    anchor: center,
    bearingDegrees: bearingDegrees,
    distanceMeters: radiusMeters,
  );
  return Polyline(
    points: [center, edge],
    color: color.withValues(alpha: 0.9),
    strokeWidth: 2,
    pattern: const StrokePattern.dotted(spacingFactor: 1.8),
  );
}

Marker buildPreviewCircleCenterMarker({
  required LatLng center,
  required Color color,
}) {
  return _centerMarker(
    zone: null,
    center: center,
    color: color,
  );
}

Polygon _polygonForCircle({
  required MapZone zone,
  required CircleGeometry geometry,
}) {
  return Polygon(
    points: circleBoundaryPoints(
      center: geometry.center,
      radiusMeters: geometry.radiusMeters,
    ),
    color: parseMarkerColor(zone.fillColor),
    borderColor: parseMarkerColor(zone.borderColor),
    borderStrokeWidth: 2.5,
    pattern: const StrokePattern.solid(),
  );
}

Polyline? _sizeLineForCircle({
  required MapZone zone,
  required CircleGeometry geometry,
}) {
  final points = circleSizeLinePoints(geometry);
  if (points.length < 2) {
    return null;
  }
  return Polyline(
    points: points,
    color: parseMarkerColor(zone.borderColor).withValues(alpha: 0.85),
    strokeWidth: 2,
    pattern: const StrokePattern.dotted(spacingFactor: 1.8),
  );
}

Marker _centerMarker({
  required MapZone? zone,
  required LatLng center,
  Color? color,
}) {
  final markerColor =
      color ?? parseMarkerColor(zone?.color ?? '#1B4965');
  return Marker(
    point: center,
    width: 18,
    height: 18,
    alignment: Alignment.center,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: markerColor,
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

MapZone? findCircleZoneById(List<MapZone> zones, UuidValue id) {
  for (final zone in zones) {
    if (zone.id == id && zone.type == circleZoneType) {
      return zone;
    }
  }
  return null;
}
