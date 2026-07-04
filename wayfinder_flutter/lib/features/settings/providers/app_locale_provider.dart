import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_locale_choice.dart';
import '../../../core/logging/app_logger.dart';
import '../data/app_settings_repository.dart';

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, AppLocaleChoice>(
      (ref) => AppLocaleNotifier(ref.watch(appSettingsRepositoryProvider)),
    );

class AppLocaleNotifier extends StateNotifier<AppLocaleChoice> {
  AppLocaleNotifier(this._repository) : super(AppLocaleChoice.system) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.appLocale;
    } catch (error, _) {
      _log.warn(
        '🌐 Failed to load app locale from server',
        error: error,
      );
      state = AppLocaleChoice.system;
    }
  }

  Future<void> setLocale(AppLocaleChoice choice) async {
    state = choice;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(appLocale: choice),
      );
    } catch (error, _) {
      _log.warn(
        '🌐 Failed to save app locale to server',
        error: error,
      );
    }
  }
}
