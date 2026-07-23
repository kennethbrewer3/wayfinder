import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_locale_choice.dart';
import '../../../core/logging/app_logger.dart';
import '../data/client_ui_preferences_repository.dart';

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, AppLocaleChoice>(
      (ref) => AppLocaleNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class AppLocaleNotifier extends StateNotifier<AppLocaleChoice> {
  AppLocaleNotifier(this._repository) : super(AppLocaleChoice.system) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.appLocale;
    } catch (error, _) {
      _log.warn(
        '🌐 Failed to load app locale from device preferences',
        error: error,
      );
      state = AppLocaleChoice.system;
    }
  }

  Future<void> setLocale(AppLocaleChoice choice) async {
    state = choice;
    try {
      await _repository.patch(
        (current) => current.copyWith(appLocale: choice),
      );
    } catch (error, _) {
      _log.warn(
        '🌐 Failed to save app locale to device preferences',
        error: error,
      );
    }
  }
}
