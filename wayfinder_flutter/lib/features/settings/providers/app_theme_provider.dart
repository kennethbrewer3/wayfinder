import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme_choice.dart';
import '../../../core/logging/app_logger.dart';
import '../data/app_theme_storage.dart';
import '../data/app_settings_repository.dart';

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeChoice>(
  (ref) => AppThemeNotifier(
    ref.watch(appSettingsRepositoryProvider),
    AppThemeStorage(),
  ),
);

class AppThemeNotifier extends StateNotifier<AppThemeChoice> {
  AppThemeNotifier(this._repository, this._storage) : super(AppThemeChoice.light) {
    _load();
  }

  final AppSettingsRepository _repository;
  final AppThemeStorage _storage;
  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.appTheme;
      await _storage.save(state);
      return;
    } catch (error, _) {
      _log.warn(
        '🎨 Failed to load app theme from server',
        error: error,
      );
    }
    state = await _storage.load();
  }

  Future<void> _save(AppThemeChoice choice) async {
    state = choice;
    await _storage.save(choice);
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(appTheme: choice),
      );
    } catch (error, _) {
      _log.warn(
        '🎨 Failed to save app theme to server',
        error: error,
      );
    }
  }

  Future<void> setFamily(AppThemeFamily family) async {
    await _save(AppThemeChoice.combine(family, state.brightness));
  }

  Future<void> setBrightness(AppThemeBrightness brightness) async {
    await _save(AppThemeChoice.combine(state.family, brightness));
  }
}
