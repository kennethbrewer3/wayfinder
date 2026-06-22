import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_theme_choice.dart';
import '../../../core/constants.dart';

class AppThemeStorage {
  Future<AppThemeChoice> load() async {
    final prefs = await SharedPreferences.getInstance();
    return appThemeChoiceFromStorage(
      prefs.getString(AppConstants.appThemeStorageKey),
    );
  }

  Future<void> save(AppThemeChoice choice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.appThemeStorageKey,
      appThemeChoiceToStorage(choice),
    );
  }
}
