import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';

class MapViewportDebugStorage {
  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.mapViewportDebugBorderStorageKey) ?? false;
  }

  Future<void> save(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.mapViewportDebugBorderStorageKey, enabled);
  }
}
