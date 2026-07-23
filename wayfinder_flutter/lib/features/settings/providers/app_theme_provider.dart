import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../app/app_theme_choice.dart';
import '../../../app/app_theme_ids.dart';
import '../../../core/logging/app_logger.dart';
import '../data/client_ui_preferences_repository.dart';

/// Selected theme storage id: built-in name or `custom:<uuid>` / `:dark`.
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

  AppThemeFamily _lastFamily = AppThemeFamily.standard;
  AppThemeBrightness _lastBrightness = AppThemeBrightness.light;

  AppThemeFamily get lastFamily => _lastFamily;
  AppThemeBrightness get lastBrightness => _lastBrightness;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      final themeId = AppThemeIds.normalize(preferences.appTheme);
      _syncRememberedSelection(themeId);
      state = themeId;
    } catch (error, _) {
      _log.warn(
        '🎨 Failed to load app theme from device preferences',
        error: error,
      );
      state = AppThemeIds.defaultId;
      _lastFamily = AppThemeFamily.standard;
      _lastBrightness = AppThemeBrightness.light;
    }
  }

  void _syncRememberedSelection(String themeId) {
    final builtIn = AppThemeChoice.values
        .where((choice) => choice.name == themeId)
        .firstOrNull;
    if (builtIn != null) {
      _lastFamily = builtIn.family;
      _lastBrightness = builtIn.brightness;
      return;
    }
    if (AppThemeIds.isCustom(themeId)) {
      _lastBrightness = AppThemeIds.isCustomDark(themeId)
          ? AppThemeBrightness.dark
          : AppThemeBrightness.light;
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
    final normalized = AppThemeIds.normalize(themeId);
    _syncRememberedSelection(normalized);
    await _save(normalized);
  }

  Future<void> setBuiltIn(AppThemeChoice choice) async {
    _lastFamily = choice.family;
    _lastBrightness = choice.brightness;
    await _save(choice.name);
  }

  /// Dropdown selection for a built-in family (Standard / Military).
  Future<void> setFamily(AppThemeFamily family) async {
    _lastFamily = family;
    await _save(AppThemeChoice.combine(family, _lastBrightness).name);
  }

  /// Dark mode toggle for the current theme family (built-in or custom).
  ///
  /// Custom themes keep the same seed; dark is generated with
  /// [ColorScheme.fromSeed].
  Future<void> setDarkMode(bool dark) async {
    _lastBrightness = dark ? AppThemeBrightness.dark : AppThemeBrightness.light;
    await _save(AppThemeIds.withDarkMode(state, dark));
  }

  /// Select a custom TOC theme, keeping the current dark-mode preference.
  Future<void> setCustomTheme(UuidValue id) async {
    final dark = _lastBrightness == AppThemeBrightness.dark;
    await _save(AppThemeIds.forCustom(id, dark: dark));
  }
}
