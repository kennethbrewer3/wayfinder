import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';

final polygonSnapRightAnglesProvider =
    StateNotifierProvider<PolygonSnapRightAnglesNotifier, bool>(
      (ref) => PolygonSnapRightAnglesNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class PolygonSnapRightAnglesNotifier extends StateNotifier<bool> {
  PolygonSnapRightAnglesNotifier(this._repository) : super(true) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.polygonSnapRightAngles;
    } catch (error, _) {
      _log.warn(
        '📐 Failed to load polygon 90° snap setting from server',
        error: error,
      );
      state = true;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(polygonSnapRightAngles: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '📐 Failed to save polygon 90° snap setting to server',
        error: error,
      );
    }
  }
}

final polygonSnap45AnglesProvider =
    StateNotifierProvider<PolygonSnap45AnglesNotifier, bool>(
      (ref) => PolygonSnap45AnglesNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class PolygonSnap45AnglesNotifier extends StateNotifier<bool> {
  PolygonSnap45AnglesNotifier(this._repository) : super(false) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.polygonSnap45Angles;
    } catch (error, _) {
      _log.warn(
        '📐 Failed to load polygon 45° snap setting from server',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(polygonSnap45Angles: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '📐 Failed to save polygon 45° snap setting to server',
        error: error,
      );
    }
  }
}
