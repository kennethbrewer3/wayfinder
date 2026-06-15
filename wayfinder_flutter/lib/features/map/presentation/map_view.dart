import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/presentation/line_distance_labels.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../lines/providers/line_drawing_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/selected_line_provider.dart';
import '../../lines/utils/line_arrows.dart';
import '../../lines/utils/line_snap.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../search/providers/search_coordinate_marker_provider.dart';
import '../../settings/models/pmtiles_map_layer.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../models/map_viewport.dart';
import 'map_cursor_coordinates.dart';
import 'map_radial_menu.dart';

class MapView extends ConsumerWidget {
  const MapView({
    super.key,
    required this.viewport,
    required this.onViewportChanged,
  });

  final MapViewport viewport;
  final ValueChanged<MapViewport> onViewportChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markersAsync = ref.watch(markersProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final searchCoordinateMarker = ref.watch(searchCoordinateMarkerProvider);
    final mapLayerAsync = ref.watch(activePmtilesMapLayerProvider);

    return mapLayerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        AppLogger.logMap.error(
          '🗺️ Map layer failed to load',
          error: error,
          stackTrace: stackTrace,
        );
        return _PlaceholderLayer(
          errorMessage: error.toString(),
          onOpenSettings: () {
            AppLogger.logNav.info(
              '🧭 Navigating to settings from map error placeholder',
            );
            context.push('/settings');
          },
        );
      },
      data: (mapLayer) {
        if (mapLayer == null) {
          AppLogger.logMap.warn('🗺️ No PMTiles map layer — showing placeholder');
        }
        return _MapCanvas(
          viewport: viewport,
          onViewportChanged: onViewportChanged,
          mapLayer: mapLayer,
          markersAsync: markersAsync,
          zonesAsync: zonesAsync,
          searchCoordinateMarker: searchCoordinateMarker,
          onCreateMarker: (point) => _createMarker(context, ref, point),
          onSaveSearchCoordinateMarker: (marker) =>
              _saveSearchCoordinateMarker(context, ref, marker),
          onOpenSettings: () {
            AppLogger.logNav.info('🧭 Navigating to settings from map placeholder');
            context.push('/settings');
          },
        );
      },
    );
  }

  Future<void> _createMarker(
    BuildContext context,
    WidgetRef ref,
    LatLng point,
  ) {
    return createMarkerAtPoint(
      context: context,
      ref: ref,
      point: point,
    );
  }

  Future<void> _saveSearchCoordinateMarker(
    BuildContext context,
    WidgetRef ref,
    SearchCoordinateMarker marker,
  ) async {
    final saved = await createMarkerAtPoint(
      context: context,
      ref: ref,
      point: marker.location,
      defaultName: marker.label,
      dialogTitle: 'Save searched coordinates',
      confirmLabel: 'Save marker',
    );
    if (saved) {
      ref.read(searchCoordinateMarkerProvider.notifier).clear();
    }
  }
}

class _MapCanvas extends ConsumerStatefulWidget {
  const _MapCanvas({
    required this.viewport,
    required this.onViewportChanged,
    required this.mapLayer,
    required this.markersAsync,
    required this.zonesAsync,
    required this.searchCoordinateMarker,
    required this.onCreateMarker,
    required this.onSaveSearchCoordinateMarker,
    required this.onOpenSettings,
  });

