import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import 'selected_map_object_provider.dart';
import '../../settings/data/app_settings_repository.dart';
import '../data/map_viewport_storage.dart';
import '../models/home_location.dart';
import '../models/map_viewport.dart';

final mapViewportStorageProvider = Provider<MapViewportStorage>(
  (ref) => MapViewportStorage(),
);

class MapViewportNotifier extends StateNotifier<AsyncValue<MapViewport>> {
  MapViewportNotifier(this._storage, this._appSettingsRepository)
      : super(
          const AsyncValue.loading(),
        ) {
    _load();
  }

  final MapViewportStorage _storage;
  final AppSettingsRepository _appSettingsRepository;
  MapViewport? _deepLinkViewport;

  /// URL `/maps?lat=…` should win over persisted viewport on cold start.
  void setDeepLinkViewport(MapViewport viewport) {
    _deepLinkViewport = viewport;
    if (state.isLoading) {
      return;
    }
    unawaited(_applyDeepLink(viewport));
  }

  Future<void> _applyDeepLink(MapViewport viewport) async {
    _deepLinkViewport = null;
    await setViewport(viewport);
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final deepLink = _deepLinkViewport;
      if (deepLink != null) {
        _deepLinkViewport = null;
        await _storage.saveViewport(deepLink);
        return deepLink;
      }
      final saved = await _storage.loadSavedViewport();
      if (saved != null) {
        return saved;
      }
      return (await _appSettingsRepository.getHomeLocation()).toViewport();
    });
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

  Future<void> goHome(HomeLocation home) {
    return setViewport(home.toViewport());
  }
}

final mapViewportProvider =
    StateNotifierProvider<MapViewportNotifier, AsyncValue<MapViewport>>(
  (ref) => MapViewportNotifier(
    ref.watch(mapViewportStorageProvider),
    ref.watch(appSettingsRepositoryProvider),
  ),
);

enum SidebarViewMode { list, tree }

enum SidebarPanelTab { markers, zones }

enum MarkerSortField { name, hue, icon, visibility }

enum ZoneSortField { name, hue, type, visibility }

extension MarkerSortFieldLabel on MarkerSortField {
  String get label => switch (this) {
        MarkerSortField.name => 'Name',
        MarkerSortField.hue => 'Hue',
        MarkerSortField.icon => 'Icon',
        MarkerSortField.visibility => 'Visibility',
      };
}

extension ZoneSortFieldLabel on ZoneSortField {
  String get label => switch (this) {
        ZoneSortField.name => 'Name',
        ZoneSortField.hue => 'Hue',
        ZoneSortField.type => 'Type',
        ZoneSortField.visibility => 'Visibility',
      };
}

class LayerSidebarSettings {
  const LayerSidebarSettings({
    this.activeTab = SidebarPanelTab.markers,
    this.viewMode = SidebarViewMode.list,
    this.markerSort = MarkerSortField.name,
    this.zoneSort = ZoneSortField.name,
  });

  final SidebarPanelTab activeTab;
  final SidebarViewMode viewMode;
  final MarkerSortField markerSort;
  final ZoneSortField zoneSort;

  LayerSidebarSettings copyWith({
    SidebarPanelTab? activeTab,
    SidebarViewMode? viewMode,
    MarkerSortField? markerSort,
    ZoneSortField? zoneSort,
  }) {
    return LayerSidebarSettings(
      activeTab: activeTab ?? this.activeTab,
      viewMode: viewMode ?? this.viewMode,
      markerSort: markerSort ?? this.markerSort,
      zoneSort: zoneSort ?? this.zoneSort,
    );
  }
}

class SidebarState {
  const SidebarState({
    this.searchQuery = '',
    this.expanded = true,
    this.selectedLayerId,
    this.expandedLayerIds,
    this.layerSettings = const {},
  });

  final String searchQuery;
  final bool expanded;
  final UuidValue? selectedLayerId;
  /// `null` = all layers expanded (initial default).
  /// Non-null set tracks explicit expand/collapse; empty set = all collapsed.
  final Set<UuidValue>? expandedLayerIds;
  final Map<UuidValue, LayerSidebarSettings> layerSettings;

