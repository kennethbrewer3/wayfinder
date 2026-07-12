import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';

final mapCompassRoseEnabledProvider =
    StateNotifierProvider<MapCompassRoseEnabledNotifier, bool>(
      (ref) => MapCompassRoseEnabledNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class MapCompassRoseEnabledNotifier extends StateNotifier<bool> {
  MapCompassRoseEnabledNotifier(this._repository) : super(true) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.mapCompassRoseEnabled;
    } catch (error, _) {
      _log.warn(
        '🧭 Failed to load compass rose setting from server',
        error: error,
      );
      state = true;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(mapCompassRoseEnabled: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🧭 Failed to save compass rose setting to server',
        error: error,
      );
    }
  }
}
