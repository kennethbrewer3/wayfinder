import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/line_geometry.dart';
import '../utils/bearing_utils.dart';
import '../utils/line_arrows.dart';
import '../utils/line_distance.dart';

List<Polyline<UuidValue>> buildSavedLinePolylines(
  List<MapZone> zones, {
  UuidValue? selectedLineId,
}) {
  final polylines = <Polyline<UuidValue>>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != lineZoneType) {
      continue;
    }
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }
    final isSelected = selectedLineId == zone.id;
    polylines.add(
      _polylineForLine(
        points: geometry.points,
        color: parseMarkerColor(zone.color),
        borderPattern: zone.borderPattern,
        strokeWidth: isSelected ? 6 : 4,
        hitValue: zone.id,
      ),
    );
  }
  return polylines;
}

List<Marker> buildSavedLineArrowMarkers(List<MapZone> zones) {
  final markers = <Marker>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != lineZoneType) {
      continue;
    }
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid || !geometry.showArrows) {
      continue;
    }
    markers.addAll(
      buildDirectionArrowMarkers(
        start: geometry.start!,
        end: geometry.end!,
        color: parseMarkerColor(zone.color),
      ),
    );
  }
  return markers;
}

List<Marker> buildLineSnapPointMarkers({
  required MapZone zone,
}) {
  final geometry = LineGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return const [];
  }

  return [
    _snapPointMarker(point: geometry.start!),
    _snapPointMarker(point: geometry.end!),
  ];
}

Marker _snapPointMarker({required LatLng point}) {
  return Marker(
    point: point,
    width: 28,
    height: 28,
    alignment: Alignment.center,
    child: IgnorePointer(
      child: Tooltip(
        message: 'Click to plot bearing · drag to draw line',
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFF1B4965), width: 3),
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
              Icons.circle,
              size: 10,
              color: Color(0xFF1B4965),
            ),
          ),
        ),
      ),
    ),
  );
}

List<Marker> buildLineEndpointMarkers({
  required LatLng? start,
  required LatLng? end,
  required Color color,
}) {
  final markers = <Marker>[];
  for (final point in [start, end]) {
    if (point == null) {
      continue;
    }
    markers.add(
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
    );
  }
  return markers;
}

Polyline? buildPreviewLinePolyline({
  required LatLng start,
  required LatLng? previewEnd,
  required Color color,
}) {
  if (previewEnd == null) {
    return null;
  }
  return _polylineForLine(
    points: [start, previewEnd],
    color: color.withValues(alpha: 0.85),
    borderPattern: 'dashed',
    strokeWidth: 3,
  );
}

Polyline? buildReferenceCoursePolyline({
  required LatLng anchor,
  required double referenceBearing,
  required LatLng? previewEnd,
  required Color color,
}) {
  if (previewEnd == null) {
    return null;
  }
  final length = lineLengthMeters(anchor, previewEnd);
  if (length < 1) {
    return null;
  }
  final end = pointAtTrueBearing(
    anchor: anchor,
    bearingDegrees: referenceBearing,
    distanceMeters: length,
  );
  return _polylineForLine(
    points: [anchor, end],
    color: color.withValues(alpha: 0.55),
    borderPattern: 'dashed',
    strokeWidth: 2,
  );
}

Polyline<UuidValue> _polylineForLine({
  required List<LatLng> points,
  required Color color,
  required String borderPattern,
  double strokeWidth = 4,
  UuidValue? hitValue,
}) {
  return Polyline(
    points: points,
    color: color,
    strokeWidth: strokeWidth,
    hitValue: hitValue,
    pattern: borderPattern == 'dashed'
        ? StrokePattern.dashed(segments: [12, 8])
        : const StrokePattern.solid(),
  );
}

MapZone? findZoneById(List<MapZone> zones, UuidValue id) {
  for (final zone in zones) {
    if (zone.id == id) {
      return zone;
    }
  }
  return null;
}
