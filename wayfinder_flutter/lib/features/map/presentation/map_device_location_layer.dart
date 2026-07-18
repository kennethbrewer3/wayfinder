import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/device_location_provider.dart';

/// Accuracy circle, optional guide line to a target, and “you are here” blue dot.
List<Widget> buildDeviceLocationMapChildren(
  DeviceLocationState location, {
  LatLng? targetPoint,
}) {
  final point = location.position;
  if (point == null) {
    return const [];
  }

  const dotColor = Color(0xFF1E88E5);
  const dotBorder = Color(0xFFFFFFFF);
  const accuracyFill = Color(0x331E88E5);
  const accuracyStroke = Color(0x661E88E5);
  const guideColor = Color(0xCC1E88E5);

  final accuracy = location.accuracyMeters;
  return [
    if (accuracy != null && accuracy >= 5 && accuracy <= 5000)
      CircleLayer(
        circles: [
          CircleMarker(
            point: point,
            radius: accuracy,
            useRadiusInMeter: true,
            color: accuracyFill,
            borderColor: accuracyStroke,
            borderStrokeWidth: 1.5,
          ),
        ],
      ),
    if (targetPoint != null)
      PolylineLayer(
        polylines: [
          Polyline(
            points: [point, targetPoint],
            strokeWidth: 2.0,
            color: guideColor,
            pattern: StrokePattern.dashed(segments: const [10, 8]),
          ),
        ],
      ),
    MarkerLayer(
      markers: [
        Marker(
          point: point,
          width: 22,
          height: 22,
          alignment: Alignment.center,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                border: Border.fromBorderSide(
                  BorderSide(color: dotBorder, width: 2.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ];
}
