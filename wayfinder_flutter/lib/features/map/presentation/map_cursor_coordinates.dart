import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

String formatMapCoordinates(LatLng location) {
  return '${location.latitude.toStringAsFixed(6)}, '
      '${location.longitude.toStringAsFixed(6)}';
}

class MapCursorCoordinates extends StatelessWidget {
  const MapCursorCoordinates({
    super.key,
    required this.location,
  });

  final LatLng location;

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
          formatMapCoordinates(location),
          style: theme.textTheme.labelLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
