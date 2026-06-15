import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants.dart';
import '../data/map_viewport_storage.dart';
import '../models/map_viewport.dart';

final mapViewportStorageProvider = Provider<MapViewportStorage>(
  (ref) => MapViewportStorage(),
);

class MapViewportNotifier extends StateNotifier<AsyncValue<MapViewport>> {
  MapViewportNotifier(this._storage)
      : super(
          const AsyncValue.loading(),
        ) {
    _load();
  }

  final MapViewportStorage _storage;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_storage.loadViewport);
  }

  Future<void> setViewport(MapViewport viewport) async {
    state = AsyncValue.data(viewport);
    await _storage.saveViewport(viewport);
  }

  Future<void> moveTo({
    required LatLng center,
    required double zoom,
  }) {
    return setViewport(MapViewport(center: center, zoom: zoom));
  }

  Future<void> applyDefaults() {
    return setViewport(
      const MapViewport(
        center: LatLng(
          AppConstants.defaultLatitude,
          AppConstants.defaultLongitude,
        ),
        zoom: AppConstants.defaultZoom,
      ),
    );
  }
}

final mapViewportProvider =
    StateNotifierProvider<MapViewportNotifier, AsyncValue<MapViewport>>(
  (ref) => MapViewportNotifier(ref.watch(mapViewportStorageProvider)),
);

enum SidebarViewMode { list, tree }

enum SidebarPanelTab { markers, zones }

enum MarkerSortField { name, hue, icon }

enum ZoneSortField { name, hue, type }

class SidebarState {
  const SidebarState({
    this.viewMode = SidebarViewMode.list,
    this.activeTab = SidebarPanelTab.markers,
    this.markerSort = MarkerSortField.name,
    this.zoneSort = ZoneSortField.name,
    this.searchQuery = '',
    this.expanded = true,
  });

  final SidebarViewMode viewMode;
  final SidebarPanelTab activeTab;
  final MarkerSortField markerSort;
  final ZoneSortField zoneSort;
  final String searchQuery;
  final bool expanded;

  SidebarState copyWith({
    SidebarViewMode? viewMode,
    SidebarPanelTab? activeTab,
    MarkerSortField? markerSort,
    ZoneSortField? zoneSort,
    String? searchQuery,
    bool? expanded,
  }) {
    return SidebarState(
      viewMode: viewMode ?? this.viewMode,
      activeTab: activeTab ?? this.activeTab,
      markerSort: markerSort ?? this.markerSort,
      zoneSort: zoneSort ?? this.zoneSort,
      searchQuery: searchQuery ?? this.searchQuery,
      expanded: expanded ?? this.expanded,
    );
  }
}

class SidebarNotifier extends StateNotifier<SidebarState> {
  SidebarNotifier() : super(const SidebarState());

  void setViewMode(SidebarViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setActiveTab(SidebarPanelTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setMarkerSort(MarkerSortField sort) {
    state = state.copyWith(markerSort: sort);
  }

  void setZoneSort(ZoneSortField sort) {
    state = state.copyWith(zoneSort: sort);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setExpanded(bool expanded) {
    state = state.copyWith(expanded: expanded);
  }

  void toggleExpanded() {
    state = state.copyWith(expanded: !state.expanded);
  }
}

final sidebarProvider =
    StateNotifierProvider<SidebarNotifier, SidebarState>(
  (ref) => SidebarNotifier(),
);
