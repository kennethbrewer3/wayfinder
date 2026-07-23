import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme_choice.dart';
import '../../../app/app_theme_ids.dart';
import '../../../core/logging/app_logger.dart';
import '../data/client_ui_preferences_repository.dart';

/// Selected theme storage id: built-in name or `custom:<uuid>`.
final appThemeProvider = StateNotifierProvider<AppThemeNotifier, String>(
  (ref) => AppThemeNotifier(
    ref.watch(clientUiPreferencesRepositoryProvider),
  ),
);

class AppThemeNotifier extends StateNotifier<String> {
  AppThemeNotifier(this._repository) : super(AppThemeIds.defaultId) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = AppThemeIds.normalize(preferences.appTheme);
    } catch (error, _) {
      _log.warn(
        '🎨 Failed to load app theme from device preferences',
        error: error,
      );
      state = AppThemeIds.defaultId;
    }
  }

  Future<void> _save(String themeId) async {
    state = themeId;
    try {
      await _repository.patch(
        (current) => current.copyWith(appTheme: themeId),
      );
    } catch (error, _) {
      _log.warn(
        '🎨 Failed to save app theme to device preferences',
        error: error,
      );
    }
  }

  Future<void> setThemeId(String themeId) async {
    await _save(AppThemeIds.normalize(themeId));
  }

  Future<void> setBuiltIn(AppThemeChoice choice) async {
    await _save(choice.name);
  }

  Future<void> setFamily(AppThemeFamily family) async {
    final current = AppThemeChoice.values
        .where((choice) => choice.name == state)
        .firstOrNull;
    final brightness = current?.brightness ?? AppThemeBrightness.light;
    await _save(AppThemeChoice.combine(family, brightness).name);
  }

  Future<void> setBrightness(AppThemeBrightness brightness) async {
    final current = AppThemeChoice.values
        .where((choice) => choice.name == state)
        .firstOrNull;
    final family = current?.family ?? AppThemeFamily.standard;
    await _save(AppThemeChoice.combine(family, brightness).name);
  }
}