  final MapViewport viewport;
  final ValueChanged<MapViewport> onViewportChanged;
  final PmtilesMapLayerConfig? mapLayer;
  final AsyncValue<List<MapMarker>> markersAsync;
  final AsyncValue<List<MapZone>> zonesAsync;
  final SearchCoordinateMarker? searchCoordinateMarker;
  final Future<void> Function(LatLng point) onCreateMarker;
  final Future<void> Function(SearchCoordinateMarker marker)
      onSaveSearchCoordinateMarker;
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends ConsumerState<_MapCanvas> {
  static const _longPressDuration = Duration(milliseconds: 450);
  static const _longPressMoveTolerance = 12.0;
  static const _cursorLabelOffset = Offset(16, 16);

  late final MapController _mapController;
  final GlobalKey _mapHostKey = GlobalKey();

  LatLng? _cursorLocation;
  Offset? _cursorScreenPosition;
  Offset? _radialMenuCenter;
  LatLng? _radialMenuPoint;

  Timer? _longPressTimer;
  Offset? _pendingLongPressLocal;
  LatLng? _pendingLongPressPoint;
  Offset? _tapDownLocal;
  bool _longPressTriggered = false;
  bool _lineDrawingPressActive = false;
  LatLng? _pendingSnapStart;
  bool _clearedSelectionOnPointerDown = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewport.center != widget.viewport.center ||
        oldWidget.viewport.zoom != widget.viewport.zoom) {
      _mapController.move(widget.viewport.center, widget.viewport.zoom);
    }
  }

  RenderBox? get _mapRenderBox =>
      _mapHostKey.currentContext?.findRenderObject() as RenderBox?;

  void _clearCursor() {
    if (_cursorLocation == null && _cursorScreenPosition == null) {
      return;
    }
    setState(() {
      _cursorLocation = null;
      _cursorScreenPosition = null;
    });
  }

  void _updateCursor(Offset globalPosition, LatLng point) {
    final box = _mapRenderBox;
    if (box == null || !box.hasSize) {
      return;
    }

    final local = box.globalToLocal(globalPosition);
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx > box.size.width ||
        local.dy > box.size.height) {
      return;
    }

    final current = _cursorLocation;
    if (current != null &&
        current.latitude.toStringAsFixed(6) ==
            point.latitude.toStringAsFixed(6) &&
        current.longitude.toStringAsFixed(6) ==
            point.longitude.toStringAsFixed(6) &&
        _cursorScreenPosition != null &&
        (_cursorScreenPosition! - local).distance < 0.5) {
      return;
    }

    setState(() {
      _cursorLocation = point;
      _cursorScreenPosition = local;
    });

    _updateLinePreviewEnd(point);
  }

  LatLng? _selectedLineSnapTarget(LatLng point) {
    final selectedLineId = ref.read(selectedLineProvider);
    if (selectedLineId == null) {
      return null;
    }

    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final selected = findZoneById(zones, selectedLineId);
    if (selected == null) {
      return null;
    }

    final geometry = LineGeometry.fromZone(selected);
    if (geometry == null || !geometry.isValid) {
      return null;
    }

    final candidates = [geometry.start!, geometry.end!];
    final snapped = snapLinePoint(
      point: point,
      camera: _mapController.camera,
      candidates: candidates,
    );

    final tapScreen = _mapController.camera.latLngToScreenOffset(point);
    final snapScreen = _mapController.camera.latLngToScreenOffset(snapped);
    if ((tapScreen - snapScreen).distance <= lineSnapRadiusPx) {
      return snapped;
    }

    return null;
  }

  List<LatLng> _lineSnapCandidates() {
    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    return collectLineEndpointSnapCandidates(zones);
  }

  LatLng _snapLinePoint(LatLng point) {
    return snapLinePoint(
      point: point,
      camera: _mapController.camera,
      candidates: _lineSnapCandidates(),
    );
  }

  void _updateLinePreviewEnd(LatLng point) {
    final lineDrawing = ref.read(lineDrawingProvider);
    if (!lineDrawing.awaitingEnd) {
      return;
    }
    ref.read(lineDrawingProvider.notifier).setPreviewEnd(_snapLinePoint(point));
  }

  void _updateCursorFromGlobalPosition(Offset globalPosition) {
    final box = _mapRenderBox;
    if (box == null || !box.hasSize) {
      return;
    }

    final local = box.globalToLocal(globalPosition);
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx > box.size.width ||
        local.dy > box.size.height) {
      return;
    }

    _updateCursor(
      globalPosition,
      _mapController.camera.screenOffsetToLatLng(local),
    );
  }

  void _cancelPendingLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _pendingLongPressLocal = null;
    _pendingLongPressPoint = null;
  }

  void _startLongPressTimer(Offset local, LatLng point) {
    _cancelPendingLongPress();
    _pendingLongPressLocal = local;
    _pendingLongPressPoint = point;
    _longPressTimer = Timer(_longPressDuration, () {
      if (!mounted) {
        return;
      }
      final center = _pendingLongPressLocal;
      final menuPoint = _pendingLongPressPoint;
      _cancelPendingLongPress();
      if (center == null || menuPoint == null) {
        return;
      }
      _longPressTriggered = true;
      _openRadialMenuAt(center, menuPoint);
    });
  }

  UuidValue? _hitLineAtPoint(LatLng point) {
    final zones = widget.zonesAsync.valueOrNull;
    if (zones == null) {
      return null;
    }
    return hitTestLineAtPoint(
      point: point,
      zones: zones,
      camera: _mapController.camera,
    );
  }

  void _clearLineSelectionIfPointerMissedLine(LatLng point) {
    if (ref.read(lineDrawingProvider).active) {
      return;
    }
    if (_hitLineAtPoint(point) != null) {
      return;
    }
    if (ref.read(selectedLineProvider) != null) {
      ref.read(selectedLineProvider.notifier).clear();
      _clearedSelectionOnPointerDown = true;
    }
  }

  void _handlePointerDown(PointerDownEvent event, LatLng point) {
    final box = _mapRenderBox;
    if (box == null) {
      return;
    }
    final local = box.globalToLocal(event.position);
    _tapDownLocal = local;
    _longPressTriggered = false;
    _pendingSnapStart = null;
    _clearedSelectionOnPointerDown = false;
    _updateCursor(event.position, point);
    if (ref.read(lineDrawingProvider).active) {
      _cancelPendingLongPress();
      if (ref.read(lineDrawingProvider).awaitingEnd) {
        _lineDrawingPressActive = true;
      }
      return;
    }

    final snapTarget = _selectedLineSnapTarget(point);
    if (snapTarget != null) {
      _pendingSnapStart = snapTarget;
      _cancelPendingLongPress();
      return;
    }

    _clearLineSelectionIfPointerMissedLine(point);
    _startLongPressTimer(local, point);
  }

  void _handlePointerMove(PointerMoveEvent event, LatLng point) {
    _updateCursor(event.position, point);

    if (_pendingSnapStart != null &&
        _tapDownLocal != null &&
        !ref.read(lineDrawingProvider).active) {
      final box = _mapRenderBox;
      if (box != null) {
        final local = box.globalToLocal(event.position);
        if ((local - _tapDownLocal!).distance > _longPressMoveTolerance) {
          ref.read(lineDrawingProvider.notifier).setStart(_pendingSnapStart!);
          _lineDrawingPressActive = true;
          _pendingSnapStart = null;
        }
      }
    }

    if (ref.read(lineDrawingProvider).awaitingEnd && _lineDrawingPressActive) {
      ref
          .read(lineDrawingProvider.notifier)
          .setPreviewEnd(_snapLinePoint(point));
    }

    final pendingLocal = _pendingLongPressLocal;
    if (pendingLocal == null || _longPressTimer == null) {
      return;
    }

    final box = _mapRenderBox;
    if (box == null) {
      return;
    }

    final local = box.globalToLocal(event.position);
    if ((local - pendingLocal).distance > _longPressMoveTolerance) {
      _cancelPendingLongPress();
    }
  }

  void _handlePointerUp(PointerUpEvent event, LatLng point) {
    final lineDrawing = ref.read(lineDrawingProvider);

    if (_pendingSnapStart != null && !lineDrawing.active) {
      _pendingSnapStart = null;
      if (_isShortPress(event.position)) {
        _handleMapSelectionTap(point);
      }
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (lineDrawing.active && !_longPressTriggered) {
      if (lineDrawing.awaitingEnd && _lineDrawingPressActive) {
        unawaited(_finalizeLineDrawing(point));
      } else if (lineDrawing.awaitingStart && _isShortPress(event.position)) {
        _dismissLineInteraction();
      }
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (!_longPressTriggered &&
        _tapDownLocal != null &&
        _isShortPress(event.position)) {
      _handleMapSelectionTap(point);
    }

    _resetLineDrawGestureState();
    _cancelPendingLongPress();
  }

  void _resetLineDrawGestureState() {
    _lineDrawingPressActive = false;
    _pendingSnapStart = null;
    _clearedSelectionOnPointerDown = false;
    _tapDownLocal = null;
  }

  void _dismissLineInteraction() {
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(selectedLineProvider.notifier).clear();
  }

  bool _isShortPress(Offset globalPosition) {
    final box = _mapRenderBox;
    if (box == null || _tapDownLocal == null) {
      return false;
    }
    final local = box.globalToLocal(globalPosition);
    return (local - _tapDownLocal!).distance <= _longPressMoveTolerance;
  }

  void _handleMapSelectionTap(LatLng point) {
    final hitLineId = _hitLineAtPoint(point);
    final currentSelection = ref.read(selectedLineProvider);
    final clearedOnDown = _clearedSelectionOnPointerDown;

    ref.read(lineDrawingProvider.notifier).reset();

    final selectedLine = ref.read(selectedLineProvider.notifier);
    if (hitLineId == null || clearedOnDown) {
      selectedLine.clear();
      return;
    }
    if (currentSelection == hitLineId) {
      selectedLine.clear();
      return;
    }
    selectedLine.select(hitLineId);
  }

  Future<void> _finalizeLineDrawing(LatLng endPoint) async {
    final drawing = ref.read(lineDrawingProvider);
    final start = drawing.start;
    if (start == null) {
      return;
    }

    final snappedEnd = _snapLinePoint(endPoint);
    ref.read(lineDrawingProvider.notifier).reset();

    if (areLinePointsTooClose(start, snappedEnd)) {
      return;
    }

    await createLineBetweenPoints(
      context: context,
      ref: ref,
      start: start,
      end: snappedEnd,
    );
  }

  void _handlePointerCancel() {
    _resetLineDrawGestureState();
    _cancelPendingLongPress();
  }

  void _beginLineDrawing() {
    final point = _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedLineProvider.notifier).clear();
    final notifier = ref.read(lineDrawingProvider.notifier);
    if (point != null) {
      notifier.setStart(point);
      if (_cursorLocation != null) {
        notifier.setPreviewEnd(_snapLinePoint(_cursorLocation!));
      }
    } else {
      notifier.begin();
    }
  }

  void _cancelLineDrawing() {
    _resetLineDrawGestureState();
    _dismissLineInteraction();
  }

  void _openRadialMenuAt(Offset center, LatLng point) {
    setState(() {
      _radialMenuCenter = center;
      _radialMenuPoint = point;
    });
  }

  void _closeRadialMenu() {
    if (_radialMenuCenter == null && _radialMenuPoint == null) {
      return;
    }
    setState(() {
      _radialMenuCenter = null;
      _radialMenuPoint = null;
    });
  }

  Future<void> _createMarkerFromRadialMenu() async {
    final point = _radialMenuPoint;
    if (point == null) {
      return;
    }
    _closeRadialMenu();
    await widget.onCreateMarker(point);
  }

  Offset _cursorLabelPosition(Size mapSize) {
    final cursor = _cursorScreenPosition ?? Offset.zero;
    const estimatedWidth = 220.0;
    const estimatedHeight = 32.0;

    final left = (cursor.dx + _cursorLabelOffset.dx)
        .clamp(8.0, math.max(8.0, mapSize.width - estimatedWidth - 8))
        .toDouble();
    final top = (cursor.dy + _cursorLabelOffset.dy)
        .clamp(8.0, math.max(8.0, mapSize.height - estimatedHeight - 8))
        .toDouble();

    return Offset(left, top);
  }

  Widget _lineDrawingBanner(LineDrawingState lineDrawing) {
    final theme = Theme.of(context);
    final message = lineDrawing.awaitingStart
        ? 'Tap a snap point or long-press the map to start a line'
        : 'Click or drag to the end point, or use Cancel to exit';

    return Material(
      elevation: 2,
      color: theme.colorScheme.inverseSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.timeline,
                color: theme.colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _cancelLineDrawing,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapLayer = widget.mapLayer;
    final minZoom = mapLayer?.minZoom.toDouble() ?? 2;
    final maxZoom = _maxInteractionZoom(mapLayer?.maxZoom);
    final lineDrawing = ref.watch(lineDrawingProvider);
    final selectedLineId = ref.watch(selectedLineProvider);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final previewColor = Theme.of(context).colorScheme.primary;
    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final selectedLine =
        selectedLineId == null ? null : findZoneById(zones, selectedLineId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
        final labelPosition = _cursorScreenPosition == null
            ? null
            : _cursorLabelPosition(mapSize);

        return Stack(
          fit: StackFit.expand,
          children: [
            MouseRegion(
              key: _mapHostKey,
              cursor: SystemMouseCursors.precise,
              onHover: (event) => _updateCursorFromGlobalPosition(event.position),
              onExit: (_) => _clearCursor(),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.viewport.center,
                  initialZoom: widget.viewport.zoom,
                  minZoom: minZoom,
                  maxZoom: maxZoom,
                  interactionOptions: InteractionOptions(
                    flags: lineDrawing.active
                        ? InteractiveFlag.all & ~InteractiveFlag.drag
                        : InteractiveFlag.all,
                  ),
                  onPositionChanged: (position, hasGesture) {
                    if (!hasGesture) return;
                    widget.onViewportChanged(
                      MapViewport(
                        center: position.center,
                        zoom: position.zoom,
                      ),
                    );
                  },
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  onPointerCancel: (_, __) => _handlePointerCancel(),
                ),
                children: [
                  ...switch (mapLayer) {
                    PmtilesVectorMapLayerConfig(
                      :final tileProvider,
                      :final theme,
                      :final sprites,
                    ) =>
                      [
                        VectorTileLayer(
                          theme: theme,
                          sprites: sprites,
                          tileProviders: TileProviders({
                            'protomaps': tileProvider,
                          }),
                        ),
                      ],
                    PmtilesRasterMapLayerConfig(:final tileProvider) => [
                        TileLayer(
                          tileProvider: tileProvider,
                        ),
                      ],
                    null => [
                        _PlaceholderLayer(
                          onOpenSettings: widget.onOpenSettings,
                        ),
                      ],
                  },
                  if (widget.markersAsync case AsyncData(:final value))
                    MarkerLayer(
                      markers: value
                          .where((marker) => marker.visible)
                          .map(
                            (marker) => Marker(
                              point: LatLng(marker.latitude, marker.longitude),
                              width: mapMarkerWidth,
                              height: mapMarkerHeight,
                              alignment: mapMarkerAnchorAlignment,
                              child: MapMarkerIcon(
                                color: parseMarkerColor(marker.color),
                                iconName: marker.icon,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (widget.searchCoordinateMarker case final marker?)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: marker.location,
                          width: mapMarkerWidth,
                          height: mapMarkerHeight,
                          alignment: mapMarkerAnchorAlignment,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () =>
                                widget.onSaveSearchCoordinateMarker(marker),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Tooltip(
                                message: 'Save as marker',
                                child: const MapMarkerIcon(
                                  color: Color(0xFFE07A24),
                                  iconName: 'my_location',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (widget.zonesAsync case AsyncData(:final value))
                    PolylineLayer(
                      polylines: buildSavedLinePolylines(
                        value,
                        selectedLineId: selectedLineId,
                      ),
                    ),
                  if (widget.zonesAsync case AsyncData(:final value))
                    MarkerLayer(
                      markers: buildSavedLineArrowMarkers(value),
                    ),
                  if (selectedLine case final line? when !lineDrawing.active)
                    MarkerLayer(
                      markers: buildLineSnapPointMarkers(zone: line),
                    ),
                  if (lineDrawing.start case final start?)
                    PolylineLayer(
                      polylines: [
                        if (buildPreviewLinePolyline(
                              start: start,
                              previewEnd: lineDrawing.previewEnd,
                              color: previewColor,
                            )
                            case final preview?)
                          preview,
                      ],
                    ),
                  if (lineDrawing.start case final start?)
                    MarkerLayer(
                      markers: [
                        ...buildLineEndpointMarkers(
                          start: start,
                          end: lineDrawing.previewEnd,
                          color: previewColor,
                        ),
                        if (lineDrawing.previewEnd case final previewEnd?)
                          ...buildDirectionArrowMarkers(
                            start: start,
                            end: previewEnd,
                            color: previewColor,
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (widget.zonesAsync case AsyncData(:final value))
              Positioned.fill(
                child: IgnorePointer(
                  child: LineMapLabelsOverlay(
                    zones: value,
                    units: measurementUnits,
                    mapController: _mapController,
                    previewStart: lineDrawing.start,
                    previewEnd: lineDrawing.previewEnd,
                    previewColor: lineDrawing.active ? previewColor : null,
                  ),
                ),
              ),
            if (_cursorLocation case final location? when labelPosition != null)
              Positioned(
                left: labelPosition.dx,
                top: labelPosition.dy,
                child: IgnorePointer(
                  child: MapCursorCoordinates(location: location),
                ),
              ),
            if (_radialMenuCenter case final center? when _radialMenuPoint != null)
              MapRadialMenu(
                center: center,
                onDismiss: _closeRadialMenu,
                actions: [
                  MapRadialMenuAction(
                    icon: Icons.add_location_alt,
                    label: 'Marker',
                    onSelected: _createMarkerFromRadialMenu,
                  ),
                  MapRadialMenuAction(
                    icon: Icons.timeline,
                    label: 'Line',
                    onSelected: _beginLineDrawing,
                  ),
                ],
              ),
            if (lineDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _lineDrawingBanner(lineDrawing),
              ),
          ],
        );
      },
    );
  }
}

class _PlaceholderLayer extends StatelessWidget {
  const _PlaceholderLayer({
    this.errorMessage,
    required this.onOpenSettings,
  });

  final String? errorMessage;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8EEF2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No offline map installed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ??
                    'Upload a .pmtiles file in Settings. Tiles are stored on the server so every browser can use them.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _maxInteractionZoom(int? archiveMaxZoom) {
  final archiveMax = archiveMaxZoom?.toDouble() ?? AppConstants.maxMapZoom;
  return archiveMax > AppConstants.maxMapZoom
      ? archiveMax
      : AppConstants.maxMapZoom;
}
