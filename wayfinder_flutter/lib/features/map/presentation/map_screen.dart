import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import '../../map_atlas/presentation/map_atlas_export_action.dart';
import '../../markers/providers/markers_provider.dart';
import '../../markers/utils/marker_hit_test.dart';
import '../../markers/utils/marker_share_url.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../../offline_packs/presentation/prepare_offline_pack_dialog.dart';
import '../../offline_packs/providers/offline_pack_controller.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../../search/providers/search_query_provider.dart';
import '../../search/models/search_result.dart';
import '../../search/providers/search_coordinate_marker_provider.dart';
import '../../search/presentation/map_search_bar.dart';
import '../../sidebar/presentation/sidebar_panel.dart';
import '../models/map_viewport.dart';
import '../providers/device_location_provider.dart';
import '../providers/home_location_provider.dart';
import '../providers/map_mgrs_grid_provider.dart';
import '../providers/map_providers.dart';
import '../providers/selected_map_object_provider.dart';
import 'map_object_selection_listener.dart';
import 'map_view.dart';

/// Below this width, secondary AppBar actions move into a trailing overflow menu
/// so search + primary map controls still fit on phones.
const _mapAppBarCompactBreakpoint = 720.0;

enum _MapAppBarOverflowAction {
  toggleMgrsGrid,
  goHome,
  prepareOffline,
  exportAtlas,
  openManual,
  openSettings,
}

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
  bool _isExportingAtlas = false;

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare by value — go_router rebuilds with new MapViewport instances
    // on every URL sync, which must not re-arm deep-link camera moves.
    if (!_sameViewport(oldWidget.initialViewport, widget.initialViewport) ||
        !_sameMarkerId(oldWidget.initialMarkerId, widget.initialMarkerId)) {
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

    // Selecting a marker syncs `?marker=` into the URL. That rebuilds this
    // screen with the same id — do not treat that as a share/deep link and
    // yank the camera to the marker.
    final selectedId = ref.read(selectedMapObjectProvider).selectedMarkerId;
    if (_sameMarkerId(selectedId, markerId)) {
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
      ref
          .read(mapViewportProvider.notifier)
          .setDeepLinkViewport(targetViewport);
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
    final defaultZoom =
        ref.read(mapViewportProvider).valueOrNull?.zoom ??
        AppConstants.defaultZoom;
    final zoom = switch (result.type) {
      SearchResultType.coordinate ||
      SearchResultType.place ||
      SearchResultType.address => result.zoom,
      _ => defaultZoom,
    };
    await ref
        .read(mapViewportProvider.notifier)
        .moveTo(
          center: result.location,
          zoom: zoom,
        );
    final searchCoordinateMarker = ref.read(
      searchCoordinateMarkerProvider.notifier,
    );
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
    final currentZoom =
        ref.read(mapViewportProvider).valueOrNull?.zoom ??
        AppConstants.defaultZoom;
    return ref
        .read(mapViewportProvider.notifier)
        .moveTo(
          center: location,
          zoom: currentZoom,
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

  Future<void> _exportMapAtlas() async {
    setState(() => _isExportingAtlas = true);
    try {
      await runMapAtlasExport(context: context, ref: ref);
    } finally {
      if (mounted) {
        setState(() => _isExportingAtlas = false);
      }
    }
  }

  Future<void> _locateMe() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(deviceLocationProvider.notifier);
    final ok = await notifier.locateAndFollow();
    if (!mounted) {
      return;
    }
    final location = ref.read(deviceLocationProvider);
    if (!ok) {
      final message = _deviceLocationErrorMessage(l10n, location.errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    final position = location.position;
    if (position == null) {
      // Permission granted; waiting on the first GPS/browser fix.
      return;
    }
    final currentZoom =
        ref.read(mapViewportProvider).valueOrNull?.zoom ??
        AppConstants.defaultZoom;
    await ref
        .read(mapViewportProvider.notifier)
        .moveTo(
          center: position,
          zoom: currentZoom < 14 ? 14 : currentZoom,
        );
  }

  Future<void> _stopLocateMe() async {
    await ref.read(deviceLocationProvider.notifier).stop();
  }

  String _deviceLocationErrorMessage(AppLocalizations l10n, String? code) {
    return switch (DeviceLocationError.fromCode(code)) {
      DeviceLocationError.serviceDisabled =>
        l10n.mapDeviceLocationServiceDisabled,
      DeviceLocationError.permissionDenied =>
        l10n.mapDeviceLocationPermissionDenied,
      DeviceLocationError.permissionDeniedForever =>
        l10n.mapDeviceLocationPermissionDeniedForever,
      DeviceLocationError.unavailable ||
      null => l10n.mapDeviceLocationUnavailable,
    };
  }

  void _followDeviceLocation(
    DeviceLocationState? previous,
    DeviceLocationState next,
  ) {
    if (!next.following || next.position == null) {
      return;
    }
    if (previous?.position == next.position && previous?.following == true) {
      return;
    }
    final currentZoom =
        ref.read(mapViewportProvider).valueOrNull?.zoom ??
        AppConstants.defaultZoom;
    // Follow updates are frequent — keep the camera in sync without
    // rewriting saved viewport storage on every GPS tick.
    unawaited(
      ref
          .read(mapViewportProvider.notifier)
          .moveTo(
            center: next.position!,
            zoom: currentZoom,
            persist: false,
          ),
    );
  }

  List<Widget> _buildMapAppBarActions({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool compact,
    required bool kioskActive,
    required bool offlineActive,
    required bool hasOfflinePack,
    required bool mgrsGridEnabled,
    required DeviceLocationState deviceLocation,
  }) {
    final theme = Theme.of(context);
    final actions = <Widget>[];

    if (!compact) {
      if (!kioskActive) {
        actions.add(
          IconButton(
            tooltip: hasOfflinePack
                ? l10n.offlinePackPrepareTooltipReady
                : l10n.offlinePackPrepareTooltip,
            icon: Icon(
              hasOfflinePack
                  ? Icons.offline_pin
                  : Icons.download_for_offline_outlined,
              color: offlineActive
                  ? theme.colorScheme.tertiary
                  : (hasOfflinePack ? theme.colorScheme.primary : null),
            ),
            onPressed: offlineActive
                ? null
                : () async {
                    await showPrepareOfflinePackDialog(context);
                  },
          ),
        );
      }
      actions.add(
        IconButton(
          tooltip: mgrsGridEnabled
              ? l10n.mapMgrsGridHideTooltip
              : l10n.mapMgrsGridShowTooltip,
          icon: Icon(
            Icons.grid_on,
            color: mgrsGridEnabled ? theme.colorScheme.primary : null,
          ),
          onPressed: () {
            ref.read(mapMgrsGridEnabledProvider.notifier).toggle();
          },
        ),
      );
    }

    actions.add(
      IconButton(
        tooltip: deviceLocation.tracking
            ? (deviceLocation.following
                  ? l10n.mapDeviceLocationFollowingTooltip
                  : l10n.mapDeviceLocationStopTooltip)
            : l10n.mapDeviceLocationTooltip,
        icon: deviceLocation.busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Icon(
                deviceLocation.tracking
                    ? (deviceLocation.following
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed)
                    : Icons.my_location,
                color: deviceLocation.tracking
                    ? theme.colorScheme.primary
                    : null,
              ),
        // Keep the button enabled while busy so long-press can still stop.
        onPressed: _locateMe,
        onLongPress: (deviceLocation.tracking || deviceLocation.busy)
            ? _stopLocateMe
            : null,
      ),
    );

    if (compact) {
      actions.add(
        _buildMapAppBarOverflowMenu(
          context: context,
          l10n: l10n,
          kioskActive: kioskActive,
          offlineActive: offlineActive,
          hasOfflinePack: hasOfflinePack,
          mgrsGridEnabled: mgrsGridEnabled,
        ),
      );
      return actions;
    }

    actions.add(
      IconButton(
        tooltip: l10n.mapHomeTooltip,
        icon: const Icon(Icons.home),
        onPressed: _goHome,
      ),
    );
    if (!kioskActive) {
      actions.add(
        IconButton(
          tooltip: l10n.mapAtlasTooltip,
          icon: _isExportingAtlas
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          onPressed: _isExportingAtlas ? null : _exportMapAtlas,
        ),
      );
    }
    actions.add(
      IconButton(
        tooltip: l10n.mapManualTooltip,
        icon: const Icon(Icons.menu_book_outlined),
        onPressed: _openManual,
      ),
    );
    if (!kioskActive) {
      actions.add(
        IconButton(
          tooltip: l10n.mapSettingsTooltip,
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
        ),
      );
    }
    return actions;
  }

  Widget _buildMapAppBarOverflowMenu({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool kioskActive,
    required bool offlineActive,
    required bool hasOfflinePack,
    required bool mgrsGridEnabled,
  }) {
    return PopupMenuButton<_MapAppBarOverflowAction>(
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      icon: const Icon(Icons.more_vert),
      onSelected: _handleMapAppBarOverflowAction,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: _MapAppBarOverflowAction.toggleMgrsGrid,
            child: _MapAppBarOverflowItem(
              icon: Icons.grid_on,
              label: mgrsGridEnabled
                  ? l10n.mapMgrsGridHideTooltip
                  : l10n.mapMgrsGridShowTooltip,
            ),
          ),
          PopupMenuItem(
            value: _MapAppBarOverflowAction.goHome,
            child: _MapAppBarOverflowItem(
              icon: Icons.home,
              label: l10n.mapHomeTooltip,
            ),
          ),
          if (!kioskActive)
            PopupMenuItem(
              value: _MapAppBarOverflowAction.prepareOffline,
              enabled: !offlineActive,
              child: _MapAppBarOverflowItem(
                icon: hasOfflinePack
                    ? Icons.offline_pin
                    : Icons.download_for_offline_outlined,
                label: hasOfflinePack
                    ? l10n.offlinePackPrepareTooltipReady
                    : l10n.offlinePackPrepareTooltip,
              ),
            ),
          if (!kioskActive)
            PopupMenuItem(
              value: _MapAppBarOverflowAction.exportAtlas,
              enabled: !_isExportingAtlas,
              child: _MapAppBarOverflowItem(
                icon: Icons.picture_as_pdf_outlined,
                label: l10n.mapAtlasTooltip,
              ),
            ),
          PopupMenuItem(
            value: _MapAppBarOverflowAction.openManual,
            child: _MapAppBarOverflowItem(
              icon: Icons.menu_book_outlined,
              label: l10n.mapManualTooltip,
            ),
          ),
          if (!kioskActive)
            PopupMenuItem(
              value: _MapAppBarOverflowAction.openSettings,
              child: _MapAppBarOverflowItem(
                icon: Icons.settings,
                label: l10n.mapSettingsTooltip,
              ),
            ),
        ];
      },
    );
  }

  Future<void> _handleMapAppBarOverflowAction(
    _MapAppBarOverflowAction action,
  ) async {
    switch (action) {
      case _MapAppBarOverflowAction.toggleMgrsGrid:
        ref.read(mapMgrsGridEnabledProvider.notifier).toggle();
      case _MapAppBarOverflowAction.goHome:
        await _goHome();
      case _MapAppBarOverflowAction.prepareOffline:
        await showPrepareOfflinePackDialog(context);
      case _MapAppBarOverflowAction.exportAtlas:
        await _exportMapAtlas();
      case _MapAppBarOverflowAction.openManual:
        _openManual();
      case _MapAppBarOverflowAction.openSettings:
        _openSettings();
    }
  }

  void _openManual() {
    AppLogger.logNav.info('🧭 Navigating to user manual from app bar');
    context.push('/manual');
  }

  void _openSettings() {
    AppLogger.logNav.info('🧭 Navigating to settings from app bar');
    context.push('/settings/general');
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
    final geocodingLoading =
        debouncedQuery.length >= mapSearchMinGeocodingLength &&
        ref.watch(geocodingSearchProvider(debouncedQuery)).isLoading;
    final showSearchResults = searchResults.isNotEmpty || geocodingLoading;
    final mgrsGridEnabled = ref.watch(mapMgrsGridEnabledProvider);
    final deviceLocation = ref.watch(deviceLocationProvider);

    ref.listen<DeviceLocationState>(
      deviceLocationProvider,
      _followDeviceLocation,
    );

    ref.listen<bool>(serverReachableProvider, (previous, next) {
      if (previous == false && next == true) {
        final messenger = ScaffoldMessenger.of(context);
        final syncedMessage = l10n.offlinePackSynced;
        unawaited(() async {
          final flushed = await ref
              .read(offlinePackControllerProvider)
              .syncIfNeeded();
          if (!mounted || flushed <= 0) {
            return;
          }
          messenger.showSnackBar(
            SnackBar(content: Text(syncedMessage(flushed))),
          );
        }());
      }
    });

    final offlineActive = ref.watch(offlineModeActiveProvider);
    final kioskActive = ref.watch(kioskModeActiveProvider);
    final hasOfflinePack =
        ref.watch(offlinePackMetaProvider).valueOrNull != null;

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
        actions: _buildMapAppBarActions(
          context: context,
          l10n: l10n,
          compact:
              MediaQuery.sizeOf(context).width < _mapAppBarCompactBreakpoint,
          kioskActive: kioskActive,
          offlineActive: offlineActive,
          hasOfflinePack: hasOfflinePack,
          mgrsGridEnabled: mgrsGridEnabled,
          deviceLocation: deviceLocation,
        ),
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
            // Header is 8+8 padding + 48 IconButton (=64). 56 overflowed by 8px.
            const sidebarHeightCollapsed = 64.0;
            // Give the map-objects sheet enough room on phones; the old fixed
            // 280px height overflowed once filters + seasonal overlays expanded.
            // Never force a 320px minimum on short landscape heights — that
            // overflowed the Column when rotating a phone with GPS/HUD visible.
            final screenHeight = MediaQuery.sizeOf(context).height;
            final sidebarHeightExpanded = mapObjectsSidebarExpandedHeight(
              screenHeight,
            );

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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
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

class _MapAppBarOverflowItem extends StatelessWidget {
  const _MapAppBarOverflowItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    );
  }
}

/// Expanded map-objects sheet height for the phone (narrow) layout.
///
/// Keeps a usable map viewport when the screen is short (landscape phones).
@visibleForTesting
double mapObjectsSidebarExpandedHeight(double screenHeight) {
  if (screenHeight <= 0) {
    return 160;
  }
  // Leave ≥45% of the screen for the map; allow short landscape sheets.
  final maxHeight = (screenHeight * 0.55).clamp(96.0, 520.0);
  final minHeight = maxHeight < 220 ? maxHeight : 220.0;
  return (screenHeight * 0.48).clamp(minHeight, maxHeight);
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

bool _sameViewport(MapViewport? a, MapViewport? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.center.latitude == b.center.latitude &&
      a.center.longitude == b.center.longitude &&
      a.zoom == b.zoom;
}

bool _sameMarkerId(UuidValue? a, UuidValue? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.toString().toLowerCase() == b.toString().toLowerCase();
}
