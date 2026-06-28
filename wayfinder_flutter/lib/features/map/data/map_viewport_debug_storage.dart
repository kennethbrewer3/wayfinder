import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';

class MapViewportDebugStorage {
  Future<bool> loadOverlay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.mapViewportDebugBorderStorageKey) ?? false;
  }

  Future<bool> loadTileBorders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.mapTileBorderDebugStorageKey) ?? false;
  }

  Future<void> saveOverlay(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.mapViewportDebugBorderStorageKey, enabled);
  }

  Future<void> saveTileBorders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.mapTileBorderDebugStorageKey, enabled);
  }
}
