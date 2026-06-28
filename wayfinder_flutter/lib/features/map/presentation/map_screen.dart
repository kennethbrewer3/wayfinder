import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../geocoding/presentation/address_search_readiness_indicator.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import 'map_tiles_load_indicator.dart';
import '../../markers/providers/markers_provider.dart';
import '../../markers/utils/marker_hit_test.dart';
import '../../markers/utils/marker_share_url.dart';
import '../../search/providers/search_query_provider.dart';
import '../../search/models/search_result.dart';
import '../../search/providers/search_coordinate_marker_provider.dart';
import '../../search/presentation/map_search_bar.dart';
import '../../sidebar/presentation/sidebar_panel.dart';
import '../models/map_viewport.dart';
import '../providers/home_location_provider.dart';
import '../providers/map_providers.dart';
import '../providers/selected_map_object_provider.dart';
import 'map_object_selection_listener.dart';
import 'map_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.initialViewport,
    this.initialMarkerId,
  });

  final MapViewport? initialViewport;
  final UuidValue? initialMarkerId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _queuedInitialViewportDeepLink = false;
  bool _appliedInitialMarkerLink = false;

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialViewport != widget.initialViewport ||
        oldWidget.initialMarkerId != widget.initialMarkerId) {
      _queuedInitialViewportDeepLink = false;
      _appliedInitialMarkerLink = false;
    }
  }

  void _queueInitialViewportDeepLink() {
    if (_queuedInitialViewportDeepLink) {
      return;
    }
    final initial = widget.initialViewport;
    if (initial == null) {
      return;
    }

    _queuedInitialViewportDeepLink = true;
    ref.read(mapViewportProvider.notifier).setDeepLinkViewport(initial);
  }

  void _applyInitialMarkerLink(AsyncValue<List<MapMarker>> markersAsync) {
    if (_appliedInitialMarkerLink) {
      return;
    }
    if (!ref.read(mapViewportProvider).hasValue) {
      return;
    }

    final markerId = widget.initialMarkerId;
    if (markerId == null) {
      _appliedInitialMarkerLink = true;
      return;
    }
    if (markersAsync.isLoading) {
      return;
    }
    if (markersAsync.hasError) {
      _appliedInitialMarkerLink = true;
      return;
    }

    final marker = findMarkerById(
      markersAsync.valueOrNull ?? const [],
      markerId,
    );
    _appliedInitialMarkerLink = true;
    if (marker == null) {
      return;
    }

    final zoom = widget.initialViewport?.zoom ?? markerShareDefaultZoom;
    final targetViewport = MapViewport(
      center: LatLng(marker.latitude, marker.longitude),
      zoom: zoom,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(mapViewportProvider.notifier).setDeepLinkViewport(targetViewport);
    });
  }

  void _syncMapUrl({
    required MapViewport viewport,
    UuidValue? markerId,
  }) {
    final nextUri = buildMapShareUri(
      viewport: viewport,
      markerId: markerId,
    );
    final currentUri = GoRouterState.of(context).uri;
    if (mapShareRoutesMatch(currentUri, nextUri)) {
      return;
    }
    context.go(mapShareLocation(nextUri));
  }

  Future<void> _handleViewportChanged(MapViewport viewport) async {
    await ref.read(mapViewportProvider.notifier).setViewport(viewport);
    if (!mounted) {
      return;
    }

    _syncMapUrl(
      viewport: viewport,
      markerId: ref.read(selectedMapObjectProvider).selectedMarkerId,
    );
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
    _queueInitialViewportDeepLink();
    final viewportAsync = ref.watch(mapViewportProvider);
    final markersAsync = ref.watch(markersProvider);
    _applyInitialMarkerLink(markersAsync);

    ref.listen<SelectedMapObject?>(
      selectedMapObjectProvider,
      (previous, next) {
        final viewport = ref.read(mapViewportProvider).valueOrNull;
        if (viewport == null || !mounted) {
          return;
        }
        _syncMapUrl(
          viewport: viewport,
          markerId: next?.selectedMarkerId,
        );
      },
    );

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
