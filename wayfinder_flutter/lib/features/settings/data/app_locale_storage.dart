import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_locale_choice.dart';
import '../../../core/constants.dart';

class AppLocaleStorage {
  Future<AppLocaleChoice> load() async {
    final prefs = await SharedPreferences.getInstance();
    return appLocaleChoiceFromStorage(
      prefs.getString(AppConstants.appLocaleStorageKey),
    );
  }

  Future<void> save(AppLocaleChoice choice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.appLocaleStorageKey,
      appLocaleChoiceToStorage(choice),
    );
  }
}
