import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../lines/models/line_arrow_density.dart';
import '../../lines/utils/line_distance.dart';
import 'track_trail_geometry.dart';

class ProjectedTrailPlacement {
  const ProjectedTrailPlacement({
    required this.point,
    required this.segmentStart,
    required this.segmentEnd,
  });

  final Offset point;
  final Offset segmentStart;
  final Offset segmentEnd;
}

class StyledTrailProjection {
  const StyledTrailProjection({
    required this.projected,
    required this.markers,
  });

  final List<Offset> projected;
  final List<TrailPathMarker> markers;
}

StyledTrailProjection? projectStyledTrail({
  required MapCamera camera,
  required Size mapSize,
  required List<LatLng> renderPoints,
  required LineArrowDensity density,
  bool includeMarkers = true,
}) {
  if (renderPoints.length < 2) {
    return null;
  }

  final totalMeters = lineLengthMetersForPoints(renderPoints);
  if (totalMeters < 1) {
    return null;
  }

  final projected = [
    for (final point in renderPoints) camera.latLngToScreenOffset(point),
  ];

  var totalPixels = 0.0;
  for (var index = 0; index < projected.length - 1; index++) {
    totalPixels += (projected[index + 1] - projected[index]).distance;
  }
  if (totalPixels < 1) {
    return null;
  }

  if (!includeMarkers) {
    return StyledTrailProjection(projected: projected, markers: const []);
  }

  final markerCount = density.arrowCountForPath(
    totalMeters: totalMeters,
    totalPixels: totalPixels,
  );
  final markers = <TrailPathMarker>[];

  for (var index = 1; index <= markerCount; index++) {
    final targetPixels = totalPixels * index / (markerCount + 1);
    final placement = pointOnProjectedTrailPath(projected, targetPixels);
    if (placement == null || !isOnMapViewport(placement.point, mapSize)) {
      continue;
    }

    markers.add(
      TrailPathMarker(
        center: placement.point,
        travelAngle: math.atan2(
          placement.segmentEnd.dy - placement.segmentStart.dy,
          placement.segmentEnd.dx - placement.segmentStart.dx,
        ),
        index: markers.length,
      ),
    );
  }

  return StyledTrailProjection(projected: projected, markers: markers);
}

ProjectedTrailPlacement? pointOnProjectedTrailPath(
  List<Offset> projected,
  double targetPixels,
) {
  var accumulated = 0.0;

  for (var index = 0; index < projected.length - 1; index++) {
    final start = projected[index];
    final end = projected[index + 1];
    final segmentLength = (end - start).distance;
    if (accumulated + segmentLength >= targetPixels) {
      if (segmentLength < 0.5) {
        return ProjectedTrailPlacement(
          point: start,
          segmentStart: start,
          segmentEnd: end,
        );
      }

      final t = ((targetPixels - accumulated) / segmentLength).clamp(0.0, 1.0);
      return ProjectedTrailPlacement(
        point: Offset.lerp(start, end, t)!,
        segmentStart: start,
        segmentEnd: end,
      );
    }
    accumulated += segmentLength;
  }

  return null;
}

bool isOnMapViewport(Offset point, Size mapSize) {
  return point.dx >= 0 &&
      point.dy >= 0 &&
      point.dx <= mapSize.width &&
      point.dy <= mapSize.height;
}
