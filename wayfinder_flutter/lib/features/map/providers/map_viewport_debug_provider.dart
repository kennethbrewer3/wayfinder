import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';

final mapViewportDebugBorderProvider =
    StateNotifierProvider<MapViewportDebugBorderNotifier, bool>(
      (ref) => MapViewportDebugBorderNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

final mapTileBorderDebugProvider =
    StateNotifierProvider<MapTileBorderDebugNotifier, bool>(
      (ref) => MapTileBorderDebugNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class MapViewportDebugBorderNotifier extends StateNotifier<bool> {
  MapViewportDebugBorderNotifier(this._repository) : super(false) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.mapViewportDebugBorder;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load map viewport debug from device preferences',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patch(
        (current) => current.copyWith(mapViewportDebugBorder: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save map viewport debug to device preferences',
        error: error,
      );
    }
  }
}

class MapTileBorderDebugNotifier extends StateNotifier<bool> {
  MapTileBorderDebugNotifier(this._repository) : super(false) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.mapTileBorderDebug;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load map tile border debug from device preferences',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patch(
        (current) => current.copyWith(mapTileBorderDebug: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save map tile border debug to device preferences',
        error: error,
      );
    }
  }
}