  LayerSidebarSettings settingsForLayer(UuidValue layerId) {
    return layerSettings[layerId] ?? const LayerSidebarSettings();
  }

  SidebarState copyWith({
    String? searchQuery,
    bool? expanded,
    UuidValue? selectedLayerId,
    Set<UuidValue>? expandedLayerIds,
    Map<UuidValue, LayerSidebarSettings>? layerSettings,
  }) {
    return SidebarState(
      searchQuery: searchQuery ?? this.searchQuery,
      expanded: expanded ?? this.expanded,
      selectedLayerId: selectedLayerId ?? this.selectedLayerId,
      expandedLayerIds: expandedLayerIds ?? this.expandedLayerIds,
      layerSettings: layerSettings ?? this.layerSettings,
    );
  }
}

class SidebarNotifier extends StateNotifier<SidebarState> {
  SidebarNotifier() : super(const SidebarState());

  void _updateLayerSettings(
    UuidValue layerId,
    LayerSidebarSettings Function(LayerSidebarSettings current) update,
  ) {
    final current = state.settingsForLayer(layerId);
    state = state.copyWith(
      layerSettings: {
        ...state.layerSettings,
        layerId: update(current),
      },
    );
  }

  void setLayerActiveTab(UuidValue layerId, SidebarPanelTab tab) {
    _updateLayerSettings(layerId, (current) => current.copyWith(activeTab: tab));
  }

  void setLayerViewMode(UuidValue layerId, SidebarViewMode mode) {
    _updateLayerSettings(layerId, (current) => current.copyWith(viewMode: mode));
  }

  void setLayerMarkerSort(UuidValue layerId, MarkerSortField sort) {
    _updateLayerSettings(
      layerId,
      (current) => current.copyWith(markerSort: sort),
    );
  }

  void setLayerZoneSort(UuidValue layerId, ZoneSortField sort) {
    _updateLayerSettings(layerId, (current) => current.copyWith(zoneSort: sort));
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setExpanded(bool expanded) {
    state = state.copyWith(expanded: expanded);
  }

  void setSelectedLayerId(UuidValue? layerId) {
    state = state.copyWith(selectedLayerId: layerId);
  }

  void toggleLayerExpanded(
    UuidValue layerId, {
    required bool expanded,
    required Iterable<UuidValue> allLayerIds,
  }) {
    final next = state.expandedLayerIds == null
        ? Set<UuidValue>.from(allLayerIds)
        : Set<UuidValue>.from(state.expandedLayerIds!);
    if (expanded) {
      next.add(layerId);
    } else {
      next.remove(layerId);
    }
    state = state.copyWith(expandedLayerIds: next);
  }

  void revealMapObject({
    required SelectedMapObjectKind kind,
    UuidValue? layerId,
  }) {
    Set<UuidValue>? expandedLayerIds;
    Map<UuidValue, LayerSidebarSettings>? layerSettings;

    if (layerId != null) {
      if (state.expandedLayerIds != null) {
        expandedLayerIds = {...state.expandedLayerIds!, layerId};
      }
      layerSettings = {
        ...state.layerSettings,
        layerId: state.settingsForLayer(layerId).copyWith(
          activeTab: kind == SelectedMapObjectKind.marker
              ? SidebarPanelTab.markers
              : SidebarPanelTab.zones,
        ),
      };
    }

    state = state.copyWith(
      expanded: true,
      selectedLayerId: layerId ?? state.selectedLayerId,
      expandedLayerIds: expandedLayerIds ?? state.expandedLayerIds,
      layerSettings: layerSettings ?? state.layerSettings,
    );
  }

  void toggleExpanded() {
    state = state.copyWith(expanded: !state.expanded);
  }
}

final sidebarProvider =
    StateNotifierProvider<SidebarNotifier, SidebarState>(
  (ref) => SidebarNotifier(),
);
