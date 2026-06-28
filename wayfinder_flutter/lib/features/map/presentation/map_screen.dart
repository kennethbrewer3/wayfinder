import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../geocoding/presentation/address_search_readiness_indicator.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import 'map_tiles_load_indicator.dart';
import '../../markers/providers/markers_provider.dart';
import '../../markers/utils/marker_hit_test.dart';
import '../../search/providers/search_query_provider.dart';
import '../../search/models/search_result.dart';
import '../../search/providers/search_coordinate_marker_provider.dart';
import '../../search/presentation/map_search_bar.dart';
import '../../sidebar/presentation/sidebar_panel.dart';
import '../models/map_viewport.dart';
import '../../map/providers/home_location_provider.dart';
import '../../map/providers/map_providers.dart';
import 'map_object_selection_listener.dart';
import 'map_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.initialViewport,
  });

  final MapViewport? initialViewport;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _appliedInitialViewport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialViewport();
    });
  }

  void _applyInitialViewport() {
    if (_appliedInitialViewport) return;
    final initial = widget.initialViewport;
    if (initial == null) return;

    _appliedInitialViewport = true;
    ref.read(mapViewportProvider.notifier).moveTo(
          center: initial.center,
          zoom: initial.zoom,
        );
  }

  Future<void> _handleViewportChanged(MapViewport viewport) async {
    await ref.read(mapViewportProvider.notifier).setViewport(viewport);
    if (!mounted) return;

    final uri = Uri(
      path: '/maps',
      queryParameters: {
        'lat': viewport.center.latitude.toStringAsFixed(6),
        'lng': viewport.center.longitude.toStringAsFixed(6),
        'zoom': viewport.zoom.toStringAsFixed(2),
      },
    );
    context.go(uri.toString());
  }

  Future<void> _handleSearchResult(SearchResult result) async {
    final defaultZoom = ref.read(mapViewportProvider).valueOrNull?.zoom ??
        AppConstants.defaultZoom;
    final zoom = switch (result.type) {
      SearchResultType.coordinate ||
      SearchResultType.place ||
      SearchResultType.address =>
        result.zoom,
      _ => defaultZoom,
    };
    await ref.read(mapViewportProvider.notifier).moveTo(
          center: result.location,
          zoom: zoom,
        );
    final searchCoordinateMarker =
        ref.read(searchCoordinateMarkerProvider.notifier);
    if (result.type == SearchResultType.coordinate ||
        result.type == SearchResultType.place ||
        result.type == SearchResultType.address) {
      searchCoordinateMarker.set(result.location, result.label);
    } else {
      searchCoordinateMarker.clear();
    }
    ref.read(sidebarProvider.notifier).setSearchQuery('');
    ref.read(debouncedMapSearchQueryProvider.notifier).clear();
  }

  Future<void> _zoomTo(LatLng location) {
    return ref.read(mapViewportProvider.notifier).moveTo(
          center: location,
          zoom: 14,
        );
  }

  Future<void> _goHome() {
    final home = ref.read(homeLocationProvider);
    final l10n = AppLocalizations.of(context)!;
    AppLogger.logNav.info(
      '🏠 Home — moving to ${home.latitude}, ${home.longitude} @ ${home.zoom}',
    );
    final markers = ref.read(markersProvider).valueOrNull ?? const [];
    final markerNotifier = ref.read(searchCoordinateMarkerProvider.notifier);
    if (hasMarkerNearLocation(markers: markers, location: home.center)) {
      markerNotifier.clear();
    } else {
      markerNotifier.set(
        home.center,
        l10n.mapHomeTooltip,
        iconName: 'home',
      );
    }
    return ref.read(mapViewportProvider.notifier).goHome(home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewportAsync = ref.watch(mapViewportProvider);
    final searchResults = watchCombinedSearchResults(ref, l10n);
    final debouncedQuery = ref.watch(debouncedMapSearchQueryProvider).trim();
    final geocodingLoading = debouncedQuery.length >= mapSearchMinGeocodingLength &&
        ref.watch(geocodingSearchProvider(debouncedQuery)).isLoading;
    final showSearchResults = searchResults.isNotEmpty || geocodingLoading;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: MapSearchField(onResultSelected: _handleSearchResult),
        bottom: showSearchResults
            ? PreferredSize(
                preferredSize: const Size.fromHeight(240),
                child: MapSearchResults(onResultSelected: _handleSearchResult),
              )
            : null,
        actions: [
          const AddressSearchReadinessIndicator(),
          const MapTilesLoadIndicator(),
          IconButton(
            tooltip: l10n.mapHomeTooltip,
            icon: const Icon(Icons.home),
            onPressed: _goHome,
          ),
          IconButton(
            tooltip: l10n.mapSettingsTooltip,
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppLogger.logNav.info('🧭 Navigating to settings from app bar');
              context.push('/settings/general');
            },
          ),
        ],
      ),
      body: MapObjectSelectionListener(
        child: viewportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.mapLoadFailed(error.toString()))),
        data: (viewport) {
          final isWide = MediaQuery.sizeOf(context).width >= 960;
          final sidebarExpanded = ref.watch(
            sidebarProvider.select((state) => state.expanded),
          );
          const sidebarWidth = 320.0;
          const sidebarHeightExpanded = 280.0;
          const sidebarHeightCollapsed = 56.0;

          final mapSection = Stack(
            children: [
              Positioned.fill(
                child: MapView(
                  viewport: viewport,
                  onViewportChanged: _handleViewportChanged,
                ),
              ),
              if (isWide && !sidebarExpanded)
                Positioned(
                  top: 16,
                  right: 8,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: IconButton(
                      tooltip: l10n.mapShowObjectsTooltip,
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        ref.read(sidebarProvider.notifier).setExpanded(true);
                      },
                    ),
                  ),
                ),
            ],
          );

          final sidebar = SidebarPanel(onZoomTo: _zoomTo);

          if (isWide) {
            return Row(
              children: [
                Expanded(child: mapSection),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: sidebarExpanded ? sidebarWidth : 0,
                  child: sidebarExpanded
                      ? SizedBox(width: sidebarWidth, child: sidebar)
                      : const SizedBox.shrink(),
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: mapSection),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: sidebarExpanded
                    ? sidebarHeightExpanded
                    : sidebarHeightCollapsed,
                child: sidebar,
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

MapViewport? parseMapViewportFromUri(Uri uri) {
  final lat = double.tryParse(uri.queryParameters['lat'] ?? '');
  final lng = double.tryParse(uri.queryParameters['lng'] ?? '');
  final zoom = double.tryParse(uri.queryParameters['zoom'] ?? '');

  if (lat == null || lng == null) {
    return null;
  }

  return MapViewport(
    center: LatLng(lat, lng),
    zoom: zoom ?? AppConstants.defaultZoom,
  );
}
