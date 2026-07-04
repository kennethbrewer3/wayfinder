import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';

final mapViewportDebugBorderProvider =
    StateNotifierProvider<MapViewportDebugBorderNotifier, bool>(
      (ref) => MapViewportDebugBorderNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

final mapTileBorderDebugProvider =
    StateNotifierProvider<MapTileBorderDebugNotifier, bool>(
      (ref) => MapTileBorderDebugNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class MapViewportDebugBorderNotifier extends StateNotifier<bool> {
  MapViewportDebugBorderNotifier(this._repository) : super(false) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.mapViewportDebugBorder;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load map viewport debug from server',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(mapViewportDebugBorder: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save map viewport debug to server',
        error: error,
      );
    }
  }
}

class MapTileBorderDebugNotifier extends StateNotifier<bool> {
  MapTileBorderDebugNotifier(this._repository) : super(false) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.mapTileBorderDebug;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load map tile border debug from server',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(mapTileBorderDebug: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save map tile border debug to server',
        error: error,
      );
    }
  }
}
