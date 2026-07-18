import 'dart:async';

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

/// Map pointer readout that stays visible while moving, then fades out.
class MapCursorCoordinates extends StatefulWidget {
  const MapCursorCoordinates({
    super.key,
    required this.location,
    this.showMgrs = false,
    this.zoom = 10,
  });

  final LatLng location;
  final bool showMgrs;
  final double zoom;

  static const idleBeforeFade = Duration(milliseconds: 900);
  static const fadeDuration = Duration(milliseconds: 450);

  @override
  State<MapCursorCoordinates> createState() => _MapCursorCoordinatesState();
}

class _MapCursorCoordinatesState extends State<MapCursorCoordinates> {
  Timer? _idleTimer;
  var _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(covariant MapCursorCoordinates oldWidget) {
    super.didUpdateWidget(oldWidget);
    final moved =
        oldWidget.location.latitude != widget.location.latitude ||
        oldWidget.location.longitude != widget.location.longitude;
    if (moved) {
      _reveal();
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _reveal() {
    _idleTimer?.cancel();
    if (_opacity != 1.0) {
      setState(() => _opacity = 1.0);
    }
    _idleTimer = Timer(MapCursorCoordinates.idleBeforeFade, () {
      if (!mounted) {
        return;
      }
      setState(() => _opacity = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: MapCursorCoordinates.fadeDuration,
        curve: Curves.easeOut,
        child: Material(
          elevation: _opacity > 0 ? 2 : 0,
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surface.withValues(alpha: 0.92),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              formatMapCursorReadout(
                widget.location,
                showMgrs: widget.showMgrs,
                zoom: widget.zoom,
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
