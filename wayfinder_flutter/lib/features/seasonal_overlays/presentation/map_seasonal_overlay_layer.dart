import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../providers/seasonal_overlays_provider.dart';

List<Polygon> buildSeasonalOverlayPolygons(
  List<SeasonalOverlay> overlays, {
  required bool showInactive,
  UuidValue? selectedOverlayId,
  PolygonGeometry? geometryOverride,
  DateTime? on,
}) {
  final polygons = <Polygon>[];
  for (final overlay in overlays) {
    if (!shouldRenderSeasonalOverlay(
      overlay: overlay,
      showInactive: showInactive,
      on: on,
    )) {
      continue;
    }
    final geometry =
        (overlay.id == selectedOverlayId && geometryOverride != null)
        ? geometryOverride
        : PolygonGeometry.fromJsonString(overlay.geometryJson);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final selected = overlay.id == selectedOverlayId;
    final active = isSeasonalOverlayCurrentlyActive(overlay, on: on);
    final fill = parseMarkerColor(overlay.fillColor);
    final border = parseMarkerColor(overlay.borderColor);
    polygons.add(
      Polygon(
        points: geometry.points,
        color: active ? fill : fill.withValues(alpha: fill.a * 0.35),
        borderColor: active
            ? border
            : border.withValues(alpha: border.a * 0.45),
        borderStrokeWidth: selected ? 4 : 2.5,
        pattern: active
            ? const StrokePattern.solid()
            : StrokePattern.dashed(segments: const [10, 6]),
      ),
    );
  }
  return polygons;
}

List<Marker> buildSeasonalOverlayNameMarkers(
  List<SeasonalOverlay> overlays, {
  required bool showInactive,
  DateTime? on,
}) {
  final markers = <Marker>[];
  for (final overlay in overlays) {
    if (!shouldRenderSeasonalOverlay(
      overlay: overlay,
      showInactive: showInactive,
      on: on,
    )) {
      continue;
    }
    final geometry = PolygonGeometry.fromJsonString(overlay.geometryJson);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final active = isSeasonalOverlayCurrentlyActive(overlay, on: on);
    final color = parseMarkerColor(overlay.borderColor);
    markers.add(
      Marker(
        point: geometry.labelPoint,
        width: 120,
        height: 28,
        alignment: Alignment.center,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: active ? 0.55 : 0.35),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.9)),
            ),
            child: Center(
              child: Text(
                overlay.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: active ? 1 : 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  return markers;
}
