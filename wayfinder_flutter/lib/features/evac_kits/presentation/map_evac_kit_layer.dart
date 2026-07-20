import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/evac_kit_geometry.dart';
import '../utils/evac_kit_path.dart';

List<Polyline> buildSavedEvacKitPolylines(
  List<MapZone> zones, {
  UuidValue? selectedKitId,
  EvacKitGeometry? geometryOverride,
  String? editingRouteId,
  LatLng? extendPreviewPoint,
}) {
  final polylines = <Polyline>[];
  for (final zone in zones) {
    if (zone.type != evacKitZoneType || !zone.visible) {
      continue;
    }
    final geometry = zone.id == selectedKitId && geometryOverride != null
        ? geometryOverride
        : EvacKitGeometry.fromZone(zone);
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
      final isEditing =
          selected && editingRouteId != null && route.id == editingRouteId;
      final routeColor = route.color != null
          ? parseMarkerColor(route.color!)
          : (isPrimary
                ? kitColor
                : kitColor.withValues(alpha: selected ? 0.75 : 0.55));
      final pattern = route.borderPattern == 'dashed' || !isPrimary
          ? StrokePattern.dashed(segments: const [12, 8])
          : const StrokePattern.solid();
      final points = isEditing && extendPreviewPoint != null
          ? buildEvacRouteRenderPoints(
              route.copyWith(
                waypoints: [
                  ...route.waypoints,
                  EvacWaypoint(
                    kind: EvacWaypointKind.point,
                    point: extendPreviewPoint,
                  ),
                ],
              ),
            )
          : buildEvacRouteRenderPoints(route);
      polylines.add(
        Polyline(
          points: points,
          color: routeColor,
          strokeWidth: selected
              ? (isEditing || isPrimary ? 5.5 : 4.0)
              : (isPrimary ? 4.0 : 3.0),
          pattern: isEditing
              ? StrokePattern.dashed(segments: const [10, 6])
              : pattern,
        ),
      );
    }
  }
  return polylines;
}

List<Marker> buildSavedEvacKitWaypointMarkers(
  List<MapZone> zones, {
  UuidValue? selectedKitId,
  EvacKitGeometry? geometryOverride,
  String? editingRouteId,
  int? selectedWaypointIndex,
}) {
  final markers = <Marker>[];
  for (final zone in zones) {
    if (zone.type != evacKitZoneType || !zone.visible) {
      continue;
    }
    if (selectedKitId != null && zone.id != selectedKitId) {
      continue;
    }
    final geometry = zone.id == selectedKitId && geometryOverride != null
        ? geometryOverride
        : EvacKitGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final kitColor = parseMarkerColor(zone.color);

    // When editing one route, show only that route's handles. Otherwise show
    // every route so alternates are numbered too (not just primary).
    final routesToShow = <EvacRoute>[];
    if (editingRouteId != null) {
      for (final route in geometry.routes) {
        if (route.id == editingRouteId) {
          routesToShow.add(route);
          break;
        }
      }
    } else {
      routesToShow.addAll(geometry.routes.where((route) => route.isValid));
    }

    for (final route in routesToShow) {
      final isPrimary = route.id == geometry.primaryRouteId;
      final isEditing = editingRouteId != null && route.id == editingRouteId;
      final routeColor = route.color != null
          ? parseMarkerColor(route.color!)
          : (isPrimary ? kitColor : kitColor.withValues(alpha: 0.85));
      for (final (index, waypoint) in route.waypoints.indexed) {
        final selected = isEditing && selectedWaypointIndex == index;
        if (waypoint.kind.isControlPoint) {
          if (!isEditing) {
            continue;
          }
          markers.add(
            _evacControlPointMarker(
              point: waypoint.point,
              color: routeColor,
              selected: selected,
            ),
          );
          continue;
        }

        final number = evacRouteWaypointNumber(route, index) ?? (index + 1);
        final size = selected ? 28.0 : (isPrimary || isEditing ? 22.0 : 18.0);
        markers.add(
          Marker(
            point: waypoint.point,
            width: size,
            height: size,
            alignment: Alignment.center,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: routeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Colors.amber
                      : (isPrimary || isEditing
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85)),
                  width: selected ? 3 : (isPrimary || isEditing ? 2 : 1.5),
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: selected ? 12 : (isPrimary || isEditing ? 11 : 9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }
  return markers;
}

Marker _evacControlPointMarker({
  required LatLng point,
  required Color color,
  required bool selected,
}) {
  final size = selected ? 26.0 : 24.0;
  return Marker(
    point: point,
    width: size,
    height: size,
    alignment: Alignment.center,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: selected ? Colors.amber : Colors.white,
          width: selected ? 3 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.adjust,
          size: 12,
          color: Colors.white,
        ),
      ),
    ),
  );
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
