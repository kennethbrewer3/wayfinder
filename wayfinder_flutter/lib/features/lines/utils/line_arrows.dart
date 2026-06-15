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
  final totalMeters = lineLengthMeters(start, end);
  if (totalMeters < 1) {
    return const [];
  }

  final bearing = lineGeodesicCalculator.bearing(start, end);
  final rotation = (bearing - 90) * math.pi / 180;
  final arrowCount = totalMeters < 50 ? 1 : count;
  final markers = <Marker>[];

  for (var index = 1; index <= arrowCount; index++) {
    final fraction = index / (arrowCount + 1);
    final point = lineGeodesicCalculator.offset(
      start,
      totalMeters * fraction,
      bearing,
    );
    markers.add(
      Marker(
        point: point,
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
