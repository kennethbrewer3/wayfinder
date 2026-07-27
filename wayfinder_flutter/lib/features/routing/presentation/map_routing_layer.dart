import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/routing_models.dart';

/// Color used for the computed routing-session overlay polyline.
const routingSessionLineColor = Color(0xFF1E88E5);

/// Builds the map polyline for the current computed route, or an empty list
/// when there is no active [RoutingResult].
List<Polyline> buildRoutingSessionPolylines(RoutingResult? result) {
  if (result == null || result.points.length < 2) {
    return const [];
  }
  return [
    Polyline(
      points: [
        for (final point in result.points) LatLng(point.lat, point.lon),
      ],
      color: routingSessionLineColor,
      strokeWidth: 5,
      pattern: const StrokePattern.solid(),
    ),
  ];
}
