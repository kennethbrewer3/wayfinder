import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/circle_size_display.dart';

class CircleSizeDisplayStorage {
  Future<CircleSizeDisplay> load() async {
    final prefs = await SharedPreferences.getInstance();
    return circleSizeDisplayFromStorage(
      prefs.getString(AppConstants.circleSizeDisplayStorageKey),
    );
  }

  Future<void> save(CircleSizeDisplay display) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.circleSizeDisplayStorageKey,
      circleSizeDisplayToStorage(display),
    );
  }
}
