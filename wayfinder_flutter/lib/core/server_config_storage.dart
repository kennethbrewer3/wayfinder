import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ServerConfigStorage {
  Future<String?> loadApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.serverApiUrlStorageKey);
  }

  Future<void> saveApiUrl(String apiUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.serverApiUrlStorageKey, apiUrl);
  }

  Future<void> clearApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.serverApiUrlStorageKey);
  }
}
