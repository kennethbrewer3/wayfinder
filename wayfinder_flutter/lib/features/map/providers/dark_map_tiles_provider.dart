import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';

final darkMapTilesInDarkModeProvider =
    StateNotifierProvider<DarkMapTilesInDarkModeNotifier, bool>(
      (ref) => DarkMapTilesInDarkModeNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class DarkMapTilesInDarkModeNotifier extends StateNotifier<bool> {
  DarkMapTilesInDarkModeNotifier(this._repository) : super(true) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.darkMapTilesInDarkMode;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load dark map tiles preference',
        error: error,
      );
      state = true;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _repository.patch(
        (current) => current.copyWith(darkMapTilesInDarkMode: enabled),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save dark map tiles preference',
        error: error,
      );
    }
  }
}
