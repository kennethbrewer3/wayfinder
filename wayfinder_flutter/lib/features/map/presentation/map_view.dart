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
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/browser_context_menu.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/presentation/copy_coordinates.dart';
import '../../circles/presentation/create_circle_dialog.dart';
import '../../circles/presentation/map_circle_layer.dart';
import '../../circles/providers/circle_drawing_provider.dart';
import '../../circles/utils/circle_hit_test.dart';
import '../../geocoding/presentation/submit_geocoding_contribution.dart';
import '../../geocoding/providers/geocoding_server_provider.dart';
import '../../layers/presentation/map_object_layer_stack.dart';
import '../../layers/providers/layers_provider.dart';
import '../../layers/utils/map_layer_utils.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/bearing_reference.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/presentation/bearing_plot_overlay.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/presentation/dead_reckoning_banner.dart';
import '../../lines/presentation/line_direction_arrows_overlay.dart';
import '../../lines/presentation/line_distance_labels.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/bearing_plot_provider.dart';
import '../../lines/providers/bearing_reference_provider.dart';
import '../../lines/providers/dead_reckoning_provider.dart';
import '../../lines/providers/line_drawing_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/pace_length_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../lines/utils/bearing_utils.dart';
import '../../lines/utils/co_located_line_endpoints.dart';
import '../../lines/utils/line_distance.dart';
import '../../lines/utils/line_path.dart';
import '../../lines/utils/line_snap.dart';
import '../../map/providers/map_providers.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/models/map_marker_size.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/providers/map_marker_size_provider.dart';
import '../../markers/providers/marker_icon_providers.dart';
import '../../markers/providers/markers_provider.dart';
import '../../markers/utils/marker_hit_test.dart';
import '../../markers/utils/marker_share_url.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../../polygons/presentation/create_polygon_dialog.dart';
import '../../polygons/presentation/map_polygon_layer.dart';
import '../../polygons/providers/polygon_drawing_provider.dart';
import '../../polygons/utils/polygon_hit_test.dart';
import '../../polygons/utils/polygon_path.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../rectangles/presentation/create_rectangle_dialog.dart';
import '../../rectangles/presentation/map_rectangle_layer.dart';
import '../../rectangles/providers/rectangle_drawing_provider.dart';
import '../../rectangles/utils/rectangle_bounds.dart';
import '../../rectangles/utils/rectangle_hit_test.dart';
import '../../search/providers/search_coordinate_marker_provider.dart';
import '../../settings/data/pmtiles_loader.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import '../../settings/models/pmtiles_map_layer.dart';
import '../../settings/models/pmtiles_source.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../../slope/presentation/map_slope_layer.dart';
import '../../slope/presentation/slope_banner.dart';
import '../../slope/providers/slope_provider.dart';
import '../../tracks/presentation/track_footsteps_overlay.dart';
import '../../viewshed/presentation/map_viewshed_layer.dart';
import '../../viewshed/presentation/viewshed_banner.dart';
import '../../viewshed/providers/viewshed_provider.dart';
import '../../viewshed/utils/viewshed_compute.dart';
import '../models/map_viewport.dart';
import '../models/pmtiles_load_status.dart';
import '../providers/device_location_provider.dart';
import '../providers/map_compass_rose_provider.dart';
import '../providers/map_mgrs_grid_provider.dart';
import '../providers/map_viewport_debug_provider.dart';
import '../providers/map_zoom_range_provider.dart';
import '../providers/pmtiles_load_status_provider.dart';
import '../utils/device_location_readout.dart';
import '../utils/magnetic_declination.dart';
import '../utils/pmtiles_archive_selection.dart';
import '../utils/pmtiles_viewport.dart';
import 'map_compass_rose_overlay.dart';
import 'map_cursor_coordinates.dart';
import 'map_device_location_hud.dart';
import 'map_device_location_layer.dart';
import 'map_mgrs_grid_layer.dart';
import 'map_radial_menu.dart';
import 'map_viewport_debug_overlay.dart';

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
    final layersAsync = ref.watch(layersProvider);
    final searchCoordinateMarker = ref.watch(searchCoordinateMarkerProvider);
    final metadataAsync = ref.watch(pmtilesEnabledMetadataProvider);

    if (metadataAsync.hasError) {
      AppLogger.logMap.error(
        '🗺️ PMTiles metadata failed to load',
        error: metadataAsync.error,
        stackTrace: metadataAsync.stackTrace,
      );
      return _PlaceholderLayer(
        errorMessage: metadataAsync.error.toString(),
        onOpenSettings: () {
          AppLogger.logNav.info(
            '🧭 Navigating to settings from map error placeholder',
          );
          context.push('/settings/map-tiles');
        },
      );
    }

    final enabledEntries = metadataAsync.valueOrNull ?? const [];
    if (enabledEntries.isEmpty && !metadataAsync.isLoading) {
      AppLogger.logMap.warn('🗺️ No PMTiles map layers — showing placeholder');
    }

    return _MapCanvas(
      viewport: viewport,
      onViewportChanged: onViewportChanged,
      enabledEntries: enabledEntries,
      metadataLoading: metadataAsync.isLoading,
      markersAsync: markersAsync,
      zonesAsync: zonesAsync,
      layersAsync: layersAsync,
      searchCoordinateMarker: searchCoordinateMarker,
      onCreateMarker: (point) => _createMarker(context, ref, point),
      onSaveSearchCoordinateMarker: (marker) =>
          _saveSearchCoordinateMarker(context, ref, marker),
      onOpenSettings: () {
        AppLogger.logNav.info('🧭 Navigating to settings from map placeholder');
        context.push('/settings/map-tiles');
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
    final l10n = AppLocalizations.of(context)!;
    final saved = await createMarkerAtPoint(
      context: context,
      ref: ref,
      point: marker.location,
      defaultName: marker.label,
      dialogTitle: l10n.markerSaveSearchedCoordinatesTitle,
      confirmLabel: l10n.markerSaveSearchedCoordinatesConfirm,
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
    required this.enabledEntries,
    required this.metadataLoading,
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
  final List<PmtilesArchiveEntry> enabledEntries;
  final bool metadataLoading;
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
  static const _controlPointDoubleTapTimeout = Duration(milliseconds: 400);
  static const _controlPointDoubleTapSlop = 28.0;
  static const _cursorLabelGap = 14.0;
  static const _cursorLabelEstimatedWidth = 240.0;
  static const _cursorLabelEstimatedHeight = 34.0;

  late final MapController _mapController;
  final GlobalKey _mapHostKey = GlobalKey();
  final Map<String, PmtilesMapLayerConfig> _layerCache = {};
  final Map<String, PmtilesSource> _layerSources = {};
  final Map<String, String> _layerLoadErrors = {};
  List<PmtilesMapLayerConfig> _visibleMapLayers = const [];
  String? _activeLayerCatalogId;
  PmtilesArchiveEntry? _resolvedActiveEntry;
  String _archiveSelectionDebug = '';
  Timer? _viewportLayerUpdateTimer;
  int _layerLoadGeneration = 0;
  Size? _lastMapSize;

  LatLng? _cursorLocation;
  Offset? _cursorScreenPosition;
  Offset? _radialMenuCenter;
  LatLng? _radialMenuPoint;
  Offset? _searchCoordinateRadialCenter;
  SearchCoordinateMarker? _searchCoordinateRadialMarker;

  Timer? _longPressTimer;
  Offset? _pendingLongPressLocal;
  LatLng? _pendingLongPressPoint;
  Offset? _tapDownLocal;
  bool _longPressTriggered = false;
  bool _lineDrawingPressActive = false;
  bool _circleDrawingPressActive = false;
  bool _rectangleDrawingPressActive = false;
  bool _polygonDrawingPressActive = false;
  bool _bearingPlotPressActive = false;
  DateTime? _lastDrawingCompleteTapAt;
  Offset? _lastDrawingCompleteTapLocal;
  bool _primaryPointerGestureHandled = false;
  bool _activePointerDown = false;
  bool _pendingSelectionTapOnUp = false;
  Offset? _selectionPointerDownLocal;
  int? _pendingLineControlIndex;
  int? _draggingLineControlIndex;
  LineGeometry? _lineEditPreviewGeometry;
  Map<UuidValue, LineGeometry> _lineEditPreviewGeometries = const {};
  List<CoLocatedLineEndpoint> _coLocatedEndpointDrags = const [];
  LatLng? _frozenMapCenterDuringVertexEdit;
  double? _frozenMapZoomDuringVertexEdit;
  DateTime? _lastControlPointTapAt;
  int? _lastControlPointTapIndex;
  Offset? _lastControlPointTapLocal;
  bool _polygonVertexEditActive = false;
  int? _pendingPolygonVertexIndex;
  int? _draggingPolygonVertexIndex;
  PolygonGeometry? _polygonEditPreviewGeometry;
  Timer? _polygonVertexLongPressTimer;
  DateTime? _lastPolygonBodyTapAt;
  Offset? _lastPolygonBodyTapLocal;
  int _radialMenuPage = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    setBrowserContextMenuEnabled(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleVisibleLayerUpdate(preload: true, immediate: true);
    });
  }

  @override
  void dispose() {
    _viewportLayerUpdateTimer?.cancel();
    _longPressTimer?.cancel();
    _polygonVertexLongPressTimer?.cancel();
    _releaseAllLayerArchives();
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

    final oldIds = oldWidget.enabledEntries.map((entry) => entry.id).toSet();
    final newIds = widget.enabledEntries.map((entry) => entry.id).toSet();
    if (oldIds != newIds) {
      _evictRemovedLayers(oldIds.difference(newIds));
      _resolvedActiveEntry = null;
      _archiveSelectionDebug = '';
      _scheduleVisibleLayerUpdate(preload: true, immediate: true);
    } else if (oldWidget.enabledEntries != widget.enabledEntries ||
        (oldWidget.metadataLoading && !widget.metadataLoading)) {
      if (widget.enabledEntries.isEmpty) {
        _evictAllLayers();
        setState(() {
          _activeLayerCatalogId = null;
          _resolvedActiveEntry = null;
          _archiveSelectionDebug = '';
          _visibleMapLayers = const [];
        });
      } else {
        _scheduleVisibleLayerUpdate(preload: true, immediate: true);
      }
    }
  }

  double _currentViewportZoom() {
    try {
      return _mapController.camera.zoom;
    } catch (_) {
      return widget.viewport.zoom;
    }
  }

  void _scheduleVisibleLayerUpdate({
    bool preload = false,
    bool immediate = false,
  }) {
    _viewportLayerUpdateTimer?.cancel();
    void run() => unawaited(_runVisibleLayerSync(preload: preload));
    if (immediate) {
      run();
      return;
    }
    _viewportLayerUpdateTimer = Timer(
      const Duration(milliseconds: 250),
      run,
    );
  }

  Future<void> _runVisibleLayerSync({required bool preload}) async {
    try {
      await _syncMapLayers(preload: preload);
    } catch (error, stackTrace) {
      AppLogger.logPmtiles.error(
        '🗺️ Uncaught map layer sync failure',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  LatLngBounds _currentViewportBounds() {
    try {
      return _mapController.camera.visibleBounds;
    } catch (_) {
      return approximateVisibleBounds(
        widget.viewport,
        mapSize: _lastMapSize,
      );
    }
  }

  LatLng _currentViewportCenter() {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return widget.viewport.center;
    }
  }

  void _publishPmtilesLoadStatus() {
    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final entries = widget.enabledEntries;
    if (widget.metadataLoading) {
      ref
          .read(pmtilesLoadStatusProvider.notifier)
          .update(
            PmtilesLoadStatus(
              isReady: false,
              isLoading: true,
              statusMessage: l10n.statusLoading,
            ),
          );
      return;
    }

    if (entries.isEmpty) {
      ref
          .read(pmtilesLoadStatusProvider.notifier)
          .update(
            PmtilesLoadStatus.noLayers,
          );
      return;
    }

    final loadedCount = entries
        .where((entry) => _layerCache.containsKey(entry.id))
        .length;
    final selectedEntries = _resolvedActiveEntry == null
        ? selectArchivesForViewport(
            entries: entries,
            viewportBounds: _currentViewportBounds(),
            viewportCenter: _currentViewportCenter(),
            viewportZoom: _currentViewportZoom(),
          )
        : [_resolvedActiveEntry!];
    final activeEntry = selectedEntries.isEmpty ? null : selectedEntries.first;
    final activeLayer = activeEntry == null
        ? null
        : _layerCache[activeEntry.id];
    final activeReady = activeLayer != null && _visibleMapLayers.isNotEmpty;

    if (activeReady && activeEntry != null) {
      ref
          .read(pmtilesLoadStatusProvider.notifier)
          .update(
            PmtilesLoadStatus(
              isReady: true,
              isLoading: false,
              enabledCount: entries.length,
              loadedCount: loadedCount,
              activeLayerName: activeEntry.name,
              statusMessage: 'Map tiles are active for the current view.',
            ),
          );
      return;
    }

    if (activeEntry != null) {
      final loadError = _layerLoadErrors[activeEntry.id];
      if (loadError != null) {
        ref
            .read(pmtilesLoadStatusProvider.notifier)
            .update(
              PmtilesLoadStatus(
                isReady: false,
                isLoading: false,
                enabledCount: entries.length,
                loadedCount: loadedCount,
                loadingLayerName: activeEntry.name,
                statusMessage: 'Failed to open ${activeEntry.name}.',
                failureMessage: loadError,
              ),
            );
        return;
      }

      ref
          .read(pmtilesLoadStatusProvider.notifier)
          .update(
            PmtilesLoadStatus(
              isReady: false,
              isLoading: true,
              enabledCount: entries.length,
              loadedCount: loadedCount,
              loadingLayerName: activeEntry.name,
              statusMessage: l10n.mapTilesOpeningProgress(activeEntry.name),
            ),
          );
      return;
    }

    if (loadedCount < entries.length) {
      final pending = entries.firstWhere(
        (entry) => !_layerCache.containsKey(entry.id),
        orElse: () => entries.first,
      );
      ref
          .read(pmtilesLoadStatusProvider.notifier)
          .update(
            PmtilesLoadStatus(
              isReady: false,
              isLoading: true,
              enabledCount: entries.length,
              loadedCount: loadedCount,
              loadingLayerName: pending.name,
              statusMessage: 'Preparing visible map tile layers…',
            ),
          );
      return;
    }

    ref
        .read(pmtilesLoadStatusProvider.notifier)
        .update(
          PmtilesLoadStatus(
            isReady: false,
            isLoading: false,
            enabledCount: entries.length,
            loadedCount: loadedCount,
            statusMessage:
                'Visible map layers do not cover the current map view. '
                'Pan or zoom to an area covered by an enabled layer.',
          ),
        );
  }

  void _evictRemovedLayers(Set<String> removedIds) {
    for (final id in removedIds) {
      _releaseLayerArchive(id);
      _layerCache.remove(id);
      _layerLoadErrors.remove(id);
    }
  }

  void _evictAllLayers() {
    _releaseAllLayerArchives();
    _layerCache.clear();
    _layerLoadErrors.clear();
  }

  void _releaseLayerArchive(String catalogId) {
    final source = _layerSources.remove(catalogId);
    if (source == null) {
      return;
    }
    unawaited(
      releasePmtilesArchive(source).catchError(
        (Object error, StackTrace stackTrace) {
          AppLogger.logPmtiles.error(
            '🗺️ Failed to release PMTiles archive',
            error: error,
            stackTrace: stackTrace,
            data: catalogId,
          );
        },
      ),
    );
  }

  void _releaseAllLayerArchives() {
    final catalogIds = _layerSources.keys.toList(growable: false);
    for (final catalogId in catalogIds) {
      _releaseLayerArchive(catalogId);
    }
  }

  Future<void> _loadLayerEntry(
    PmtilesArchiveEntry entry,
    int generation,
  ) async {
    try {
      final layer = await buildPmtilesMapLayer(
        entry.source,
        catalogId: entry.id,
      );
      if (mounted && generation == _layerLoadGeneration) {
        _layerCache[entry.id] = layer;
        _layerSources[entry.id] = entry.source;
        _layerLoadErrors.remove(entry.id);
      } else {
        await releasePmtilesArchive(entry.source);
      }
    } catch (error, stackTrace) {
      if (mounted && generation == _layerLoadGeneration) {
        _layerLoadErrors[entry.id] = error.toString();
      }
      AppLogger.logPmtiles.error(
        '🗺️ Failed to load PMTiles layer',
        error: error,
        stackTrace: stackTrace,
        data: 'id=${entry.id} name="${entry.name}"',
      );
    } finally {
      if (mounted && generation == _layerLoadGeneration) {
        _publishPmtilesLoadStatus();
      }
    }
  }

  Future<void> _loadBackgroundLayers(
    int generation,
    List<PmtilesArchiveEntry> entries,
  ) async {
    for (final entry in entries) {
      if (!mounted || generation != _layerLoadGeneration) {
        return;
      }
      if (_layerCache.containsKey(entry.id)) {
        continue;
      }
      await _loadLayerEntry(entry, generation);
    }
  }

  Future<void> _syncMapLayers({required bool preload}) async {
    if (!mounted) {
      return;
    }

    if (widget.enabledEntries.isEmpty) {
      if (_visibleMapLayers.isNotEmpty || _activeLayerCatalogId != null) {
        setState(() {
          _visibleMapLayers = const [];
          _activeLayerCatalogId = null;
        });
      }
      _publishPmtilesLoadStatus();
      return;
    }

    _publishPmtilesLoadStatus();

    try {
      final resolveGeneration = ++_layerLoadGeneration;
      final selection = await resolveActiveArchiveForViewport(
        entries: widget.enabledEntries,
        viewportBounds: _currentViewportBounds(),
        viewportCenter: _currentViewportCenter(),
        viewportZoom: _currentViewportZoom(),
      );
      if (!mounted || resolveGeneration != _layerLoadGeneration) {
        return;
      }
      _resolvedActiveEntry = selection.entry;
      _archiveSelectionDebug = selection.debugSummary;
      final activeEntry = selection.entry;
      var generation = _layerLoadGeneration;

      if (activeEntry != null && !_layerCache.containsKey(activeEntry.id)) {
        generation = ++_layerLoadGeneration;
        await _loadLayerEntry(activeEntry, generation);
        if (!mounted || generation != _layerLoadGeneration) {
          return;
        }
        _applyVisibleLayerSelection();
      }

      if (preload) {
        final rankedEntries = rankArchivesForViewport(
          entries: widget.enabledEntries,
          viewportBounds: _currentViewportBounds(),
          viewportCenter: _currentViewportCenter(),
          viewportZoom: _currentViewportZoom(),
        );
        final backgroundEntries = rankedEntries
            .where((entry) => !_layerCache.containsKey(entry.id))
            .where((entry) => entry.id != activeEntry?.id)
            .toList();
        if (backgroundEntries.isNotEmpty) {
          generation = ++_layerLoadGeneration;
          unawaited(
            _loadBackgroundLayers(generation, backgroundEntries).catchError(
              (Object error, StackTrace stackTrace) {
                AppLogger.logPmtiles.error(
                  '🗺️ Uncaught background PMTiles preload failure',
                  error: error,
                  stackTrace: stackTrace,
                );
              },
            ),
          );
        }
      }

      _applyVisibleLayerSelection();
      _publishPmtilesLoadStatus();
    } catch (error, stackTrace) {
      AppLogger.logPmtiles.error(
        '🗺️ Failed to sync visible PMTiles layers',
        error: error,
        stackTrace: stackTrace,
      );
      ref
          .read(pmtilesLoadStatusProvider.notifier)
          .update(
            PmtilesLoadStatus(
              isReady: false,
              isLoading: false,
              enabledCount: widget.enabledEntries.length,
              loadedCount: _layerCache.length,
              statusMessage: 'Failed to prepare map tiles.',
              failureMessage: error.toString(),
            ),
          );
    }
  }

  void _applyVisibleLayerSelection() {
    if (!mounted) {
      return;
    }

    final fallback = selectArchivesForViewport(
      entries: widget.enabledEntries,
      viewportBounds: _currentViewportBounds(),
      viewportCenter: _currentViewportCenter(),
      viewportZoom: _currentViewportZoom(),
    );
    final activeEntry =
        _resolvedActiveEntry ?? (fallback.isEmpty ? null : fallback.first);
    final activeLayer = activeEntry == null
        ? null
        : _layerCache[activeEntry.id];
    final nextCatalogId = activeLayer?.catalogId;

    if (nextCatalogId == _activeLayerCatalogId &&
        (activeLayer == null
            ? _visibleMapLayers.isEmpty
            : _visibleMapLayers.length == 1 &&
                  _visibleMapLayers.first.catalogId == nextCatalogId)) {
      return;
    }

    setState(() {
      _activeLayerCatalogId = nextCatalogId;
      _visibleMapLayers = activeLayer == null ? const [] : [activeLayer];
    });

    if (activeLayer != null) {
      AppLogger.logPmtiles.debug(
        '🗺️ Active PMTiles layer',
        data:
            'id=${activeEntry!.id} name="${activeEntry.name}" enabled=${widget.enabledEntries.length}',
      );
    }

    _publishPmtilesLoadStatus();
  }

  String _viewportDebugDetails() {
    final zoom = _currentViewportZoom();
    final tileZoom = tileZoomForViewport(zoom);
    final center = _currentViewportCenter();
    final centerTile = latLngToTile(center, tileZoom);
    PmtilesArchiveEntry? activeEntry = _resolvedActiveEntry;
    if (activeEntry == null) {
      for (final entry in widget.enabledEntries) {
        if (entry.id == _activeLayerCatalogId) {
          activeEntry = entry;
          break;
        }
      }
    }
    final archiveLine = activeEntry == null
        ? 'archive: none'
        : 'archive: ${activeEntry.name} (z${activeEntry.minZoom}-${activeEntry.maxZoom})';
    return [
      'zoom=${zoom.toStringAsFixed(2)} tileZ=$tileZoom',
      'center=${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}',
      'tile=${centerTile.z}/${centerTile.x}/${centerTile.y}',
      archiveLine,
      if (_archiveSelectionDebug.isNotEmpty) _archiveSelectionDebug,
    ].join('\n');
  }

  RenderBox? get _mapRenderBox =>
      _mapHostKey.currentContext?.findRenderObject() as RenderBox?;

  bool get _isMapToolActive =>
      ref.read(bearingPlotProvider).active ||
      ref.read(lineDrawingProvider).active ||
      ref.read(circleDrawingProvider).active ||
      ref.read(rectangleDrawingProvider).active ||
      ref.read(polygonDrawingProvider).active ||
      ref.read(deadReckoningProvider).active ||
      ref.read(viewshedProvider).active ||
      ref.read(slopeProvider).active;

  void _beginSelectionPointer(PointerDownEvent event, LatLng point) {
    _activePointerDown = true;
    _selectionPointerDownLocal = event.localPosition;
    _pendingSelectionTapOnUp = false;

    if (_isMapToolActive) {
      return;
    }
    if (_controlPointIndexAt(point) != null ||
        _polygonVertexIndexAt(point) != null) {
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

    final shouldApply =
        !_longPressTriggered &&
        !_isMapToolActive &&
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
    if (_lineEditPreviewGeometries.isNotEmpty) {
      return _lineEditPreviewGeometries;
    }
    final zone = _selectedLineZone();
    final preview = _lineEditPreviewGeometry;
    if (zone == null || preview == null) {
      return null;
    }
    return {zone.id: preview};
  }

  int? _controlPointIndexAt(LatLng point) {
    final geometry = _selectedLineGeometry();
    if (geometry == null) {
      return null;
    }

    return hitTestLineControlPointIndex(
      geometry: geometry,
      tap: point,
      camera: _mapController.camera,
    );
  }

  Future<void> _persistLineGeometry(LineGeometry geometry) async {
    final zone = _selectedLineZone();
    if (zone == null) {
      return;
    }

    await ref
        .read(zonesProvider.notifier)
        .updateLineGeometry(
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

  bool _removeLineControlPointAtIndex(int index) {
    final geometry = _selectedLineGeometry();
    if (geometry == null || !isInteriorLineControlPoint(geometry, index)) {
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

  void _clearControlPointDoubleTap() {
    _lastControlPointTapAt = null;
    _lastControlPointTapIndex = null;
    _lastControlPointTapLocal = null;
  }

  bool _registerControlPointTap({
    required int index,
    required Offset local,
  }) {
    final now = DateTime.now();
    final previousAt = _lastControlPointTapAt;
    final previousIndex = _lastControlPointTapIndex;
    final previousLocal = _lastControlPointTapLocal;
    final isDoubleTap =
        previousAt != null &&
        previousIndex == index &&
        previousLocal != null &&
        now.difference(previousAt) <= _controlPointDoubleTapTimeout &&
        (local - previousLocal).distance <= _controlPointDoubleTapSlop;

    if (isDoubleTap) {
      _clearControlPointDoubleTap();
      return true;
    }

    _lastControlPointTapAt = now;
    _lastControlPointTapIndex = index;
    _lastControlPointTapLocal = local;
    return false;
  }

  Future<void> _commitLineControlPointDrag(LatLng point) async {
    final index = _draggingLineControlIndex;
    final selectedZone = _selectedLineZone();
    final geometry = _selectedLineGeometry();
    final linked = List<CoLocatedLineEndpoint>.from(_coLocatedEndpointDrags);
    if (index == null || geometry == null || selectedZone == null) {
      _resetLineEditGestureState();
      return;
    }

    final updated = moveLineControlPoint(
      geometry: geometry,
      controlPointIndex: index,
      point: point,
    );
    final linkedUpdates = _movedCoLocatedEndpointGeometries(point, linked);
    _resetLineEditGestureState();
    if (updated == null) {
      return;
    }

    await _persistLineGeometry(updated);
    final notifier = ref.read(zonesProvider.notifier);
    for (final entry in linkedUpdates.entries) {
      await notifier.updateLineGeometry(
        zoneId: entry.key,
        geometry: entry.value,
      );
    }
  }

  Map<UuidValue, LineGeometry> _movedCoLocatedEndpointGeometries(
    LatLng point,
    List<CoLocatedLineEndpoint> linked,
  ) {
    if (linked.isEmpty) {
      return const {};
    }

    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final updates = <UuidValue, LineGeometry>{};
    for (final link in linked) {
      var base = updates[link.zoneId];
      if (base == null) {
        final zone = findZoneById(zones, link.zoneId);
        base = zone == null ? null : LineGeometry.fromZone(zone);
      }
      if (base == null) {
        continue;
      }
      final moved = moveLineControlPoint(
        geometry: base,
        controlPointIndex: link.controlPointIndex,
        point: point,
      );
      if (moved != null) {
        updates[link.zoneId] = moved;
      }
    }
    return updates;
  }

  void _resetLineEditGestureState() {
    if (_pendingLineControlIndex == null &&
        _draggingLineControlIndex == null &&
        _lineEditPreviewGeometry == null &&
        _lineEditPreviewGeometries.isEmpty &&
        _coLocatedEndpointDrags.isEmpty &&
        _frozenMapCenterDuringVertexEdit == null) {
      return;
    }
    setState(() {
      _pendingLineControlIndex = null;
      _draggingLineControlIndex = null;
      _lineEditPreviewGeometry = null;
      _lineEditPreviewGeometries = const {};
      _coLocatedEndpointDrags = const [];
      _frozenMapCenterDuringVertexEdit = null;
      _frozenMapZoomDuringVertexEdit = null;
    });
  }

  void _armLineControlPointEdit(int index) {
    // Freeze map panning immediately so the gesture moves the vertex instead.
    _cancelPendingLongPress();
    final camera = _mapController.camera;
    _frozenMapCenterDuringVertexEdit = camera.center;
    _frozenMapZoomDuringVertexEdit = camera.zoom;
    final geometry = _selectedLineGeometry();
    final selectedZone = _selectedLineZone();
    final linked = <CoLocatedLineEndpoint>[];
    final previews = <UuidValue, LineGeometry>{};
    if (geometry != null && selectedZone != null) {
      previews[selectedZone.id] = geometry;
      if (!isInteriorLineControlPoint(geometry, index)) {
        linked.addAll(
          findCoLocatedLineEndpoints(
            point: geometry.points[index],
            excludeZoneId: selectedZone.id,
            zones: _zonesOnMap,
          ),
        );
        for (final link in linked) {
          final zone = findZoneById(_zonesOnMap, link.zoneId);
          final otherGeometry = zone == null
              ? null
              : LineGeometry.fromZone(zone);
          if (otherGeometry != null) {
            previews[link.zoneId] = otherGeometry;
          }
        }
      }
    }
    setState(() {
      _pendingLineControlIndex = null;
      _draggingLineControlIndex = index;
      _lineEditPreviewGeometry = geometry;
      _lineEditPreviewGeometries = previews;
      _coLocatedEndpointDrags = linked;
    });
  }

  void _holdMapStillDuringVertexEdit() {
    final center = _frozenMapCenterDuringVertexEdit;
    final zoom = _frozenMapZoomDuringVertexEdit;
    if (center == null || zoom == null) {
      return;
    }
    final camera = _mapController.camera;
    if (camera.center.latitude == center.latitude &&
        camera.center.longitude == center.longitude &&
        camera.zoom == zoom) {
      return;
    }
    _mapController.move(center, zoom);
  }

  void _updateLineControlPointDrag(LatLng point) {
    final index = _draggingLineControlIndex;
    final selectedZone = _selectedLineZone();
    final geometry = _selectedLineGeometry();
    if (index == null || geometry == null || selectedZone == null) {
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

    final previews = <UuidValue, LineGeometry>{
      selectedZone.id: updated,
      ..._movedCoLocatedEndpointGeometries(point, _coLocatedEndpointDrags),
    };

    setState(() {
      _lineEditPreviewGeometry = updated;
      _lineEditPreviewGeometries = previews;
    });
  }


  MapZone? _selectedPolygonZone() {
    final selected = ref.read(selectedMapObjectProvider);
    if (selected == null || selected.kind != SelectedMapObjectKind.zone) {
      return null;
    }
    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final zone = findZoneById(zones, selected.id);
    if (zone == null || zone.type != polygonZoneType) {
      return null;
    }
    return zone;
  }

  PolygonGeometry? _selectedPolygonGeometry() {
    final preview = _polygonEditPreviewGeometry;
    if (preview != null) {
      return preview;
    }
    final zone = _selectedPolygonZone();
    if (zone == null) {
      return null;
    }
    return PolygonGeometry.fromZone(zone);
  }

  int? _polygonVertexIndexAt(LatLng point) {
    if (!_polygonVertexEditActive) {
      return null;
    }
    final geometry = _selectedPolygonGeometry();
    if (geometry == null) {
      return null;
    }
    return hitTestPolygonVertexIndex(
      geometry: geometry,
      tap: point,
      camera: _mapController.camera,
    );
  }

  void _enterPolygonVertexEdit() {
    final zone = _selectedPolygonZone();
    if (zone == null) {
      return;
    }
    setState(() {
      _polygonVertexEditActive = true;
      _polygonEditPreviewGeometry = PolygonGeometry.fromZone(zone);
    });
  }

  void _exitPolygonVertexEdit() {
    _cancelPolygonVertexLongPress();
    if (!_polygonVertexEditActive &&
        _pendingPolygonVertexIndex == null &&
        _draggingPolygonVertexIndex == null &&
        _polygonEditPreviewGeometry == null) {
      return;
    }
    setState(() {
      _polygonVertexEditActive = false;
      _pendingPolygonVertexIndex = null;
      _draggingPolygonVertexIndex = null;
      _polygonEditPreviewGeometry = null;
      if (_draggingLineControlIndex == null) {
        _frozenMapCenterDuringVertexEdit = null;
        _frozenMapZoomDuringVertexEdit = null;
      }
    });
  }

  void _cancelPolygonVertexLongPress() {
    _polygonVertexLongPressTimer?.cancel();
    _polygonVertexLongPressTimer = null;
    _pendingPolygonVertexIndex = null;
  }

  void _startPolygonVertexLongPressRemove(int index) {
    _cancelPolygonVertexLongPress();
    _cancelPendingLongPress();
    _pendingPolygonVertexIndex = index;
    _polygonVertexLongPressTimer = Timer(_longPressDuration, () {
      if (!mounted) {
        return;
      }
      final pending = _pendingPolygonVertexIndex;
      _polygonVertexLongPressTimer = null;
      if (pending != index) {
        return;
      }
      // Held still long enough — remove instead of dragging.
      _longPressTriggered = true;
      _removePolygonVertexAtIndex(index);
      _resetPolygonEditGestureState(keepEditMode: true);
    });
  }

  void _armPolygonVertexEdit(int index) {
    _cancelPendingLongPress();
    final camera = _mapController.camera;
    _frozenMapCenterDuringVertexEdit = camera.center;
    _frozenMapZoomDuringVertexEdit = camera.zoom;
    final geometry = _selectedPolygonGeometry();
    setState(() {
      _pendingPolygonVertexIndex = null;
      _draggingPolygonVertexIndex = index;
      _polygonEditPreviewGeometry = geometry;
    });
  }

  void _updatePolygonVertexDrag(LatLng point) {
    final index = _draggingPolygonVertexIndex;
    final geometry = _selectedPolygonGeometry();
    if (index == null || geometry == null) {
      return;
    }
    final updated = movePolygonVertex(
      geometry: geometry,
      vertexIndex: index,
      point: point,
    );
    if (updated == null) {
      return;
    }
    setState(() => _polygonEditPreviewGeometry = updated);
  }

  Future<void> _persistPolygonGeometry(PolygonGeometry geometry) async {
    final zone = _selectedPolygonZone();
    if (zone == null) {
      return;
    }
    await ref.read(zonesProvider.notifier).updatePolygonGeometry(
      zoneId: zone.id,
      geometry: geometry,
    );
  }

  Future<void> _commitPolygonVertexDrag(LatLng point) async {
    final index = _draggingPolygonVertexIndex;
    final geometry = _selectedPolygonGeometry();
    if (index == null || geometry == null) {
      _resetPolygonEditGestureState(keepEditMode: true);
      return;
    }
    final updated = movePolygonVertex(
      geometry: geometry,
      vertexIndex: index,
      point: point,
    );
    _resetPolygonEditGestureState(keepEditMode: true);
    if (updated == null) {
      return;
    }
    setState(() => _polygonEditPreviewGeometry = updated);
    await _persistPolygonGeometry(updated);
  }

  void _resetPolygonEditGestureState({required bool keepEditMode}) {
    _cancelPolygonVertexLongPress();
    setState(() {
      _draggingPolygonVertexIndex = null;
      if (!keepEditMode) {
        _polygonVertexEditActive = false;
        _polygonEditPreviewGeometry = null;
      }
      if (_draggingLineControlIndex == null) {
        _frozenMapCenterDuringVertexEdit = null;
        _frozenMapZoomDuringVertexEdit = null;
      }
    });
  }

  Future<void> _insertPolygonVertexAt(LatLng point) async {
    final geometry = _selectedPolygonGeometry();
    if (geometry == null || !_polygonVertexEditActive) {
      return;
    }
    final updated = insertPolygonVertex(
      geometry: geometry,
      tap: point,
      camera: _mapController.camera,
    );
    if (updated == null) {
      return;
    }
    setState(() => _polygonEditPreviewGeometry = updated);
    await _persistPolygonGeometry(updated);
  }

  bool _removePolygonVertexAtIndex(int index) {
    final geometry = _selectedPolygonGeometry();
    if (geometry == null) {
      return false;
    }
    final updated = removePolygonVertex(
      geometry: geometry,
      vertexIndex: index,
    );
    if (updated == null) {
      return false;
    }
    setState(() => _polygonEditPreviewGeometry = updated);
    unawaited(_persistPolygonGeometry(updated));
    return true;
  }

  void _clearPolygonBodyDoubleTap() {
    _lastPolygonBodyTapAt = null;
    _lastPolygonBodyTapLocal = null;
  }

  bool _registerPolygonBodyDoubleTap(Offset local) {
    final now = DateTime.now();
    final previousAt = _lastPolygonBodyTapAt;
    final previousLocal = _lastPolygonBodyTapLocal;
    final isDoubleTap =
        previousAt != null &&
        previousLocal != null &&
        now.difference(previousAt) <= _controlPointDoubleTapTimeout &&
        (local - previousLocal).distance <= _controlPointDoubleTapSlop;
    if (isDoubleTap) {
      _clearPolygonBodyDoubleTap();
      return true;
    }
    _lastPolygonBodyTapAt = now;
    _lastPolygonBodyTapLocal = local;
    return false;
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

  void _clearDrawingCompleteDoubleTap() {
    _lastDrawingCompleteTapAt = null;
    _lastDrawingCompleteTapLocal = null;
  }

  /// Double-tap to commit the second point of an in-progress draw tool.
  bool _registerDrawingCompleteTap(Offset local) {
    final now = DateTime.now();
    final previousAt = _lastDrawingCompleteTapAt;
    final previousLocal = _lastDrawingCompleteTapLocal;
    final isDoubleTap =
        previousAt != null &&
        previousLocal != null &&
        now.difference(previousAt) <= _controlPointDoubleTapTimeout &&
        (local - previousLocal).distance <= _controlPointDoubleTapSlop;

    if (isDoubleTap) {
      _clearDrawingCompleteDoubleTap();
      return true;
    }

    _lastDrawingCompleteTapAt = now;
    _lastDrawingCompleteTapLocal = local;
    return false;
  }

  void _completeActiveDrawingAt(LatLng point) {
    _clearDrawingCompleteDoubleTap();
    final lineDrawing = ref.read(lineDrawingProvider);
    if (lineDrawing.active && lineDrawing.awaitingEnd) {
      unawaited(_finalizeLineDrawing(lineDrawing.previewEnd ?? point));
      return;
    }
    final circleDrawing = ref.read(circleDrawingProvider);
    if (circleDrawing.active && circleDrawing.awaitingRadius) {
      unawaited(_finalizeCircleDrawing(point));
      return;
    }
    final rectangleDrawing = ref.read(rectangleDrawingProvider);
    if (rectangleDrawing.active && rectangleDrawing.awaitingSecondPoint) {
      unawaited(
        _finalizeRectangleDrawing(rectangleDrawing.previewPoint ?? point),
      );
      return;
    }
    final polygonDrawing = ref.read(polygonDrawingProvider);
    if (polygonDrawing.active && polygonDrawing.canFinish) {
      unawaited(_finalizePolygonDrawing());
      return;
    }
    final bearingPlot = ref.read(bearingPlotProvider);
    if (bearingPlot.active) {
      final anchor = bearingPlot.anchor;
      final previewEnd = bearingPlot.previewEnd ?? point;
      if (anchor != null && !areLinePointsTooClose(anchor, previewEnd)) {
        unawaited(_finalizeBearingPlot());
      }
    }
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
      final hit = _hitMapObjectAtPoint(menuPoint);
      if (hit != null) {
        if (hit.kind == SelectedMapObjectKind.marker) {
          final markers = widget.markersAsync.valueOrNull;
          final marker = markers == null
              ? null
              : findMarkerById(markers, hit.id);
          if (marker != null) {
            unawaited(_handleMarkerLongPress(marker));
            return;
          }
        }
        _selectMapObject(hit, openDetails: true);
        return;
      }
      _openRadialMenuAt(center, menuPoint);
    });
  }

  Future<void> _handleMarkerLongPress(MapMarker marker) async {
    if (_isMapToolActive) {
      return;
    }

    final selectedId = ref.read(selectedMapObjectProvider).selectedMarkerId;
    final markers = widget.markersAsync.valueOrNull ?? const <MapMarker>[];
    final fromMarker = selectedId == null
        ? null
        : findMarkerById(markers, selectedId);

    // No other marker selected, or long-pressing the same pin → open details.
    if (fromMarker == null || fromMarker.id == marker.id) {
      _selectMapObject(
        SelectedMapObject(
          kind: SelectedMapObjectKind.marker,
          id: marker.id,
        ),
        openDetails: true,
      );
      return;
    }

    final start = LatLng(fromMarker.latitude, fromMarker.longitude);
    final end = LatLng(marker.latitude, marker.longitude);
    if (areLinePointsTooClose(start, end)) {
      return;
    }

    final created = await createLineBetweenPoints(
      context: context,
      ref: ref,
      start: start,
      end: end,
    );
    if (!mounted || !created) {
      return;
    }

    // Keep the destination selected so you can chain waypoints A→B→C.
    _selectMapObject(
      SelectedMapObject(
        kind: SelectedMapObjectKind.marker,
        id: marker.id,
      ),
    );
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
        width: mapMarkerRenderWidth(ref.read(mapMarkerSizeScaleProvider)),
        height: mapMarkerRenderHeight(ref.read(mapMarkerSizeScaleProvider)),
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

    final polygonId = hitTestPolygonAtPoint(
      point: point,
      zones: visibleZones,
      camera: _mapController.camera,
    );
    if (polygonId != null) {
      return SelectedMapObject(
        kind: SelectedMapObjectKind.zone,
        id: polygonId,
      );
    }

    return null;
  }

  void _revealSelectedObjectInSidebar(SelectedMapObject selection) {
    final layerId = switch (selection.kind) {
      SelectedMapObjectKind.marker =>
        widget.markersAsync.valueOrNull
            ?.where((marker) => marker.id == selection.id)
            .map((marker) => marker.layerId)
            .firstOrNull,
      SelectedMapObjectKind.zone =>
        widget.zonesAsync.valueOrNull
            ?.where((zone) => zone.id == selection.id)
            .map((zone) => zone.layerId)
            .firstOrNull,
    };

    ref
        .read(sidebarProvider.notifier)
        .revealMapObject(
          kind: selection.kind,
          layerId: layerId,
        );
  }

  void _selectMapObject(
    SelectedMapObject selection, {
    bool openDetails = false,
  }) {
    // Tap selects only; long-press opens details (markers and zones).
    ref
        .read(selectedMapObjectProvider.notifier)
        .select(selection, openDetails: openDetails);
    _revealSelectedObjectInSidebar(selection);
  }

  void _handleSecondaryMapTap(TapPosition tapPosition, LatLng point) {
    if (_isMapToolActive) {
      return;
    }

    _cancelPendingLongPress();
    final local =
        tapPosition.relative ??
        _mapRenderBox?.globalToLocal(tapPosition.global);
    if (local == null) {
      return;
    }
    _openRadialMenuAt(local, point);
  }

  void _handlePointerDown(PointerDownEvent event, LatLng point) {
    _longPressTriggered = false;
    _pendingLineControlIndex = null;
    _tapDownLocal = event.localPosition;
    _updateCursor(event.position, point);

    final box = _mapRenderBox;
    if (box == null) {
      return;
    }

    if ((_radialMenuCenter != null || _searchCoordinateRadialCenter != null) &&
        event.buttons == kPrimaryMouseButton) {
      _closeRadialMenu();
    }

    if (ref.read(bearingPlotProvider).active) {
      _cancelPendingLongPress();
      _bearingPlotPressActive = true;
      _updateBearingPlotPreview(point);
      return;
    }

    if (ref.read(deadReckoningProvider).active) {
      _cancelPendingLongPress();
      return;
    }

    if (ref.read(viewshedProvider).active) {
      _cancelPendingLongPress();
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

    if (ref.read(polygonDrawingProvider).active) {
      _cancelPendingLongPress();
      _polygonDrawingPressActive = true;
      return;
    }

    final polygonVertexIndex = _polygonVertexIndexAt(point);
    if (polygonVertexIndex != null) {
      // Drag immediately (like line vertices); long-hold still removes.
      _armPolygonVertexEdit(polygonVertexIndex);
      _startPolygonVertexLongPressRemove(polygonVertexIndex);
      return;
    }

    final controlPointIndex = _controlPointIndexAt(point);
    if (controlPointIndex != null) {
      // Arm edit immediately so InteractiveFlag.drag turns off before the map
      // can pan. Short-press vs drag is decided on pointer-up.
      _armLineControlPointEdit(controlPointIndex);
      return;
    }

    if (event.buttons == kPrimaryMouseButton) {
      _startLongPressTimer(event.localPosition, point);
    }
  }

  void _handlePointerMove(PointerMoveEvent event, LatLng point) {
    _updateCursor(event.position, point);

    if ((_radialMenuCenter != null || _searchCoordinateRadialCenter != null) &&
        _tapDownLocal != null) {
      if ((event.localPosition - _tapDownLocal!).distance >
          _longPressMoveTolerance) {
        _closeRadialMenu();
      }
    }

    if (ref.read(bearingPlotProvider).active && _bearingPlotPressActive) {
      _updateBearingPlotPreview(point);
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _controlPointDoubleTapSlop) {
        _clearDrawingCompleteDoubleTap();
      }
    }

    if (ref.read(lineDrawingProvider).awaitingEnd && _lineDrawingPressActive) {
      ref
          .read(lineDrawingProvider.notifier)
          .setPreviewEnd(_snapLinePoint(point));
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _controlPointDoubleTapSlop) {
        _clearDrawingCompleteDoubleTap();
      }
    }

    if (ref.read(circleDrawingProvider).awaitingRadius &&
        _circleDrawingPressActive) {
      _updateCirclePreviewRadius(point);
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _controlPointDoubleTapSlop) {
        _clearDrawingCompleteDoubleTap();
      }
    }

    if (ref.read(rectangleDrawingProvider).awaitingSecondPoint &&
        _rectangleDrawingPressActive) {
      _updateRectanglePreview(point);
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _controlPointDoubleTapSlop) {
        _clearDrawingCompleteDoubleTap();
      }
    }

    if (ref.read(polygonDrawingProvider).active) {
      ref.read(polygonDrawingProvider.notifier).setPreviewPoint(point);
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _controlPointDoubleTapSlop) {
        _clearDrawingCompleteDoubleTap();
      }
    }

    if (_pendingPolygonVertexIndex != null &&
        _tapDownLocal != null &&
        (event.localPosition - _tapDownLocal!).distance >
            _longPressMoveTolerance) {
      _cancelPolygonVertexLongPress();
    }

    if (_draggingPolygonVertexIndex != null) {
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _longPressMoveTolerance) {
        _clearControlPointDoubleTap();
      }
      _updatePolygonVertexDrag(point);
    }

    if (_draggingLineControlIndex != null) {
      if (_tapDownLocal != null &&
          (event.localPosition - _tapDownLocal!).distance >
              _longPressMoveTolerance) {
        _clearControlPointDoubleTap();
      }
      _updateLineControlPointDrag(point);
    }

    final pendingLocal = _pendingLongPressLocal;
    if (pendingLocal == null || _longPressTimer == null) {
      return;
    }

    if ((event.localPosition - pendingLocal).distance >
        _longPressMoveTolerance) {
      _cancelPendingLongPress();
    }
  }

  void _handlePointerUp(PointerUpEvent event, LatLng point) {
    _primaryPointerGestureHandled = false;
    final lineDrawing = ref.read(lineDrawingProvider);
    final bearingPlot = ref.read(bearingPlotProvider);

    if (_draggingLineControlIndex != null) {
      final controlIndex = _draggingLineControlIndex!;
      if (_isShortPress(event)) {
        // Tap (not a drag): discard the armed edit and keep tap semantics.
        _resetLineEditGestureState();
        final geometry = _selectedLineGeometry();
        if (geometry != null &&
            controlIndex >= 0 &&
            controlIndex < geometry.points.length) {
          if (_registerControlPointTap(
            index: controlIndex,
            local: event.localPosition,
          )) {
            if (isInteriorLineControlPoint(geometry, controlIndex)) {
              _removeLineControlPointAtIndex(controlIndex);
            } else {
              _beginBearingPlot(geometry.points[controlIndex]);
            }
          }
        }
      } else {
        _clearControlPointDoubleTap();
        unawaited(_commitLineControlPointDrag(point));
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (bearingPlot.active && !_longPressTriggered) {
      // Preview follows press/drag; double-tap commits the plot.
      if (_bearingPlotPressActive) {
        _updateBearingPlotPreview(point);
        if (_isShortPress(event) &&
            _registerDrawingCompleteTap(event.localPosition)) {
          _completeActiveDrawingAt(point);
        } else if (!_isShortPress(event)) {
          _clearDrawingCompleteDoubleTap();
        }
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (lineDrawing.active && !_longPressTriggered) {
      // End point commits on double-tap so endpoints can be dragged freely.
      if (lineDrawing.awaitingEnd && _lineDrawingPressActive) {
        ref
            .read(lineDrawingProvider.notifier)
            .setPreviewEnd(_snapLinePoint(point));
        if (_isShortPress(event) &&
            _registerDrawingCompleteTap(event.localPosition)) {
          _completeActiveDrawingAt(point);
        } else if (!_isShortPress(event)) {
          _clearDrawingCompleteDoubleTap();
        }
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
        _updateCirclePreviewRadius(point);
        if (_isShortPress(event) &&
            _registerDrawingCompleteTap(event.localPosition)) {
          _completeActiveDrawingAt(point);
        } else if (!_isShortPress(event)) {
          _clearDrawingCompleteDoubleTap();
        }
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
        _updateRectanglePreview(point);
        if (_isShortPress(event) &&
            _registerDrawingCompleteTap(event.localPosition)) {
          _completeActiveDrawingAt(point);
        } else if (!_isShortPress(event)) {
          _clearDrawingCompleteDoubleTap();
        }
      } else if (_isShortPress(event)) {
        _cancelRectangleDrawing();
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (_draggingPolygonVertexIndex != null) {
      _cancelPolygonVertexLongPress();
      if (_isShortPress(event)) {
        // Quick tap — do not move or remove.
        _resetPolygonEditGestureState(keepEditMode: true);
      } else {
        unawaited(_commitPolygonVertexDrag(point));
      }
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    if (_pendingPolygonVertexIndex != null) {
      // Long-press remove already handled in the timer, or was cancelled.
      _cancelPolygonVertexLongPress();
      _primaryPointerGestureHandled = true;
      _clearPointerDownSelectionState();
      _resetLineDrawGestureState();
      _cancelPendingLongPress();
      return;
    }

    final polygonDrawing = ref.read(polygonDrawingProvider);
    if (polygonDrawing.active && !_longPressTriggered) {
      if (_polygonDrawingPressActive) {
        ref.read(polygonDrawingProvider.notifier).setPreviewPoint(point);
        if (_isShortPress(event) &&
            _registerDrawingCompleteTap(event.localPosition)) {
          _completeActiveDrawingAt(point);
        } else if (_isShortPress(event)) {
          ref.read(polygonDrawingProvider.notifier).addVertex(point);
        } else {
          _clearDrawingCompleteDoubleTap();
        }
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
    if (_longPressTriggered ||
        _radialMenuCenter != null ||
        _searchCoordinateRadialCenter != null) {
      return;
    }
    if (_isMapToolActive) {
      return;
    }
    _applyMapSelectionAt(point);
    _clearPointerDownSelectionState();
  }

  void _resetLineDrawGestureState() {
    _lineDrawingPressActive = false;
    _circleDrawingPressActive = false;
    _rectangleDrawingPressActive = false;
    _polygonDrawingPressActive = false;
    _bearingPlotPressActive = false;
    _tapDownLocal = null;
  }


  Widget _polygonEditingBanner() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                Icons.polyline,
                color: theme.colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.polygonEditingHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _exitPolygonVertexEdit,
                child: Text(
                  l10n.actionDone,
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lineEditingBanner() {
    final theme = Theme.of(context);
    const message =
        'Tap the line to add a curve point · drag endpoints or mid-points to move · co-located endpoints move together · double-tap a mid-point to remove · double-tap an endpoint to plot a bearing';

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
    _clearDrawingCompleteDoubleTap();
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
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref
        .read(bearingPlotProvider.notifier)
        .begin(
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
    ref
        .read(bearingPlotProvider.notifier)
        .updatePlot(
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
    _clearDrawingCompleteDoubleTap();
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
    if (_isMapToolActive) {
      return;
    }

    final hit = _hitMapObjectAtPoint(point);
    final current = ref.read(selectedMapObjectProvider);
    final notifier = ref.read(selectedMapObjectProvider.notifier);

    if (current == null) {
      if (hit != null) {
        if (hit.kind == SelectedMapObjectKind.zone) {
          final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
          final zone = findZoneById(zones, hit.id);
          if (zone?.type == polygonZoneType) {
            final local = _selectionPointerDownLocal ?? Offset.zero;
            _selectMapObject(hit);
            if (_registerPolygonBodyDoubleTap(local)) {
              _enterPolygonVertexEdit();
            }
            return;
          }
        }
        _clearPolygonBodyDoubleTap();
        _selectMapObject(hit);
      }
      return;
    }

    if (hit == null) {
      _exitPolygonVertexEdit();
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
        if (zone?.type == polygonZoneType) {
          final local = _selectionPointerDownLocal ?? Offset.zero;
          if (_polygonVertexEditActive) {
            // Double-click between vertices (on an edge) inserts a point.
            final geometry = _selectedPolygonGeometry();
            final onEdge = geometry != null &&
                _polygonVertexIndexAt(point) == null &&
                isNearPolygonEdge(
                  geometry: geometry,
                  tap: point,
                  camera: _mapController.camera,
                );
            if (onEdge && _registerPolygonBodyDoubleTap(local)) {
              unawaited(_insertPolygonVertexAt(point));
            }
            return;
          }
          if (_registerPolygonBodyDoubleTap(local)) {
            _enterPolygonVertexEdit();
            return;
          }
          // Keep selection; waiting for possible second tap to enter edit.
          return;
        }
      }
      _exitPolygonVertexEdit();
      notifier.clear();
      return;
    }

    _exitPolygonVertexEdit();
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
      RectangleCreationMode.centerExtent => boundsFromCenterExtent(
        anchor,
        point,
      ),
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
    _resetLineEditGestureState();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    _cancelPendingLongPress();
  }

  void _copyRadialMenuCoordinates() {
    final point = _radialMenuPoint;
    _closeRadialMenu();
    if (point == null) {
      return;
    }
    unawaited(copyCoordinatesToClipboard(context, point));
  }

  MapMarker? _selectedMarker() {
    final selectedMarkerId = ref
        .read(selectedMapObjectProvider)
        .selectedMarkerId;
    final markers = widget.markersAsync.valueOrNull ?? const <MapMarker>[];
    if (selectedMarkerId == null) {
      return null;
    }
    return findMarkerById(markers, selectedMarkerId);
  }

  LatLng? _selectedMarkerPoint() {
    final selectedMarker = _selectedMarker();
    if (selectedMarker == null) {
      return null;
    }
    return LatLng(selectedMarker.latitude, selectedMarker.longitude);
  }

  void _beginLineDrawing() {
    final point = _selectedMarkerPoint() ?? _radialMenuPoint;

    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();
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

  LatLng? _deadReckoningAnchor() {
    final selectedMarker = _selectedMarkerPoint();
    if (selectedMarker != null) {
      return selectedMarker;
    }

    final device = ref.read(deviceLocationProvider);
    if (device.hasFix && device.position != null) {
      return device.position;
    }

    return _radialMenuPoint;
  }

  void _beginDeadReckoning() {
    final anchor = _deadReckoningAnchor();
    _closeRadialMenu();
    if (anchor == null) {
      return;
    }

    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();

    final device = ref.read(deviceLocationProvider);
    final heading = device.headingDegrees;
    ref
        .read(deadReckoningProvider.notifier)
        .begin(
          anchor: anchor,
          headingTrueDegrees: heading,
          paceLengthMeters: ref.read(paceLengthProvider),
        );
  }

  void _beginViewshed() {
    final selectedMarker = _selectedMarker();
    final point = selectedMarker == null
        ? _radialMenuPoint
        : LatLng(selectedMarker.latitude, selectedMarker.longitude);
    _closeRadialMenu();
    if (point == null) {
      return;
    }

    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();

    unawaited(
      ref
          .read(viewshedProvider.notifier)
          .begin(
            observer: point,
            antennaHeightMeters: defaultAntennaHeightForMarkerIcon(
              selectedMarker?.icon,
            ),
          ),
    );
  }

  void _cancelViewshed() {
    ref.read(viewshedProvider.notifier).reset();
  }

  void _beginSlope() {
    final point = _selectedMarkerPoint() ?? _radialMenuPoint;
    _closeRadialMenu();
    if (point == null) {
      return;
    }

    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();

    unawaited(ref.read(slopeProvider.notifier).begin(center: point));
  }

  void _cancelSlope() {
    ref.read(slopeProvider.notifier).reset();
  }

  Future<void> _finalizeDeadReckoningMarker() async {
    final state = ref.read(deadReckoningProvider);
    final end = state.previewEnd;
    if (end == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final created = await createMarkerAtPoint(
      context: context,
      ref: ref,
      point: end,
      defaultName: l10n.mapDeadReckoningMarkerName,
    );
    if (!mounted || !created) {
      return;
    }
    ref.read(deadReckoningProvider.notifier).reset();
  }

  Future<void> _finalizeDeadReckoningLine() async {
    final state = ref.read(deadReckoningProvider);
    final start = state.anchor;
    final end = state.previewEnd;
    if (start == null || end == null) {
      return;
    }
    if (areLinePointsTooClose(start, end)) {
      return;
    }

    final created = await createLineBetweenPoints(
      context: context,
      ref: ref,
      start: start,
      end: end,
    );
    if (!mounted || !created) {
      return;
    }
    ref.read(deadReckoningProvider.notifier).reset();
  }

  void _cancelDeadReckoning() {
    ref.read(deadReckoningProvider.notifier).reset();
  }

  void _cancelLineDrawing() {
    _resetLineDrawGestureState();
    _dismissLineInteraction();
  }

  void _beginCircleDrawing() {
    final point = _selectedMarkerPoint() ?? _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();
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
    _clearDrawingCompleteDoubleTap();
    _resetLineDrawGestureState();
    ref.read(circleDrawingProvider.notifier).reset();
  }

  void _beginCenterRectDrawing() {
    final point = _selectedMarkerPoint() ?? _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();
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
    ref.read(polygonDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();
    final notifier = ref.read(rectangleDrawingProvider.notifier);
    if (point != null) {
      notifier.beginCorners(point);
      if (_cursorLocation != null) {
        notifier.setPreviewPoint(_cursorLocation!);
      }
    }
  }

  void _cancelRectangleDrawing() {
    _clearDrawingCompleteDoubleTap();
    _resetLineDrawGestureState();
    ref.read(rectangleDrawingProvider.notifier).reset();
  }

  void _beginPolygonDrawing() {
    final point = _selectedMarkerPoint() ?? _radialMenuPoint;
    _closeRadialMenu();
    ref.read(selectedMapObjectProvider.notifier).clear();
    ref.read(lineDrawingProvider.notifier).reset();
    ref.read(circleDrawingProvider.notifier).reset();
    ref.read(rectangleDrawingProvider.notifier).reset();
    ref.read(bearingPlotProvider.notifier).reset();
    ref.read(deadReckoningProvider.notifier).reset();
    ref.read(viewshedProvider.notifier).reset();
    ref.read(slopeProvider.notifier).reset();
    ref.read(polygonDrawingProvider.notifier).begin(firstPoint: point);
    if (point != null && _cursorLocation != null) {
      ref.read(polygonDrawingProvider.notifier).setPreviewPoint(_cursorLocation!);
    }
  }

  void _cancelPolygonDrawing() {
    _clearDrawingCompleteDoubleTap();
    _resetLineDrawGestureState();
    ref.read(polygonDrawingProvider.notifier).reset();
  }

  Future<void> _finalizePolygonDrawing() async {
    final drawing = ref.read(polygonDrawingProvider);
    if (!drawing.canFinish) {
      return;
    }
    final points = List<LatLng>.from(drawing.points);
    ref.read(polygonDrawingProvider.notifier).reset();
    _polygonDrawingPressActive = false;
    await createPolygonFromPoints(context: context, ref: ref, points: points);
  }

  void _openRadialMenuAt(Offset center, LatLng point) {
    setState(() {
      _searchCoordinateRadialCenter = null;
      _searchCoordinateRadialMarker = null;
      _radialMenuCenter = center;
      _radialMenuPoint = point;
      _radialMenuPage = 0;
    });
  }

  void _openSearchCoordinateRadialMenu(
    Offset center,
    SearchCoordinateMarker marker,
  ) {
    setState(() {
      _radialMenuCenter = null;
      _radialMenuPoint = null;
      _searchCoordinateRadialCenter = center;
      _searchCoordinateRadialMarker = marker;
    });
  }

  void _closeRadialMenu() {
    if (_radialMenuCenter == null &&
        _radialMenuPoint == null &&
        _searchCoordinateRadialCenter == null &&
        _searchCoordinateRadialMarker == null) {
      return;
    }
    setState(() {
      _radialMenuCenter = null;
      _radialMenuPoint = null;
      _searchCoordinateRadialCenter = null;
      _searchCoordinateRadialMarker = null;
      _radialMenuPage = 0;
    });
  }

  void _openSearchCoordinateMarkerRadialMenu(SearchCoordinateMarker marker) {
    final center = _mapController.camera.latLngToScreenOffset(marker.location);
    _openSearchCoordinateRadialMenu(center, marker);
  }

  Future<void> _saveSearchCoordinateMarkerFromRadialMenu() async {
    final marker = _searchCoordinateRadialMarker;
    if (marker == null) {
      return;
    }
    _closeRadialMenu();
    await widget.onSaveSearchCoordinateMarker(marker);
  }

  Future<void> _addSearchCoordinateMarkerToGeocoding() async {
    final marker = _searchCoordinateRadialMarker;
    if (marker == null) {
      return;
    }
    _closeRadialMenu();
    final saved = await submitGeocodingContribution(
      context: context,
      ref: ref,
      name: marker.label,
      latitude: marker.location.latitude,
      longitude: marker.location.longitude,
    );
    if (saved && mounted) {
      ref.read(searchCoordinateMarkerProvider.notifier).clear();
    }
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
    const width = _cursorLabelEstimatedWidth;
    const height = _cursorLabelEstimatedHeight;
    const gap = _cursorLabelGap;
    const pad = 8.0;

    // Prefer centered horizontally, directly above the cursor.
    var left = cursor.dx - width / 2;
    var top = cursor.dy - height - gap;

    left = left
        .clamp(pad, math.max(pad, mapSize.width - width - pad))
        .toDouble();

    // If there isn't room above, place it just below instead of sliding oddly.
    if (top < pad) {
      top = cursor.dy + gap;
    }
    top = top
        .clamp(pad, math.max(pad, mapSize.height - height - pad))
        .toDouble();

    return Offset(left, top);
  }

  Widget _bearingPlotBanner(
    BearingPlotState bearingPlot,
    AngleDisplayFormat angleFormat,
    BearingReference bearingReference,
    double declinationDegrees,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reference = bearingPlot.referenceBearing;
    final plot = bearingPlot.plotBearing;
    final relative = bearingPlot.relativeBearing;

    String formatPlotBearing(double trueBearing) {
      return formatNavigationBearing(
        trueBearingDegrees: trueBearing,
        reference: bearingReference,
        declinationDegrees: declinationDegrees,
      );
    }

    final details = StringBuffer('Bearing plot · ');
    if (reference != null) {
      details.write('Ref ${formatPlotBearing(reference)}');
    }
    if (plot != null) {
      details.write(' · Brg ${formatPlotBearing(plot)}');
    }
    if (relative != null) {
      details.write(' · ${formatRelativeAngle(relative, angleFormat)}');
    }
    details.write(' · Double-tap to plot line');

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
                    labelText: l10n.mapRelativeAngleLabel,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onInverseSurface.withValues(
                        alpha: 0.8,
                      ),
                      fontSize: 11,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(
                      alpha: 0.15,
                    ),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
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
                  l10n.actionCancel,
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
    final l10n = AppLocalizations.of(context)!;
    final message = lineDrawing.awaitingStart
        ? 'Drag a snap point to draw freely, or click one to plot a bearing'
        : 'Move to the end point, then double-tap to place it (or Cancel)';

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
                  l10n.actionCancel,
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
    final l10n = AppLocalizations.of(context)!;
    const message =
        'Move to set the radius, then double-tap to place it (or Cancel)';

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
                  l10n.actionCancel,
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
    final l10n = AppLocalizations.of(context)!;
    final message = switch (rectangleDrawing.mode) {
      RectangleCreationMode.centerExtent =>
        'Move to set size from center, then double-tap to place (or Cancel)',
      RectangleCreationMode.corners =>
        'Move to the opposite corner, then double-tap to place (or Cancel)',
      null =>
        'Move to define the rectangle, then double-tap to place (or Cancel)',
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
                  l10n.actionCancel,
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _polygonDrawingBanner(PolygonDrawingState polygonDrawing) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                Icons.polyline,
                color: theme.colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.polygonDrawingHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (polygonDrawing.points.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      ref.read(polygonDrawingProvider.notifier).undoLastVertex(),
                  child: Text(
                    l10n.polygonUndoAction,
                    style: TextStyle(color: theme.colorScheme.inversePrimary),
                  ),
                ),
              if (polygonDrawing.canFinish)
                TextButton(
                  onPressed: () => unawaited(_finalizePolygonDrawing()),
                  child: Text(
                    l10n.polygonFinishAction,
                    style: TextStyle(color: theme.colorScheme.inversePrimary),
                  ),
                ),
              TextButton(
                onPressed: _cancelPolygonDrawing,
                child: Text(
                  l10n.actionCancel,
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
    final l10n = AppLocalizations.of(context)!;
    ref.watch(markerIconRevisionProvider);
    ref.watch(markerIconCatalogProvider);
    final mapLayers = _visibleMapLayers;
    final enabledEntries = widget.enabledEntries;
    final mapZoomRange = ref.watch(mapZoomRangeProvider);
    final minZoom = mapZoomRange.min;
    final interactionMaxZoom = mapZoomRange.max;
    final lineDrawing = ref.watch(lineDrawingProvider);
    final circleDrawing = ref.watch(circleDrawingProvider);
    final rectangleDrawing = ref.watch(rectangleDrawingProvider);
    final polygonDrawing = ref.watch(polygonDrawingProvider);
    final bearingPlot = ref.watch(bearingPlotProvider);
    final deadReckoning = ref.watch(deadReckoningProvider);
    final viewshed = ref.watch(viewshedProvider);
    final slope = ref.watch(slopeProvider);
    final selectedMapObject = ref.watch(selectedMapObjectProvider);
    final selectedLineId = selectedMapObject.selectedZoneId;
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final angleDisplayFormat = ref.watch(angleDisplayFormatProvider);
    final navigationBearingReference = ref.watch(bearingReferenceProvider);
    final previewColor = Theme.of(context).colorScheme.primary;
    final previewFillColor = previewColor.withValues(alpha: 0.25);
    final referenceColor = Theme.of(context).colorScheme.secondary;
    final allMarkers = widget.markersAsync.valueOrNull;
    final zones = widget.zonesAsync.valueOrNull ?? const <MapZone>[];
    final layers = widget.layersAsync.valueOrNull ?? const <MapLayer>[];
    final layersById = mapLayersById(layers);
    final selectedZone = selectedLineId == null
        ? null
        : findZoneById(zones, selectedLineId);
    final selectedLine =
        selectedZone?.type == lineZoneType ? selectedZone : null;
    final selectedPolygon =
        selectedZone?.type == polygonZoneType ? selectedZone : null;
    final lineGeometryOverrides = _lineGeometryOverrides();
    final polygonGeometryOverride = _polygonEditPreviewGeometry ??
        (selectedPolygon == null
            ? null
            : PolygonGeometry.fromZone(selectedPolygon));
    final mapTilesDisplayed =
        !widget.metadataLoading &&
        widget.enabledEntries.isNotEmpty &&
        mapLayers.isNotEmpty;
    final showViewportDebugBorder = ref.watch(mapViewportDebugBorderProvider);
    final showTileBorderDebug = ref.watch(mapTileBorderDebugProvider);
    final showCompassRose = ref.watch(mapCompassRoseEnabledProvider);
    final showMgrsGrid = ref.watch(mapMgrsGridEnabledProvider);
    final deviceLocation = ref.watch(deviceLocationProvider);
    final deviceLocationTarget = selectedMarkerTarget(
      selection: selectedMapObject,
      markers: allMarkers ?? const [],
    );
    final deviceLocationTargetPoint = deviceLocationTarget == null
        ? null
        : LatLng(
            deviceLocationTarget.latitude,
            deviceLocationTarget.longitude,
          );
    final mapMarkerSizeScale = ref.watch(mapMarkerSizeScaleProvider);
    final geocodingReachable =
        ref.watch(geocodingServerReachableProvider).valueOrNull ?? false;
    final mapObjectLayerChildren = !mapTilesDisplayed || allMarkers == null
        ? const <Widget>[]
        : buildStackedMapLayerChildren(
            layers: layers,
            markers: allMarkers,
            zones: zones,
            mapMarkerSizeScale: mapMarkerSizeScale,
            selectedLineId: selectedLine?.id,
            selectedPolygonId:
                _polygonVertexEditActive ? selectedPolygon?.id : null,
            polygonGeometryOverride: _polygonVertexEditActive
                ? polygonGeometryOverride
                : null,
            selectedMarkerId: selectedMapObject.selectedMarkerId,
            markerSelectionColor: Theme.of(context).colorScheme.primary,
            geometryOverrides: lineGeometryOverrides,
            onMarkerTap: (marker) => _selectMapObject(
              SelectedMapObject(
                kind: SelectedMapObjectKind.marker,
                id: marker.id,
              ),
              openDetails: false,
            ),
            onMarkerLongPress: (marker) {
              _cancelPendingLongPress();
              _longPressTriggered = true;
              unawaited(_handleMarkerLongPress(marker));
            },
          );
    final selectedLinePreviewGeometry =
        _lineEditPreviewGeometry ??
        (selectedLine == null ? null : LineGeometry.fromZone(selectedLine));
    final bearingAnchor = bearingPlot.active ? bearingPlot.anchor : null;
    final bearingReference = bearingPlot.referenceBearing;
    final activeRectanglePreviewBounds =
        rectangleDrawing.mode == null ||
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
        if (_lastMapSize != null &&
            (_lastMapSize!.width != mapSize.width ||
                _lastMapSize!.height != mapSize.height)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _scheduleVisibleLayerUpdate(immediate: true);
          });
        }
        _lastMapSize = mapSize;
        final viewportDebugDetails = showViewportDebugBorder
            ? _viewportDebugDetails()
            : '';
        final labelPosition = _cursorScreenPosition == null
            ? null
            : _cursorLabelPosition(mapSize);

        return Stack(
          fit: StackFit.expand,
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                final point = _mapController.camera.screenOffsetToLatLng(
                  event.localPosition,
                );
                _beginSelectionPointer(event, point);
              },
              onPointerUp: (event) {
                final point = _mapController.camera.screenOffsetToLatLng(
                  event.localPosition,
                );
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
                    maxZoom: interactionMaxZoom,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    interactionOptions: InteractionOptions(
                      flags: () {
                        var flags = InteractiveFlag.all;
                        if (lineDrawing.active ||
                            bearingPlot.active ||
                            circleDrawing.active ||
                            rectangleDrawing.active ||
                            polygonDrawing.active ||
                            deadReckoning.active ||
                            _draggingLineControlIndex != null ||
                            _draggingPolygonVertexIndex != null ||
                            _pendingPolygonVertexIndex != null) {
                          flags &= ~InteractiveFlag.drag;
                        }
                        // Free double-tap for vertex removal while editing.
                        if (selectedLine != null || _polygonVertexEditActive) {
                          flags &= ~InteractiveFlag.doubleTapZoom;
                        }
                        return flags;
                      }(),
                    ),
                    onPositionChanged: (position, hasGesture) {
                      if (_draggingLineControlIndex != null ||
                          _draggingPolygonVertexIndex != null) {
                        _holdMapStillDuringVertexEdit();
                        return;
                      }
                      _scheduleVisibleLayerUpdate();
                      if (!hasGesture) return;
                      // User panned/zoomed — stop auto-recenter but keep the blue dot.
                      if (ref.read(deviceLocationProvider).following) {
                        ref
                            .read(deviceLocationProvider.notifier)
                            .stopFollowing();
                      }
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
                    onPointerCancel: (_, _) => _handlePointerCancel(),
                  ),
                  children: [
                    if (enabledEntries.isEmpty && !widget.metadataLoading)
                      _PlaceholderLayer(
                        onOpenSettings: widget.onOpenSettings,
                      )
                    else
                      ...mapLayers.expand(
                        (mapLayer) => switch (mapLayer) {
                          PmtilesVectorMapLayerConfig(
                            :final catalogId,
                            :final tileProvider,
                            :final theme,
                            :final backgroundTheme,
                            :final sprites,
                          ) =>
                            [
                              VectorTileLayer(
                                key: ValueKey('pmtiles-$catalogId'),
                                layerMode: VectorTileLayerMode.vector,
                                theme: theme,
                                backgroundTheme: backgroundTheme,
                                sprites: sprites,
                                concurrency: 6,
                                maximumTileSubstitutionDifference: 3,
                                memoryTileDataCacheMaxSize: 99,
                                memoryTileCacheMaxSize: 32 * 1024 * 1024,
                                showTileDebugInfo:
                                    showViewportDebugBorder &&
                                    showTileBorderDebug,
                                tileProviders: TileProviders({
                                  'protomaps': tileProvider,
                                }),
                              ),
                            ],
                          PmtilesRasterMapLayerConfig(
                            :final catalogId,
                            :final tileProvider,
                            :final maxZoom,
                          ) =>
                            [
                              TileLayer(
                                key: ValueKey('pmtiles-$catalogId'),
                                maxNativeZoom: maxZoom,
                                maxZoom: interactionMaxZoom,
                                tileProvider: tileProvider,
                              ),
                            ],
                        },
                      ),
                    ...mapObjectLayerChildren,
                    if (showMgrsGrid) ...[
                      MapMgrsGridLayer(mapController: _mapController),
                      MapMgrsGridLabelsLayer(mapController: _mapController),
                    ],
                    ...buildDeviceLocationMapChildren(
                      deviceLocation,
                      targetPoint: deviceLocationTargetPoint,
                    ),
                    if (mapTilesDisplayed)
                      if (widget.searchCoordinateMarker case final marker?)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: marker.location,
                              width: mapMarkerRenderWidth(mapMarkerSizeScale),
                              height: mapMarkerRenderHeight(mapMarkerSizeScale),
                              alignment: mapMarkerAnchorAlignment,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () =>
                                    _openSearchCoordinateMarkerRadialMenu(
                                      marker,
                                    ),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    message:
                                        l10n.markerSaveSearchedCoordinatesTitle,
                                    child: MapMarkerIcon(
                                      color: const Color(0xFFE07A24),
                                      iconName: marker.iconName,
                                      width: mapMarkerRenderWidth(
                                        mapMarkerSizeScale,
                                      ),
                                      height: mapMarkerRenderHeight(
                                        mapMarkerSizeScale,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    if (mapTilesDisplayed)
                      if (selectedLine case final line?
                          when !lineDrawing.active &&
                              !bearingPlot.active &&
                              !deadReckoning.active)
                        MarkerLayer(
                          markers: buildLineSnapPointMarkers(
                            zone: line,
                            geometryOverride: selectedLinePreviewGeometry,
                          ),
                        ),
                    if (mapTilesDisplayed &&
                        _polygonVertexEditActive &&
                        selectedPolygon != null &&
                        polygonGeometryOverride != null)
                      MarkerLayer(
                        markers: buildEditablePolygonVertexMarkers(
                          points: polygonGeometryOverride.points,
                          color: previewColor,
                        ),
                      ),
                    if (bearingAnchor case final anchor?)
                      PolylineLayer(
                        polylines: [
                          if (bearingReference case final reference?)
                            ?buildReferenceCoursePolyline(
                              anchor: anchor,
                              referenceBearing: reference,
                              previewEnd: bearingPlot.previewEnd,
                              color: referenceColor,
                            ),
                          ?buildPreviewLinePolyline(
                            start: anchor,
                            previewEnd: bearingPlot.previewEnd,
                            color: previewColor,
                          ),
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
                        ],
                      ),
                    if (circleDrawing.center case final center?)
                      PolygonLayer(
                        polygons: [
                          ?buildPreviewCirclePolygon(
                            center: center,
                            radiusMeters: circleDrawing.previewRadiusMeters,
                            borderColor: previewColor,
                            fillColor: previewFillColor,
                          ),
                        ],
                      ),
                    if (circleDrawing.center case final center?)
                      PolylineLayer(
                        polylines: [
                          ?buildPreviewCircleRadiusLine(
                            center: center,
                            radiusMeters: circleDrawing.previewRadiusMeters,
                            color: previewColor,
                          ),
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
                          ?buildPreviewRectanglePolygon(
                            bounds: bounds,
                            borderColor: previewColor,
                            fillColor: previewFillColor,
                          ),
                        ],
                      ),
                    if (rectangleDrawing.mode ==
                            RectangleCreationMode.centerExtent &&
                        rectangleDrawing.anchor != null)
                      MarkerLayer(
                        markers: [
                          ?buildPreviewRectangleCenterMarker(
                            center: rectangleDrawing.anchor,
                            color: previewColor,
                          ),
                        ],
                      ),
                    if (rectangleDrawing.mode ==
                            RectangleCreationMode.corners &&
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
                    if (polygonDrawing.active) ...[
                      PolygonLayer(
                        polygons: [
                          ?buildPreviewPolygon(
                            points: polygonDrawing.points,
                            previewPoint: polygonDrawing.previewPoint,
                            borderColor: previewColor,
                            fillColor: previewFillColor,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: buildPreviewPolygonVertexMarkers(
                          points: polygonDrawing.points,
                          color: previewColor,
                        ),
                      ),
                    ],
                    if (lineDrawing.start case final start?)
                      PolylineLayer(
                        polylines: [
                          ?buildPreviewLinePolyline(
                            start: start,
                            previewEnd: lineDrawing.previewEnd,
                            color: previewColor,
                          ),
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
                        ],
                      ),
                    if (deadReckoning.active && deadReckoning.anchor != null)
                      PolylineLayer(
                        polylines: [
                          ?buildPreviewLinePolyline(
                            start: deadReckoning.anchor!,
                            previewEnd: deadReckoning.previewEnd,
                            color: previewColor,
                          ),
                        ],
                      ),
                    if (deadReckoning.active && deadReckoning.anchor != null)
                      MarkerLayer(
                        markers: [
                          ...buildLineEndpointMarkers(
                            start: deadReckoning.anchor!,
                            end: deadReckoning.previewEnd,
                            color: previewColor,
                          ),
                        ],
                      ),
                    if (viewshed.active) ...[
                      PolygonLayer(
                        polygons: [
                          ?buildViewshedRangeRingPolygon(
                            points: viewshed.rangeRing,
                            borderColor: previewColor.withValues(alpha: 0.7),
                          ),
                          ?buildViewshedVisiblePolygon(
                            points: viewshed.visiblePolygon,
                            borderColor: previewColor,
                            fillColor: previewFillColor,
                          ),
                        ],
                      ),
                      if (viewshed.observer case final observer?)
                        MarkerLayer(
                          markers: [
                            buildViewshedObserverMarker(
                              observer: observer,
                              color: previewColor,
                            ),
                          ],
                        ),
                    ],
                    if (slope.active) ...[
                      Builder(
                        builder: (context) {
                          final overlays = buildSlopeOverlayImages(
                            image: slope.heatmapImage,
                            bounds: slope.bounds,
                            opacity: slope.opacity,
                          );
                          if (overlays.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return OverlayImageLayer(overlayImages: overlays);
                        },
                      ),
                      PolygonLayer(
                        polygons: [
                          ?buildSlopeRangeRingPolygon(
                            points: slope.rangeRing,
                            borderColor: previewColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                      if (slope.center case final center?)
                        MarkerLayer(
                          markers: [
                            buildSlopeCenterMarker(
                              center: center,
                              color: previewColor,
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
            ),
            if (mapTilesDisplayed)
              if (widget.zonesAsync.valueOrNull case final value?)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        LineDirectionArrowsOverlay(
                          zones: filterZonesForMap(value, layersById),
                          mapController: _mapController,
                          geometryOverrides: lineGeometryOverrides,
                          previewStart: lineDrawing.start,
                          previewEnd: lineDrawing.previewEnd,
                          previewColor: lineDrawing.active
                              ? previewColor
                              : null,
                          bearingPreviewStart: bearingPlot.active
                              ? bearingPlot.anchor
                              : deadReckoning.active
                              ? deadReckoning.anchor
                              : null,
                          bearingPreviewEnd: bearingPlot.active
                              ? bearingPlot.previewEnd
                              : deadReckoning.previewEnd,
                          bearingPreviewColor:
                              bearingPlot.active || deadReckoning.active
                              ? previewColor
                              : null,
                        ),
                        TrackFootstepsOverlay(
                          zones: filterZonesForMap(value, layersById),
                          mapController: _mapController,
                        ),
                        LineMapLabelsOverlay(
                          zones: filterZonesForMap(value, layersById),
                          units: measurementUnits,
                          mapController: _mapController,
                          previewStart: lineDrawing.start,
                          previewEnd: lineDrawing.previewEnd,
                          previewColor: lineDrawing.active
                              ? previewColor
                              : null,
                          bearingPreviewStart: bearingPlot.active
                              ? bearingPlot.anchor
                              : deadReckoning.active
                              ? deadReckoning.anchor
                              : null,
                          bearingPreviewEnd: bearingPlot.active
                              ? bearingPlot.previewEnd
                              : deadReckoning.previewEnd,
                          bearingPreviewColor:
                              bearingPlot.active || deadReckoning.active
                              ? previewColor
                              : null,
                          bearingPreviewAngle:
                              !bearingPlot.active ||
                                  bearingPlot.relativeBearing == null
                              ? null
                              : formatRelativeAngle(
                                  bearingPlot.relativeBearing!,
                                  angleDisplayFormat,
                                ),
                          previewCircleCenter: circleDrawing.active
                              ? circleDrawing.center
                              : null,
                          previewCircleRadiusMeters:
                              circleDrawing.previewRadiusMeters,
                          previewCircleColor: circleDrawing.active
                              ? previewColor
                              : null,
                          previewRectangleBounds: rectangleDrawing.active
                              ? activeRectanglePreviewBounds
                              : null,
                          previewRectangleColor: rectangleDrawing.active
                              ? previewColor
                              : null,
                        ),
                      ],
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
                child: MapCursorCoordinates(
                  location: location,
                  showMgrs: showMgrsGrid,
                  zoom: _mapController.camera.zoom,
                ),
              ),
            if (showCompassRose ||
                (deviceLocation.tracking && deviceLocation.hasFix))
              Positioned(
                left: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  right: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCompassRose)
                        MapCompassRoseOverlay(mapController: _mapController),
                      if (showCompassRose &&
                          deviceLocation.tracking &&
                          deviceLocation.hasFix)
                        const SizedBox(height: 8),
                      if (deviceLocation.tracking && deviceLocation.hasFix)
                        IgnorePointer(
                          child: MapDeviceLocationHud(
                            zoom: _mapController.camera.zoom,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (_radialMenuCenter case final center?
                when _radialMenuPoint != null)
              MapRadialMenu(
                center: center,
                actions: _radialMenuPage == 0
                    ? [
                        MapRadialMenuAction(
                          icon: Icons.add_location_alt,
                          label: l10n.mapRadialMarker,
                          onSelected: _createMarkerFromRadialMenu,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.timeline,
                          label: l10n.mapRadialLine,
                          onSelected: _beginLineDrawing,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.radio_button_unchecked,
                          label: l10n.mapRadialCircle,
                          onSelected: _beginCircleDrawing,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.crop_square,
                          label: l10n.mapRadialRectCenter,
                          onSelected: _beginCenterRectDrawing,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.select_all,
                          label: l10n.mapRadialRectCorners,
                          onSelected: _beginCornersRectDrawing,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.polyline,
                          label: l10n.mapRadialPolygon,
                          onSelected: _beginPolygonDrawing,
                        ),
                      ]
                    : [
                        MapRadialMenuAction(
                          icon: Icons.visibility,
                          label: l10n.mapRadialViewshed,
                          onSelected: _beginViewshed,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.terrain,
                          label: l10n.mapRadialSlope,
                          onSelected: _beginSlope,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.directions_walk,
                          label: l10n.mapRadialDeadReckoning,
                          onSelected: _beginDeadReckoning,
                        ),
                        MapRadialMenuAction(
                          icon: Icons.copy,
                          label: l10n.mapRadialCopyCoordinates,
                          onSelected: _copyRadialMenuCoordinates,
                        ),
                      ],
                footerAction: _radialMenuPage == 0
                    ? MapRadialMenuAction(
                        icon: Icons.more_horiz,
                        label: l10n.mapRadialMore,
                        onSelected: () => setState(() => _radialMenuPage = 1),
                      )
                    : MapRadialMenuAction(
                        icon: Icons.arrow_back,
                        label: l10n.mapRadialBack,
                        onSelected: () => setState(() => _radialMenuPage = 0),
                      ),
              ),
            if (_searchCoordinateRadialCenter case final center?
                when _searchCoordinateRadialMarker != null)
              MapRadialMenu(
                center: center,
                actions: [
                  MapRadialMenuAction(
                    icon: Icons.add_location_alt,
                    label: l10n.markerSaveSearchedCoordinatesConfirm,
                    onSelected: _saveSearchCoordinateMarkerFromRadialMenu,
                  ),
                  if (geocodingReachable)
                    MapRadialMenuAction(
                      icon: Icons.public,
                      label: l10n.mapRadialAddToGeocoding,
                      onSelected: _addSearchCoordinateMarkerToGeocoding,
                    ),
                ],
              ),
            if (bearingPlot.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _bearingPlotBanner(
                  bearingPlot,
                  angleDisplayFormat,
                  navigationBearingReference,
                  magneticDeclinationDegrees(
                    location: _mapController.camera.center,
                  ),
                ),
              ),
            if (deadReckoning.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: DeadReckoningBanner(
                  bearingReference: navigationBearingReference,
                  declinationDegrees: magneticDeclinationDegrees(
                    location:
                        deadReckoning.anchor ?? _mapController.camera.center,
                  ),
                  onPlaceMarker: () =>
                      unawaited(_finalizeDeadReckoningMarker()),
                  onCreateLine: () => unawaited(_finalizeDeadReckoningLine()),
                  onCancel: _cancelDeadReckoning,
                ),
              ),
            if (viewshed.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: ViewshedBanner(onCancel: _cancelViewshed),
              ),
            if (slope.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SlopeBanner(onCancel: _cancelSlope),
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
                !deadReckoning.active &&
                !viewshed.active &&
                !slope.active &&
                !circleDrawing.active &&
                !rectangleDrawing.active &&
                !polygonDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _lineEditingBanner(),
              ),
            if (_polygonVertexEditActive &&
                selectedPolygon != null &&
                !polygonDrawing.active &&
                !viewshed.active &&
                !slope.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _polygonEditingBanner(),
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
            if (polygonDrawing.active)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _polygonDrawingBanner(polygonDrawing),
              ),
            if (showViewportDebugBorder)
              Positioned(
                left: 0,
                top: 0,
                width: mapSize.width,
                height: mapSize.height,
                child: MapViewportDebugOverlay(
                  mapSize: mapSize,
                  details: viewportDebugDetails,
                ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.mapNoOfflineMapTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? l10n.mapNoOfflineMapMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: Text(l10n.actionOpenSettings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
