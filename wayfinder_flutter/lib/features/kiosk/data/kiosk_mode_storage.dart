import 'package:shared_preferences/shared_preferences.dart';

/// Local-only kiosk preference for spare TOC / viewer laptops.
abstract final class KioskModeStorage {
  static const preferenceKey = 'wayfinder.kioskMode';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(preferenceKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preferenceKey, enabled);
  }
}
