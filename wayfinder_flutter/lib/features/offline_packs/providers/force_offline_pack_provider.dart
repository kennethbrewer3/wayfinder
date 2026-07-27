import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';

const forceOfflinePackWhileOnlinePrefsKey =
    'wayfinder.forceOfflinePackWhileOnline';

/// Whether offline mode should be active.
///
/// Normally requires the server to be unreachable. [forceWhileOnline] lets
/// testers exercise a prepared offline / field pack without cutting internet.
bool isOfflineModeActive({
  required bool serverReachable,
  required bool hasPack,
  required bool forceWhileOnline,
}) {
  if (!hasPack) {
    return false;
  }
  return forceWhileOnline || !serverReachable;
}

/// Device-local debug flag: use the offline pack even when the server is up.
final forceOfflinePackWhileOnlineProvider =
    StateNotifierProvider<ForceOfflinePackWhileOnlineNotifier, bool>(
      (ref) => ForceOfflinePackWhileOnlineNotifier(),
    );

class ForceOfflinePackWhileOnlineNotifier extends StateNotifier<bool> {
  ForceOfflinePackWhileOnlineNotifier() : super(false) {
    _load();
  }

  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(forceOfflinePackWhileOnlinePrefsKey) ?? false;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load force-offline-pack preference',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(forceOfflinePackWhileOnlinePrefsKey, enabled);
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save force-offline-pack preference',
        error: error,
      );
    }
  }
}
