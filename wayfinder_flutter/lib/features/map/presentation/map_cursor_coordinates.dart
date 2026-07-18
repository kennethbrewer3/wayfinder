import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../utils/mgrs_utils.dart';

String formatMapCoordinates(LatLng location) {
  return '${location.latitude.toStringAsFixed(6)}, '
      '${location.longitude.toStringAsFixed(6)}';
}

/// Cursor readout: MGRS while the grid is on, otherwise lat/lng.
String formatMapCursorReadout(
  LatLng location, {
  required bool showMgrs,
  required double zoom,
}) {
  if (!showMgrs) {
    return formatMapCoordinates(location);
  }
  try {
    return formatMgrs(
      latLngToMgrs(location, accuracy: mgrsAccuracyForZoom(zoom)),
    );
  } catch (_) {
    // Polar / invalid for MGRS — fall back to geographic coordinates.
    return formatMapCoordinates(location);
  }
}

class MapCursorCoordinates extends StatelessWidget {
  const MapCursorCoordinates({
    super.key,
    required this.location,
    this.showMgrs = false,
    this.zoom = 10,
  });

  final LatLng location;
  final bool showMgrs;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          formatMapCursorReadout(
            location,
            showMgrs: showMgrs,
            zoom: zoom,
          ),
          style: theme.textTheme.labelLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
