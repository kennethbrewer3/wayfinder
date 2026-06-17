import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/browser_context_menu.dart';
import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../circles/presentation/create_circle_dialog.dart';
import '../../circles/presentation/map_circle_layer.dart';
import '../../circles/providers/circle_drawing_provider.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../rectangles/presentation/create_rectangle_dialog.dart';
import '../../rectangles/presentation/map_rectangle_layer.dart';
import '../../rectangles/providers/rectangle_drawing_provider.dart';
import '../../rectangles/utils/rectangle_bounds.dart';
import '../../rectangles/utils/rectangle_hit_test.dart';
import '../../layers/presentation/map_object_layer_stack.dart';
import '../../layers/providers/layers_provider.dart';
import '../../layers/utils/map_layer_utils.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/presentation/bearing_plot_overlay.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/presentation/line_distance_labels.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../circles/utils/circle_hit_test.dart';
import '../../lines/providers/bearing_plot_provider.dart';
import '../../lines/providers/line_drawing_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/map_providers.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/utils/marker_hit_test.dart';
import '../../lines/utils/bearing_utils.dart';
import '../../lines/utils/line_arrows.dart';
import '../../lines/utils/line_distance.dart';
import '../../lines/utils/line_path.dart';
import '../../lines/utils/line_snap.dart';
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
    final layersResultAsync = ref.watch(layersProvider);
    final layersAsync = layersResultAsync.whenData((result) => result.layers);
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
          layersAsync: layersAsync,
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
    required this.layersAsync,
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
  final AsyncValue<List<MapLayer>> layersAsync;
  final SearchCoordinateMarker? searchCoordinateMarker;
  final Future<void> Function(LatLng point) onCreateMarker;
  final Future<void> Function(SearchCoordinateMarker marker)
      onSaveSearchCoordinateMarker;
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends ConsumerState<_MapCanvas> {
  static const _longPressDuration = Duration(milliseconds: 550);
  static const _longPressMoveTolerance = 18.0;
  static const _selectionClickSlop = 24.0;
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
  bool _circleDrawingPressActive = false;
  bool _rectangleDrawingPressActive = false;
  LatLng? _pendingSnapStart;
  bool _primaryPointerGestureHandled = false;
  bool _activePointerDown = false;
  bool _pendingSelectionTapOnUp = false;
  Offset? _selectionPointerDownLocal;
  int? _draggingLineControlIndex;
  LineGeometry? _lineEditPreviewGeometry;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    setBrowserContextMenuEnabled(false);
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    setBrowserContextMenuEnabled(true);
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

  void _beginSelectionPointer(PointerDownEvent event, LatLng point) {
    _activePointerDown = true;
    _selectionPointerDownLocal = event.localPosition;
    _pendingSelectionTapOnUp = false;

    if (ref.read(bearingPlotProvider).active ||
        ref.read(lineDrawingProvider).active ||
        ref.read(circleDrawingProvider).active ||
        ref.read(rectangleDrawingProvider).active) {
      return;
    }
    if (_selectedLineSnapTarget(point) != null) {
      return;
    }
    _pendingSelectionTapOnUp = true;
  }

  void _clearPointerDownSelectionState() {
    _pendingSelectionTapOnUp = false;
    _activePointerDown = false;
    _selectionPointerDownLocal = null;
  }

  bool _isSelectionClick(PointerUpEvent event) {
    final downLocal = _selectionPointerDownLocal;
    if (downLocal == null) {
      return true;
    }
    return (event.localPosition - downLocal).distance <= _selectionClickSlop;
  }

  bool _finishSelectionPointer(PointerUpEvent event, LatLng point) {
    if (!_activePointerDown) {
      return false;
    }

    final shouldApply = !_longPressTriggered &&
        !ref.read(bearingPlotProvider).active &&
        !ref.read(lineDrawingProvider).active &&
        !ref.read(circleDrawingProvider).active &&
        !ref.read(rectangleDrawingProvider).active &&
        _pendingSelectionTapOnUp &&
        _isSelectionClick(event);

    if (shouldApply) {
      _applyMapSelectionAt(point);
    }

    _clearPointerDownSelectionState();
    return shouldApply;
  }

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
    _updateCirclePreviewRadius(point);
    _updateRectanglePreview(point);
    if (ref.read(bearingPlotProvider).active) {
      _updateBearingPlotPreview(point);
    }
  }

  LatLng? _selectedLineSnapTarget(LatLng point) {
    final selected = ref.read(selectedMapObjectProvider);
    if (selected?.kind != SelectedMapObjectKind.zone) {
      return null;
    }

    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final selectedZone = findZoneById(zones, selected!.id);
    if (selectedZone == null || selectedZone.type != lineZoneType) {
      return null;
    }

    final geometry = LineGeometry.fromZone(selectedZone);
    if (geometry == null || !geometry.isValid) {
      return null;
    }

    final tapScreen = _mapController.camera.latLngToScreenOffset(point);
    for (final candidate in [geometry.start!, geometry.end!]) {
      final candidateScreen =
          _mapController.camera.latLngToScreenOffset(candidate);
      if ((tapScreen - candidateScreen).distance <= lineSnapRadiusPx) {
        return candidate;
      }
    }

    return null;
  }

  MapZone? _selectedLineZone() {
    final selected = ref.read(selectedMapObjectProvider);
    if (selected?.kind != SelectedMapObjectKind.zone) {
      return null;
    }

    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final zone = findZoneById(zones, selected!.id);
    if (zone == null || zone.type != lineZoneType) {
      return null;
    }
    return zone;
  }

  LineGeometry? _selectedLineGeometry() {
    final zone = _selectedLineZone();
    if (zone == null) {
      return null;
    }
    return LineGeometry.fromZone(zone);
  }

  Map<UuidValue, LineGeometry>? _lineGeometryOverrides() {
    final zone = _selectedLineZone();
    final preview = _lineEditPreviewGeometry;
    if (zone == null || preview == null) {
      return null;
    }
    return {zone.id: preview};
  }

  int? _interiorControlPointIndexAt(LatLng point) {
    final geometry = _selectedLineGeometry();
    if (geometry == null) {
      return null;
    }

    final index = hitTestLineControlPointIndex(
      geometry: geometry,
      tap: point,
      camera: _mapController.camera,
    );
    if (index == null || !isInteriorLineControlPoint(geometry, index)) {
      return null;
    }
    return index;
  }

  Future<void> _persistLineGeometry(LineGeometry geometry) async {
    final zone = _selectedLineZone();
    if (zone == null) {
      return;
    }

    await ref.read(zonesProvider.notifier).updateLineGeometry(
          zoneId: zone.id,
          geometry: geometry,
        );
  }

  Future<void> _insertLineControlPointAt(LatLng point) async {
    final geometry = _selectedLineGeometry();
    if (geometry == null) {
      return;
    }

    final updated = insertLineControlPoint(
      geometry: geometry,
      tap: point,
      camera: _mapController.camera,
    );
    if (updated == null) {
      return;
    }

    await _persistLineGeometry(updated);
  }

  bool _removeLineControlPointAt(LatLng point) {
    final geometry = _selectedLineGeometry();
    if (geometry == null) {
      return false;
    }

    final index = hitTestLineControlPointIndex(
      geometry: geometry,
      tap: point,
      camera: _mapController.camera,
    );
    if (index == null || !isInteriorLineControlPoint(geometry, index)) {
      return false;
    }

    final updated = removeLineControlPoint(
      geometry: geometry,
      controlPointIndex: index,
    );
    if (updated == null) {
      return false;
    }

    unawaited(_persistLineGeometry(updated));
    return true;
  }

  Future<void> _commitLineControlPointDrag(LatLng point) async {
    final index = _draggingLineControlIndex;
    final geometry = _selectedLineGeometry();
    if (index == null || geometry == null) {
      _resetLineEditGestureState();
      return;
    }

    final updated = moveLineControlPoint(
      geometry: geometry,
      controlPointIndex: index,
      point: point,
    );
    _resetLineEditGestureState();
    if (updated == null) {
      return;
    }

    await _persistLineGeometry(updated);
  }

  void _resetLineEditGestureState() {
    if (_draggingLineControlIndex == null && _lineEditPreviewGeometry == null) {
      return;
    }
    setState(() {
      _draggingLineControlIndex = null;
      _lineEditPreviewGeometry = null;
    });
  }

  void _updateLineControlPointDrag(LatLng point) {
    final index = _draggingLineControlIndex;
    final geometry = _selectedLineGeometry();
    if (index == null || geometry == null) {
      return;
    }

    final updated = moveLineControlPoint(
      geometry: geometry,
      controlPointIndex: index,
      point: point,
    );
    if (updated == null) {
      return;
    }

    setState(() {
      _lineEditPreviewGeometry = updated;
    });
  }

  List<LatLng> _lineSnapCandidates() {
    return collectLineEndpointSnapCandidates(_zonesOnMap);
  }

  Map<UuidValue, MapLayer> get _layersById => mapLayersById(
        widget.layersAsync.valueOrNull ?? const <MapLayer>[],
      );

  List<MapZone> get _zonesOnMap {
    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    return filterZonesForMap(zones, _layersById);
  }

  LatLng _snapLinePoint(LatLng point) {
    return snapLinePoint(
      point: point,
      camera: _mapController.camera,
      candidates: _lineSnapCandidates(),
    );
  }

  void _updateCirclePreviewRadius(LatLng point) {
    final circleDrawing = ref.read(circleDrawingProvider);
    final center = circleDrawing.center;
    if (!circleDrawing.awaitingRadius || center == null) {
      return;
    }
    ref
        .read(circleDrawingProvider.notifier)
        .setPreviewRadius(lineLengthMeters(center, point));
  }

  void _updateRectanglePreview(LatLng point) {
    final rectangleDrawing = ref.read(rectangleDrawingProvider);
    if (!rectangleDrawing.awaitingSecondPoint) {
      return;
    }
    ref.read(rectangleDrawingProvider.notifier).setPreviewPoint(point);
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
      if (_removeLineControlPointAt(menuPoint)) {
        _cancelPendingLongPress();
        return;
      }
      _openRadialMenuAt(center, menuPoint);
    });
  }

  SelectedMapObject? _hitMapObjectAtPoint(LatLng point) {
    final markers = widget.markersAsync.valueOrNull;
    final layers = widget.layersAsync.valueOrNull ?? const <MapLayer>[];
    final layersById = mapLayersById(layers);
    if (markers != null) {
      final markerId = hitTestMarkerAtPoint(
        point: point,
        markers: filterMarkersForMap(markers, layersById),
        camera: _mapController.camera,
      );
      if (markerId != null) {
        return SelectedMapObject(
          kind: SelectedMapObjectKind.marker,
          id: markerId,
        );
      }
    }

    final zones = widget.zonesAsync.valueOrNull;
    if (zones == null) {
      return null;
    }

    final visibleZones = filterZonesForMap(zones, layersById);

    final lineId = hitTestLineAtPoint(
      point: point,
      zones: visibleZones,
      camera: _mapController.camera,
    );
    if (lineId != null) {
      return SelectedMapObject(kind: SelectedMapObjectKind.zone, id: lineId);
    }

    final circleId = hitTestCircleAtPoint(point: point, zones: visibleZones);
    if (circleId != null) {
      return SelectedMapObject(kind: SelectedMapObjectKind.zone, id: circleId);
    }

    final rectangleId = hitTestRectangleAtPoint(
      point: point,
      zones: zones,
      camera: _mapController.camera,
    );
    if (rectangleId != null) {
      return SelectedMapObject(
        kind: SelectedMapObjectKind.zone,
        id: rectangleId,
      );
    }

    return null;
  }

  void _revealSelectedObjectInSidebar(SelectedMapObject selection) {
    final layerId = switch (selection.kind) {
      SelectedMapObjectKind.marker => widget.markersAsync.valueOrNull
          ?.where((marker) => marker.id == selection.id)
          .map((marker) => marker.layerId)
          .firstOrNull,
      SelectedMapObjectKind.zone => widget.zonesAsync.valueOrNull
          ?.where((zone) => zone.id == selection.id)
          .map((zone) => zone.layerId)
          .firstOrNull,
    };

    ref.read(sidebarProvider.notifier).revealMapObject(
          kind: selection.kind,
          layerId: layerId,
        );
  }

  void _selectMapObject(SelectedMapObject selection) {
    ref.read(selectedMapObjectProvider.notifier).select(selection);
    _revealSelectedObjectInSidebar(selection);
  }

  void _handleSecondaryMapTap(TapPosition tapPosition, LatLng point) {
    if (ref.read(lineDrawingProvider).active ||
        ref.read(bearingPlotProvider).active ||
        ref.read(circleDrawingProvider).active ||
        ref.read(rectangleDrawingProvider).active) {
      return;
    }

    _cancelPendingLongPress();
    final local = tapPosition.relative ??
        _mapRenderBox?.globalToLocal(tapPosition.global);
    if (local == null) {
      return;
    }
    _openRadialMenuAt(local, point);
  }

  void _handlePointerDown(PointerDownEvent event, LatLng point) {
    _longPressTriggered = false;
    _pendingSnapStart = null;
    _tapDownLocal = event.localPosition;
    _updateCursor(event.position, point);

    final box = _mapRenderBox;
    if (box == null) {
      return;
    }

    if (_radialMenuCenter != null && event.buttons == kPrimaryMouseButton) {
      _closeRadialMenu();
    }

    if (ref.read(bearingPlotProvider).active) {
      _cancelPendingLongPress();
      _updateBearingPlotPreview(point);
      return;
    }

    if (ref.read(lineDrawingProvider).active) {
      _cancelPendingLongPress();
      if (ref.read(lineDrawingProvider).awaitingEnd) {
        _lineDrawingPressActive = true;
      }
      return;
    }

    if (ref.read(circleDrawingProvider).active) {
      _cancelPendingLongPress();
      if (ref.read(circleDrawingProvider).awaitingRadius) {
        _circleDrawingPressActive = true;
      }
      return;
    }

    if (ref.read(rectangleDrawingProvider).active) {
      _cancelPendingLongPress();
      if (ref.read(rectangleDrawingProvider).awaitingSecondPoint) {
        _rectangleDrawingPressActive = true;
      }
      return;
    }

    final snapTarget = _selectedLineSnapTarget(point);
    if (snapTarget != null) {
      _pendingSnapStart = snapTarget;
      _cancelPendingLongPress();
      return;
    }

    final interiorControlPoint = _interiorControlPointIndexAt(point);
    if (interiorControlPoint != null) {
      setState(() {
        _draggingLineControlIndex = interiorControlPoint;
        _lineEditPreviewGeometry = _selectedLineGeometry();
      });
      _cancelPendingLongPress();
      return;
    }

    if (event.buttons == kPrimaryMouseButton) {
      _startLongPressTimer(event.localPosition, point);
    }
  }

  void _handlePointerMove(PointerMoveEvent event, LatLng point) {
    _updateCursor(event.position, point);

    if (_radialMenuCenter != null && _tapDownLocal != null) {
      if ((event.localPosition - _tapDownLocal!).distance >
          _longPressMoveTolerance) {
        _closeRadialMenu();
      }
    }

    if (ref.read(bearingPlotProvider).active) {
      _updateBearingPlotPreview(point);
    }

    if (_pendingSnapStart != null &&
        _tapDownLocal != null &&
        !ref.read(lineDrawingProvider).active) {
      if ((event.localPosition - _tapDownLocal!).distance >
          _longPressMoveTolerance) {
        ref.read(lineDrawingProvider.notifier).setStart(_pendingSnapStart!);
        _lineDrawingPressActive = true;
        _pendingSnapStart = null;
      }
    }

    if (ref.read(lineDrawingProvider).awaitingEnd && _lineDrawingPressActive) {
      ref
          .read(lineDrawingProvider.notifier)
          .setPreviewEnd(_snapLinePoint(point));
    }

    if (ref.read(circleDrawingProvider).awaitingRadius &&
        _circleDrawingPressActive) {
      _updateCirclePreviewRadius(point);
    }

    if (ref.read(rectangleDrawingProvider).awaitingSecondPoint &&
        _rectangleDrawingPressActive) {
      _updateRectanglePreview(point);
    }

    if (_draggingLineControlIndex != null) {
      _updateLineControlPointDrag(point);
    }

    final pendingLocal = _pendingLongPressLocal;
    if (pendingLocal == null || _longPressTimer == null) {
      return;
    }

    if ((event.localPosition - pendingLocal).distance > _longPressMoveTolerance) {
      _cancelPendingLongPress();
    }
  }

  void _handlePointerUp(PointerUpEvent event, LatLng point) {
    _primaryPointerGestureHandled = false;
    final lineDrawing = ref.read(lineDrawingProvider);
    final bearingPlot = ref.read(bearingPlotProvider);

    if (_draggingLineControlIndex != null) {
      unawaited(_commitLineControlPointDrag(point));
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (_pendingSnapStart != null && !lineDrawing.active) {
      final snapAnchor = _pendingSnapStart!;
      _pendingSnapStart = null;
      if (_isShortPress(event)) {
        _beginBearingPlot(snapAnchor);
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (bearingPlot.active && !_longPressTriggered) {
      if (_isShortPress(event)) {
        _updateBearingPlotPreview(point);
        final updated = ref.read(bearingPlotProvider);
        final anchor = updated.anchor;
        final previewEnd = updated.previewEnd;
        if (anchor != null &&
            previewEnd != null &&
            !areLinePointsTooClose(anchor, previewEnd)) {
          unawaited(_finalizeBearingPlot());
        }
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (lineDrawing.active && !_longPressTriggered) {
      if (lineDrawing.awaitingEnd && _lineDrawingPressActive) {
        unawaited(_finalizeLineDrawing(point));
      } else if (lineDrawing.awaitingStart && _isShortPress(event)) {
        _dismissLineInteraction();
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    final circleDrawing = ref.read(circleDrawingProvider);
    if (circleDrawing.active && !_longPressTriggered) {
      if (circleDrawing.awaitingRadius && _circleDrawingPressActive) {
        unawaited(_finalizeCircleDrawing(point));
      } else if (_isShortPress(event)) {
        _cancelCircleDrawing();
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    final rectangleDrawing = ref.read(rectangleDrawingProvider);
    if (rectangleDrawing.active && !_longPressTriggered) {
      if (rectangleDrawing.awaitingSecondPoint &&
          _rectangleDrawingPressActive) {
        unawaited(_finalizeRectangleDrawing(point));
      } else if (_isShortPress(event)) {
        _cancelRectangleDrawing();
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    _resetLineDrawGestureState();
    _cancelPendingLongPress();
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_primaryPointerGestureHandled) {
      return;
    }
    if (_longPressTriggered || _radialMenuCenter != null) {
      return;
    }
    if (ref.read(bearingPlotProvider).active ||
        ref.read(lineDrawingProvider).active ||
        ref.read(circleDrawingProvider).active ||
        ref.read(rectangleDrawingProvider).active) {
      return;
    }
    _applyMapSelectionAt(point);
    _clearPointerDownSelectionState();
  }

  void _resetLineDrawGestureState() {
    _lineDrawingPressActive = false;
    _circleDrawingPressActive = false;
    _rectangleDrawingPressActive = false;
    _pendingSnapStart = null;
    _tapDownLocal = null;
  }

  Widget _lineEditingBanner() {
    final theme = Theme.of(context);
    const message =
        'Tap the line to add a curve point · drag points to move · long-press a point to remove';

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
                Icons.ssid_chart,
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
            ],
          ),
        ),
      ),
    );
  }

  void _dismissLineInteraction() {
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(selectedMapObjectProvider.notifier).clear();
  }

  void _beginBearingPlot(LatLng anchor) {
    final selectedLineId = ref.read(selectedMapObjectProvider).selectedZoneId;
    if (selectedLineId == null) {
      return;
    }

    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final selectedLine = findZoneById(zones, selectedLineId);
    if (selectedLine == null) {
      return;
    }

    final referenceBearing = referenceLineBearingAtAnchor(
      zone: selectedLine,
      anchor: anchor,
    );
    if (referenceBearing == null) {
      return;
    }

    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).begin(
          anchor: anchor,
          referenceBearing: referenceBearing,
          referenceLineId: selectedLine.id,
        );

    if (_cursorLocation != null) {
      _updateBearingPlotPreview(_cursorLocation!);
    }
  }

  void _updateBearingPlotPreview(LatLng point) {
    final bearingPlot = ref.read(bearingPlotProvider);
    final anchor = bearingPlot.anchor;
    if (!bearingPlot.active || anchor == null) {
      return;
    }

    final previewEnd = _snapLinePoint(point);
    final plotBearing = lineGeodesicCalculator.bearing(anchor, previewEnd);
    ref.read(bearingPlotProvider.notifier).updatePlot(
          plotBearing: plotBearing,
          previewEnd: previewEnd,
        );
  }

  Future<void> _finalizeBearingPlot() async {
    final bearingPlot = ref.read(bearingPlotProvider);
    final anchor = bearingPlot.anchor;
    final previewEnd = bearingPlot.previewEnd;
    ref.read(bearingPlotProvider.notifier).reset();

    if (anchor == null || previewEnd == null) {
      return;
    }
    if (areLinePointsTooClose(anchor, previewEnd)) {
      return;
    }

    await createLineBetweenPoints(
      context: context,
      ref: ref,
      start: anchor,
      end: previewEnd,
    );
  }

  void _cancelBearingPlot() {
    ref.read(bearingPlotProvider.notifier).reset();
  }

  bool _isShortPress(PointerUpEvent event) {
    final tapDown = _tapDownLocal;
    if (tapDown == null) {
      return false;
    }
    return (event.localPosition - tapDown).distance <= _longPressMoveTolerance;
  }

  void _applyMapSelectionAt(LatLng point) {
    if (ref.read(bearingPlotProvider).active ||
        ref.read(lineDrawingProvider).active ||
        ref.read(circleDrawingProvider).active ||
        ref.read(rectangleDrawingProvider).active) {
      return;
    }

    final hit = _hitMapObjectAtPoint(point);
    final current = ref.read(selectedMapObjectProvider);
    final notifier = ref.read(selectedMapObjectProvider.notifier);

    if (current == null) {
      if (hit != null) {
        _selectMapObject(hit);
      }
      return;
    }

    if (hit == null) {
      notifier.clear();
      return;
    }

    if (hit == current) {
      if (current.kind == SelectedMapObjectKind.zone) {
        final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
        final zone = findZoneById(zones, current.id);
        if (zone?.type == lineZoneType) {
          unawaited(_insertLineControlPointAt(point));
          return;
        }
      }
      notifier.clear();
      return;
    }

    _selectMapObject(hit);
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

  Future<void> _finalizeCircleDrawing(LatLng edgePoint) async {
    final drawing = ref.read(circleDrawingProvider);
    final center = drawing.center;
    if (center == null) {
      return;
    }

    final radiusMeters = lineLengthMeters(center, edgePoint);
    ref.read(circleDrawingProvider.notifier).reset();
    _circleDrawingPressActive = false;

    if (radiusMeters < 1) {
      return;
    }

    await createCircleAtCenter(
      context: context,
      ref: ref,
      center: center,
      radiusMeters: radiusMeters,
    );
  }

  Future<void> _finalizeRectangleDrawing(LatLng point) async {
    final drawing = ref.read(rectangleDrawingProvider);
    final anchor = drawing.anchor;
    final mode = drawing.mode;
    if (anchor == null || mode == null) {
      return;
    }

    ref.read(rectangleDrawingProvider.notifier).reset();
    _rectangleDrawingPressActive = false;

    final bounds = switch (mode) {
      RectangleCreationMode.centerExtent =>
        boundsFromCenterExtent(anchor, point),
      RectangleCreationMode.corners => boundsFromCorners(anchor, point),
    };
    if (!bounds.isValid) {
      return;
    }

    switch (mode) {
      case RectangleCreationMode.centerExtent:
        await createCenterExtentRectangle(
          context: context,
          ref: ref,
          center: anchor,
          extentPoint: point,
        );
      case RectangleCreationMode.corners:
        await createCornersRectangle(
          context: context,
          ref: ref,
          cornerA: anchor,
          cornerB: point,
        );
    }
  }

  void _handlePointerCancel() {
    _clearPointerDownSelectionState();
    _resetLineDrawGestureState();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    _cancelPendingLongPress();
  }

  void _beginLineDrawing() {
    final point = _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
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

  void _beginCircleDrawing() {
    final point = _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    final notifier = ref.read(circleDrawingProvider.notifier);
    if (point != null) {
      notifier.setCenter(point);
      if (_cursorLocation != null) {
        notifier.setPreviewRadius(lineLengthMeters(point, _cursorLocation!));
      }
    } else {
      notifier.begin();
    }
  }

  void _cancelCircleDrawing() {
    _resetLineDrawGestureState();
    ref.read(circleDrawingProvider.notifier).reset();
  }

  void _beginCenterRectDrawing() {
    final point = _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    final notifier = ref.read(rectangleDrawingProvider.notifier);
    if (point != null) {
      notifier.beginCenterExtent(point);
      if (_cursorLocation != null) {
        notifier.setPreviewPoint(_cursorLocation!);
      }
    }
  }

  void _beginCornersRectDrawing() {
    final point = _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    final notifier = ref.read(rectangleDrawingProvider.notifier);
    if (point != null) {
      notifier.beginCorners(point);
      if (_cursorLocation != null) {
        notifier.setPreviewPoint(_cursorLocation!);
      }
    }
  }

  void _cancelRectangleDrawing() {
    _resetLineDrawGestureState();
    ref.read(rectangleDrawingProvider.notifier).reset();
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

  Widget _bearingPlotBanner(
    BearingPlotState bearingPlot,
    AngleDisplayFormat angleFormat,
  ) {
    final theme = Theme.of(context);
    final reference = bearingPlot.referenceBearing;
    final plot = bearingPlot.plotBearing;
    final relative = bearingPlot.relativeBearing;

    final details = StringBuffer('Bearing plot · ');
    if (reference != null) {
      details.write('Ref ${formatTrueBearing(reference)}');
    }
    if (plot != null) {
      details.write(' · Brg ${formatTrueBearing(plot)}');
    }
    if (relative != null) {
      details.write(' · ${formatRelativeAngle(relative, angleFormat)}');
    }
    details.write(' · Click to plot line');

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
                Icons.explore_outlined,
                color: theme.colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  details.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Rel°',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onInverseSurface
                          .withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(alpha: 0.15),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  style: TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontSize: 13,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    final angle = double.tryParse(value.trim());
                    if (angle == null) {
                      return;
                    }
                    ref
                        .read(bearingPlotProvider.notifier)
                        .setRelativeBearing(angle);
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _cancelBearingPlot,
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

  Widget _lineDrawingBanner(LineDrawingState lineDrawing) {
    final theme = Theme.of(context);
    final message = lineDrawing.awaitingStart
        ? 'Drag a snap point to draw freely, or click one to plot a bearing'
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

  Widget _circleDrawingBanner(CircleDrawingState circleDrawing) {
    final theme = Theme.of(context);
    const message =
        'Click or drag to set the circle radius, or use Cancel to exit';

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
                Icons.radio_button_unchecked,
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
                onPressed: _cancelCircleDrawing,
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

  Widget _rectangleDrawingBanner(RectangleDrawingState rectangleDrawing) {
    final theme = Theme.of(context);
    final message = switch (rectangleDrawing.mode) {
      RectangleCreationMode.centerExtent =>
        'Click or drag to set the rectangle size from center, or use Cancel to exit',
      RectangleCreationMode.corners =>
        'Click or drag to set the opposite corner, or use Cancel to exit',
      null => 'Click or drag to define the rectangle, or use Cancel to exit',
    };

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
                Icons.crop_square,
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
                onPressed: _cancelRectangleDrawing,
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
    final circleDrawing = ref.watch(circleDrawingProvider);
    final rectangleDrawing = ref.watch(rectangleDrawingProvider);
    final bearingPlot = ref.watch(bearingPlotProvider);
    final selectedMapObject = ref.watch(selectedMapObjectProvider);
    final selectedLineId = selectedMapObject.selectedZoneId;
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final angleDisplayFormat = ref.watch(angleDisplayFormatProvider);
    final previewColor = Theme.of(context).colorScheme.primary;
    final previewFillColor = previewColor.withValues(alpha: 0.25);
    final referenceColor = Theme.of(context).colorScheme.secondary;
    final allMarkers = widget.markersAsync.valueOrNull;
    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final layers = widget.layersAsync.valueOrNull ?? const <MapLayer>[];
    final layersById = mapLayersById(layers);
    final selectedLine =
        selectedLineId == null ? null : findZoneById(zones, selectedLineId);
    final lineGeometryOverrides = _lineGeometryOverrides();
    final mapObjectLayerChildren = allMarkers == null
        ? const <Widget>[]
        : buildStackedMapLayerChildren(
            layers: layers,
            markers: allMarkers,
            zones: zones,
            selectedLineId: selectedLineId,
            geometryOverrides: lineGeometryOverrides,
            onMarkerTap: (marker) => _selectMapObject(
              SelectedMapObject(
                kind: SelectedMapObjectKind.marker,
                id: marker.id,
              ),
            ),
          );
    final selectedLinePreviewGeometry = _lineEditPreviewGeometry ??
        (selectedLine == null ? null : LineGeometry.fromZone(selectedLine));
    final bearingAnchor =
        bearingPlot.active ? bearingPlot.anchor : null;
    final bearingReference = bearingPlot.referenceBearing;
    final activeRectanglePreviewBounds = rectangleDrawing.mode == null ||
            rectangleDrawing.anchor == null ||
            rectangleDrawing.previewPoint == null
        ? null
        : previewRectangleBounds(
            RectangleDrawingPreview(
              mode: rectangleDrawing.mode!,
              anchor: rectangleDrawing.anchor,
              previewPoint: rectangleDrawing.previewPoint,
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
        final labelPosition = _cursorScreenPosition == null
            ? null
            : _cursorLabelPosition(mapSize);

        return Stack(
          fit: StackFit.expand,
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                final point = _mapController.camera
                    .screenOffsetToLatLng(event.localPosition);
                _beginSelectionPointer(event, point);
              },
              onPointerUp: (event) {
                final point = _mapController.camera
                    .screenOffsetToLatLng(event.localPosition);
                if (_finishSelectionPointer(event, point)) {
                  _primaryPointerGestureHandled = true;
                }
              },
              child: MouseRegion(
                key: _mapHostKey,
                cursor: SystemMouseCursors.precise,
                onHover: (event) =>
                    _updateCursorFromGlobalPosition(event.position),
                onExit: (_) => _clearCursor(),
                child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.viewport.center,
                  initialZoom: widget.viewport.zoom,
                  minZoom: minZoom,
                  maxZoom: maxZoom,
                  interactionOptions: InteractionOptions(
                    flags: lineDrawing.active ||
                            bearingPlot.active ||
                            circleDrawing.active ||
                            rectangleDrawing.active ||
                            _draggingLineControlIndex != null
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
                  onSecondaryTap: _handleSecondaryMapTap,
                  onTap: _handleMapTap,
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
                  ...mapObjectLayerChildren,
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
                  if (selectedLine case final line?
                      when !lineDrawing.active && !bearingPlot.active)
                    MarkerLayer(
                      markers: buildLineSnapPointMarkers(
                        zone: line,
                        geometryOverride: selectedLinePreviewGeometry,
                      ),
                    ),
                  if (bearingAnchor case final anchor?)
                    PolylineLayer(
                      polylines: [
                        if (bearingReference case final reference?)
                          if (buildReferenceCoursePolyline(
                                anchor: anchor,
                                referenceBearing: reference,
                                previewEnd: bearingPlot.previewEnd,
                                color: referenceColor,
                              )
                              case final referenceLine?)
                            referenceLine,
                        if (buildPreviewLinePolyline(
                              start: anchor,
                              previewEnd: bearingPlot.previewEnd,
                              color: previewColor,
                            )
                            case final preview?)
                          preview,
                      ],
                    ),
                  if (bearingAnchor case final anchor?)
                    MarkerLayer(
                      markers: [
                        ...buildLineEndpointMarkers(
                          start: anchor,
                          end: bearingPlot.previewEnd,
                          color: previewColor,
                        ),
                        if (bearingPlot.previewEnd case final previewEnd?)
                          ...buildDirectionArrowMarkers(
                            start: anchor,
                            end: previewEnd,
                            color: previewColor,
                          ),
                      ],
                    ),
                  if (circleDrawing.center case final center?)
                    PolygonLayer(
                      polygons: [
                        if (buildPreviewCirclePolygon(
                              center: center,
                              radiusMeters: circleDrawing.previewRadiusMeters,
                              borderColor: previewColor,
                              fillColor: previewFillColor,
                            )
                            case final preview?)
                          preview,
                      ],
                    ),
                  if (circleDrawing.center case final center?)
                    PolylineLayer(
                      polylines: [
                        if (buildPreviewCircleRadiusLine(
                              center: center,
                              radiusMeters: circleDrawing.previewRadiusMeters,
                              color: previewColor,
                            )
                            case final preview?)
                          preview,
                      ],
                    ),
                  if (circleDrawing.center case final center?)
                    MarkerLayer(
                      markers: [
                        buildPreviewCircleCenterMarker(
                          center: center,
                          color: previewColor,
                        ),
                      ],
                    ),
                  if (activeRectanglePreviewBounds case final bounds?)
                    PolygonLayer(
                      polygons: [
                        if (buildPreviewRectanglePolygon(
                              bounds: bounds,
                              borderColor: previewColor,
                              fillColor: previewFillColor,
                            )
                            case final preview?)
                          preview,
                      ],
                    ),
                  if (rectangleDrawing.mode ==
                          RectangleCreationMode.centerExtent &&
                      rectangleDrawing.anchor != null)
                    MarkerLayer(
                      markers: [
                        if (buildPreviewRectangleCenterMarker(
                              center: rectangleDrawing.anchor,
                              color: previewColor,
                            )
                            case final preview?)
                          preview,
                      ],
                    ),
                  if (rectangleDrawing.mode == RectangleCreationMode.corners &&
                      rectangleDrawing.anchor != null)
                    MarkerLayer(
                      markers: [
                        ...buildLineEndpointMarkers(
                          start: rectangleDrawing.anchor!,
                          end: rectangleDrawing.previewPoint,
                          color: previewColor,
                        ),
                      ],
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
            ),
            if (widget.zonesAsync.valueOrNull case final value?)
              Positioned.fill(
                child: IgnorePointer(
                  child: LineMapLabelsOverlay(
                    zones: filterZonesForMap(value, layersById),
                    units: measurementUnits,
                    mapController: _mapController,
                    previewStart: lineDrawing.start,
                    previewEnd: lineDrawing.previewEnd,
                    previewColor: lineDrawing.active ? previewColor : null,
                    bearingPreviewStart:
                        bearingPlot.active ? bearingPlot.anchor : null,
                    bearingPreviewEnd: bearingPlot.previewEnd,
                    bearingPreviewColor:
                        bearingPlot.active ? previewColor : null,
                    bearingPreviewAngle: bearingPlot.relativeBearing == null
                        ? null
                        : formatRelativeAngle(
                            bearingPlot.relativeBearing!,
                            angleDisplayFormat,
                          ),
                    previewCircleCenter:
                        circleDrawing.active ? circleDrawing.center : null,
                    previewCircleRadiusMeters: circleDrawing.previewRadiusMeters,
                    previewCircleColor:
                        circleDrawing.active ? previewColor : null,
                    previewRectangleBounds: rectangleDrawing.active
                        ? activeRectanglePreviewBounds
                        : null,
                    previewRectangleColor:
                        rectangleDrawing.active ? previewColor : null,
                  ),
                ),
              ),
            if (bearingAnchor case final anchor? when bearingReference != null)
              BearingPlotOverlay(
                anchor: anchor,
                referenceBearing: bearingReference,
                plotBearing: bearingPlot.plotBearing,
                mapController: _mapController,
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
                  MapRadialMenuAction(
                    icon: Icons.radio_button_unchecked,
                    label: 'Circle',
                    onSelected: _beginCircleDrawing,
                  ),
                  MapRadialMenuAction(
                    icon: Icons.crop_square,
                    label: 'Rect center',
                    onSelected: _beginCenterRectDrawing,
                  ),
                  MapRadialMenuAction(
                    icon: Icons.select_all,
                    label: 'Rect corners',
                    onSelected: _beginCornersRectDrawing,
                  ),
                ],
              ),
            if (bearingPlot.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _bearingPlotBanner(bearingPlot, angleDisplayFormat),
              ),
            if (lineDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _lineDrawingBanner(lineDrawing),
              ),
            if (selectedLine != null &&
                !lineDrawing.active &&
                !bearingPlot.active &&
                !circleDrawing.active &&
                !rectangleDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _lineEditingBanner(),
              ),
            if (circleDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _circleDrawingBanner(circleDrawing),
              ),
            if (rectangleDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _rectangleDrawingBanner(rectangleDrawing),
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
