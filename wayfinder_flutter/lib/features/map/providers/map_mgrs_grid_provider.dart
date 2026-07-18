import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';

final mapMgrsGridEnabledProvider =
    StateNotifierProvider<MapMgrsGridEnabledNotifier, bool>(
      (ref) => MapMgrsGridEnabledNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class MapMgrsGridEnabledNotifier extends StateNotifier<bool> {
  MapMgrsGridEnabledNotifier(this._repository) : super(false) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.mapMgrsGridEnabled;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load MGRS grid setting from server',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(mapMgrsGridEnabled: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save MGRS grid setting to server',
        error: error,
      );
    }
  }

  Future<void> toggle() => setEnabled(!state);
}
