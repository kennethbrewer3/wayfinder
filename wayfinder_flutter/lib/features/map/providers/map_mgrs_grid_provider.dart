import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';

final mapMgrsGridEnabledProvider =
    StateNotifierProvider<MapMgrsGridEnabledNotifier, bool>(
      (ref) => MapMgrsGridEnabledNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class MapMgrsGridEnabledNotifier extends StateNotifier<bool> {
  MapMgrsGridEnabledNotifier(this._repository) : super(false) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.mapMgrsGridEnabled;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load MGRS grid setting from device preferences',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patch(
        (current) => current.copyWith(mapMgrsGridEnabled: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save MGRS grid setting to device preferences',
        error: error,
      );
    }
  }

  Future<void> toggle() => setEnabled(!state);
}
