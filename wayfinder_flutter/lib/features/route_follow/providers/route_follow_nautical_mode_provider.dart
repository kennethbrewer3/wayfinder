import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';

const routeFollowNauticalModePrefsKey = 'wayfinder.routeFollowNauticalMode';

/// Device-local: use port/starboard instead of left/right in route-follow HUD.
final routeFollowNauticalModeProvider =
    StateNotifierProvider<RouteFollowNauticalModeNotifier, bool>(
      (ref) => RouteFollowNauticalModeNotifier(),
    );

class RouteFollowNauticalModeNotifier extends StateNotifier<bool> {
  RouteFollowNauticalModeNotifier() : super(false) {
    _load();
  }

  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(routeFollowNauticalModePrefsKey) ?? false;
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load nautical route-follow preference',
        error: error,
      );
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(routeFollowNauticalModePrefsKey, enabled);
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save nautical route-follow preference',
        error: error,
      );
    }
  }

  Future<void> toggle() => setEnabled(!state);
}
