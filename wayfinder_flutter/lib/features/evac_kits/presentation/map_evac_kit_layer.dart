import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/evac_kit_geometry.dart';

List<Polyline> buildSavedEvacKitPolylines(
  List<MapZone> zones, {
  UuidValue? selectedKitId,
}) {
  final polylines = <Polyline>[];
  for (final zone in zones) {
    if (zone.type != evacKitZoneType || !zone.visible) {
      continue;
    }
    final geometry = EvacKitGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final selected = zone.id == selectedKitId;
    final kitColor = parseMarkerColor(zone.color);

    for (final route in geometry.routes) {
      if (!route.isValid) {
        continue;
      }
      final isPrimary = route.id == geometry.primaryRouteId;
      final routeColor = route.color != null
          ? parseMarkerColor(route.color!)
          : (isPrimary
                ? kitColor
                : kitColor.withValues(alpha: selected ? 0.75 : 0.55));
      final pattern = route.borderPattern == 'dashed' || !isPrimary
          ? StrokePattern.dashed(segments: const [12, 8])
          : const StrokePattern.solid();
      polylines.add(
        Polyline(
          points: route.pathPoints,
          color: routeColor,
          strokeWidth: selected
              ? (isPrimary ? 5.5 : 4.0)
              : (isPrimary ? 4.0 : 3.0),
          pattern: pattern,
        ),
      );
    }
  }
  return polylines;
}

List<Marker> buildSavedEvacKitWaypointMarkers(
  List<MapZone> zones, {
  UuidValue? selectedKitId,
}) {
  final markers = <Marker>[];
  for (final zone in zones) {
    if (zone.type != evacKitZoneType || !zone.visible) {
      continue;
    }
    if (selectedKitId != null && zone.id != selectedKitId) {
      continue;
    }
    final geometry = EvacKitGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final color = parseMarkerColor(zone.color);
    final primary = geometry.primaryRoute;
    if (primary == null) {
      continue;
    }
    for (final (index, waypoint) in primary.waypoints.indexed) {
      markers.add(
        Marker(
          point: waypoint.point,
          width: 22,
          height: 22,
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
  return markers;
}

List<LatLng> evacKitDrawingPreviewPoints({
  required List<EvacWaypoint> waypoints,
  LatLng? previewPoint,
}) {
  final points = [for (final waypoint in waypoints) waypoint.point];
  if (previewPoint != null && points.isNotEmpty) {
    return [...points, previewPoint];
  }
  return points;
}
