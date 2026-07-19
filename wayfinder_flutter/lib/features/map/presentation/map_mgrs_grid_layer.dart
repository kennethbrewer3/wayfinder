import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/mgrs_utils.dart';

/// MGRS grid lines as a direct [FlutterMap] child (must not be nested in a Stack).
class MapMgrsGridLayer extends StatefulWidget {
  const MapMgrsGridLayer({
    super.key,
    required this.mapController,
  });

  final MapController mapController;

  @override
  State<MapMgrsGridLayer> createState() => _MapMgrsGridLayerState();
}

class _MapMgrsGridLayerState extends State<MapMgrsGridLayer> {
  StreamSubscription<MapEvent>? _subscription;
  MgrsGridGeometry _geometry = MgrsGridGeometry.empty;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subscription = widget.mapController.mapEventStream.listen((_) {
      _scheduleRebuild();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild());
  }

  @override
  void didUpdateWidget(MapMgrsGridLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _subscription?.cancel();
      _subscription = widget.mapController.mapEventStream.listen((_) {
        _scheduleRebuild();
      });
      _rebuild();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _scheduleRebuild() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 40), _rebuild);
  }

  void _rebuild() {
    if (!mounted) {
      return;
    }
    final camera = widget.mapController.camera;
    final visible = camera.visibleBounds;
    final geometry = buildMgrsGrid(
      bounds: MgrsLatLngBounds(
        south: visible.south,
        west: visible.west,
        north: visible.north,
        east: visible.east,
        longitudeCenter: visible.longitudeCenter,
        longitudeWidth: visible.longitudeWidth,
      ),
      zoom: camera.zoom,
    );
    setState(() => _geometry = geometry);
  }

  @override
  Widget build(BuildContext context) {
    MapCamera.of(context);

    if (_geometry.lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final lineColor = theme.brightness == Brightness.dark
        ? const Color(0xE6FFB74D)
        : const Color(0xE6C62828);

    return PolylineLayer(
      polylines: [
        for (final line in _geometry.lines)
          Polyline(
            points: line,
            strokeWidth: _geometry.accuracy <= 1 ? 1.75 : 1.25,
            color: lineColor,
          ),
      ],
    );
  }
}

/// Sparse MGRS grid labels; kept as a separate map child so lines render correctly.
class MapMgrsGridLabelsLayer extends StatefulWidget {
  const MapMgrsGridLabelsLayer({
    super.key,
    required this.mapController,
  });

  final MapController mapController;

  @override
  State<MapMgrsGridLabelsLayer> createState() => _MapMgrsGridLabelsLayerState();
}

class _MapMgrsGridLabelsLayerState extends State<MapMgrsGridLabelsLayer> {
  StreamSubscription<MapEvent>? _subscription;
  MgrsGridGeometry _geometry = MgrsGridGeometry.empty;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subscription = widget.mapController.mapEventStream.listen((_) {
      _scheduleRebuild();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild());
  }

  @override
  void didUpdateWidget(MapMgrsGridLabelsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _subscription?.cancel();
      _subscription = widget.mapController.mapEventStream.listen((_) {
        _scheduleRebuild();
      });
      _rebuild();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _scheduleRebuild() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 40), _rebuild);
  }

  void _rebuild() {
    if (!mounted) {
      return;
    }
    final camera = widget.mapController.camera;
    final visible = camera.visibleBounds;
    final geometry = buildMgrsGrid(
      bounds: MgrsLatLngBounds(
        south: visible.south,
        west: visible.west,
        north: visible.north,
        east: visible.east,
        longitudeCenter: visible.longitudeCenter,
        longitudeWidth: visible.longitudeWidth,
      ),
      zoom: camera.zoom,
    );
    setState(() => _geometry = geometry);
  }

  @override
  Widget build(BuildContext context) {
    MapCamera.of(context);

    if (_geometry.labels.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final labelColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFFE0B2)
        : const Color(0xFFB71C1C);
    final labelBackground = theme.colorScheme.surface.withValues(alpha: 0.82);

    return MarkerLayer(
      markers: [
        for (final label in _geometry.labels)
          Marker(
            point: label.point,
            width: (label.text.length * 7.0 + 16).clamp(36.0, 140.0),
            height: 20,
            alignment: Alignment.center,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: labelBackground,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: labelColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Text(
                    label.text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
