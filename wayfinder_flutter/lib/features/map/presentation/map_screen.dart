import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../search/models/search_result.dart';
import '../../search/presentation/map_search_bar.dart';
import '../../sidebar/presentation/sidebar_panel.dart';
import '../models/map_viewport.dart';
import '../providers/map_providers.dart';
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
    await ref.read(mapViewportProvider.notifier).moveTo(
          center: result.location,
          zoom: result.zoom,
        );
    ref.read(sidebarProvider.notifier).setSearchQuery('');
  }

  Future<void> _zoomTo(LatLng location) {
    return ref.read(mapViewportProvider.notifier).moveTo(
          center: location,
          zoom: 14,
        );
  }

  Future<void> _goHome() {
    AppLogger.logNav.info('🏠 Debug home — moving to default viewport');
    return ref.read(mapViewportProvider.notifier).applyDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final viewportAsync = ref.watch(mapViewportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Home (debug)',
            icon: const Icon(Icons.home),
            onPressed: _goHome,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppLogger.logNav.info('🧭 Navigating to settings from app bar');
              context.push('/settings');
            },
          ),
        ],
      ),
      body: viewportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load map: $error')),
        data: (viewport) {
          final isWide = MediaQuery.sizeOf(context).width >= 960;

          final mapSection = Stack(
            children: [
              Positioned.fill(
                child: MapView(
                  viewport: viewport,
                  onViewportChanged: _handleViewportChanged,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: isWide ? 360 : 16,
                child: MapSearchBar(
                  onResultSelected: _handleSearchResult,
                ),
              ),
            ],
          );

          final sidebar = SidebarPanel(onZoomTo: _zoomTo);

          if (isWide) {
            return Row(
              children: [
                Expanded(child: mapSection),
                SizedBox(
                  width: 320,
                  child: sidebar,
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: mapSection),
              SizedBox(
                height: 280,
                child: sidebar,
              ),
            ],
          );
        },
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
