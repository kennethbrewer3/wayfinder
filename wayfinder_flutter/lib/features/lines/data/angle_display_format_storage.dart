import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/angle_display_format.dart';

class AngleDisplayFormatStorage {
  Future<AngleDisplayFormat> load() async {
    final prefs = await SharedPreferences.getInstance();
    return angleDisplayFormatFromStorage(
      prefs.getString(AppConstants.angleDisplayFormatStorageKey),
    );
  }

  Future<void> save(AngleDisplayFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.angleDisplayFormatStorageKey,
      angleDisplayFormatToStorage(format),
    );
  }
}
