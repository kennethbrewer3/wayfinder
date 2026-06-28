import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/map_viewport_debug_storage.dart';

final mapViewportDebugBorderProvider =
    StateNotifierProvider<MapViewportDebugBorderNotifier, bool>(
  (ref) => MapViewportDebugBorderNotifier(MapViewportDebugStorage()),
);

final mapTileBorderDebugProvider =
    StateNotifierProvider<MapTileBorderDebugNotifier, bool>(
  (ref) => MapTileBorderDebugNotifier(MapViewportDebugStorage()),
);

class MapViewportDebugBorderNotifier extends StateNotifier<bool> {
  MapViewportDebugBorderNotifier(this._storage) : super(false) {
    _load();
  }

  final MapViewportDebugStorage _storage;

  Future<void> _load() async {
    state = await _storage.loadOverlay();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _storage.saveOverlay(enabled);
  }
}

class MapTileBorderDebugNotifier extends StateNotifier<bool> {
  MapTileBorderDebugNotifier(this._storage) : super(false) {
    _load();
  }

  final MapViewportDebugStorage _storage;

  Future<void> _load() async {
    state = await _storage.loadTileBorders();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _storage.saveTileBorders(enabled);
  }
}
