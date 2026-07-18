import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../elevation/providers/elevation_providers.dart';
import '../../elevation/utils/elevation_format.dart';
import '../../lines/providers/measurement_units_provider.dart';
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
  String? elevationLabel,
}) {
  final base = () {
    if (!showMgrs) {
      return formatMapCoordinates(location);
    }
    try {
      return formatMgrs(
        latLngToMgrs(location, accuracy: mgrsAccuracyForZoom(zoom)),
      );
    } catch (_) {
      return formatMapCoordinates(location);
    }
  }();
  if (elevationLabel == null || elevationLabel.isEmpty) {
    return base;
  }
  return '$base · $elevationLabel';
}

/// Map pointer readout that stays visible while moving, then fades out.
class MapCursorCoordinates extends ConsumerStatefulWidget {
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
  static const elevationDebounce = Duration(milliseconds: 180);

  @override
  ConsumerState<MapCursorCoordinates> createState() =>
      _MapCursorCoordinatesState();
}

class _MapCursorCoordinatesState
    extends ConsumerState<MapCursorCoordinates> {
  Timer? _idleTimer;
  Timer? _elevationTimer;
  var _opacity = 1.0;
  String? _elevationLabel;

  @override
  void initState() {
    super.initState();
    _reveal();
    _scheduleElevationSample();
  }

  @override
  void didUpdateWidget(covariant MapCursorCoordinates oldWidget) {
    super.didUpdateWidget(oldWidget);
    final moved =
        oldWidget.location.latitude != widget.location.latitude ||
        oldWidget.location.longitude != widget.location.longitude;
    if (moved) {
      _reveal();
      _scheduleElevationSample();
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _elevationTimer?.cancel();
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

  void _scheduleElevationSample() {
    _elevationTimer?.cancel();
    _elevationTimer = Timer(MapCursorCoordinates.elevationDebounce, () async {
      if (!mounted) {
        return;
      }
      final sampler = await ref.read(elevationSamplerProvider.future);
      if (!mounted || !sampler.hasDem) {
        if (mounted && _elevationLabel != null) {
          setState(() => _elevationLabel = null);
        }
        return;
      }
      final meters = await sampler.elevationAt(
        widget.location,
        preferredZoom: widget.zoom.round(),
      );
      if (!mounted) {
        return;
      }
      final units = ref.read(measurementUnitsProvider);
      setState(() {
        _elevationLabel = meters == null
            ? null
            : formatElevationMeters(meters, units);
      });
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
                elevationLabel: _elevationLabel,
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
