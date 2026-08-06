import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';

const radioSyncEnabledPrefsKey = 'wayfinder.radio_sync.enabled';

/// Whether radio-sync dual-write (outbox enqueue on mutations) is enabled.
final radioSyncEnabledProvider =
    StateNotifierProvider<RadioSyncEnabledNotifier, bool>(
      (ref) => RadioSyncEnabledNotifier(),
    );

class RadioSyncEnabledNotifier extends StateNotifier<bool> {
  RadioSyncEnabledNotifier() : super(false) {
    _load();
  }

  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(radioSyncEnabledPrefsKey) ?? false;
    } catch (error, _) {
      _log.warn('Failed to load radio-sync enabled preference', error: error);
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(radioSyncEnabledPrefsKey, enabled);
    } catch (error, _) {
      _log.warn('Failed to save radio-sync enabled preference', error: error);
    }
  }
}
