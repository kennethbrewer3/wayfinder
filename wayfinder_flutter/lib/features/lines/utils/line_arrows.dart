import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'line_distance.dart';

List<Marker> buildDirectionArrowMarkers({
  required LatLng start,
  required LatLng end,
  required Color color,
  int count = 3,
}) {
  return buildDirectionArrowMarkersForPath(
    renderPoints: [start, end],
    color: color,
    count: count,
  );
}

List<Marker> buildDirectionArrowMarkersForPath({
  required List<LatLng> renderPoints,
  required Color color,
  int count = 3,
}) {
  if (renderPoints.length < 2) {
    return const [];
  }

  final totalMeters = lineLengthMetersForPoints(renderPoints);
  if (totalMeters < 1) {
    return const [];
  }

  final arrowCount = totalMeters < 50 ? 1 : count;
  final markers = <Marker>[];

  for (var index = 1; index <= arrowCount; index++) {
    final target = totalMeters * index / (arrowCount + 1);
    final placement = _pointAndBearingAtDistance(renderPoints, target);
    if (placement == null) {
      continue;
    }

    final rotation = (placement.bearing - 90) * math.pi / 180;
    markers.add(
      Marker(
        point: placement.point,
        width: 24,
        height: 24,
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: rotation,
          child: Icon(
            Icons.arrow_forward,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  return markers;
}

class _PathPlacement {
  const _PathPlacement({required this.point, required this.bearing});

  final LatLng point;
  final double bearing;
}

_PathPlacement? _pointAndBearingAtDistance(
  List<LatLng> renderPoints,
  double targetMeters,
) {
  var accumulated = 0.0;

  for (var index = 0; index < renderPoints.length - 1; index++) {
    final start = renderPoints[index];
    final end = renderPoints[index + 1];
    final segmentLength = lineLengthMeters(start, end);
    if (accumulated + segmentLength >= targetMeters) {
      final remaining = targetMeters - accumulated;
      if (segmentLength < 0.5) {
        return _PathPlacement(
          point: start,
          bearing: lineGeodesicCalculator.bearing(start, end),
        );
      }
      final bearing = lineGeodesicCalculator.bearing(start, end);
      return _PathPlacement(
        point: lineGeodesicCalculator.offset(start, remaining, bearing),
        bearing: bearing,
      );
    }
    accumulated += segmentLength;
  }

  return null;
}
