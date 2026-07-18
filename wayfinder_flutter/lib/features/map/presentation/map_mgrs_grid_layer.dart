import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/mgrs_utils.dart';

/// Draws an MGRS grid that refreshes as the map pans and zooms.
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
    _debounce = Timer(const Duration(milliseconds: 50), _rebuild);
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
      ),
      zoom: camera.zoom,
    );
    setState(() => _geometry = geometry);
  }

  @override
  Widget build(BuildContext context) {
    // Keep this widget under FlutterMap so child layers resolve MapCamera.
    MapCamera.of(context);

    if (_geometry.lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.primary.withValues(alpha: 0.45);
    final labelColor = theme.colorScheme.onSurface.withValues(alpha: 0.75);
    final labelBackground = theme.colorScheme.surface.withValues(alpha: 0.7);

    return Stack(
      children: [
        PolylineLayer(
          polylines: [
            for (final line in _geometry.lines)
              Polyline(
                points: line,
                strokeWidth: _geometry.accuracy <= 1 ? 1.5 : 1.0,
                color: lineColor,
              ),
          ],
        ),
        if (_geometry.labels.isNotEmpty)
          MarkerLayer(
            markers: [
              for (final label in _geometry.labels)
                Marker(
                  point: label.point,
                  width: 120,
                  height: 24,
                  alignment: Alignment.center,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: labelBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          label.text,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: labelColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
