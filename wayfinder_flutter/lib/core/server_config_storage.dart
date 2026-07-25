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

  Future<String?> loadWebUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.serverWebUrlStorageKey);
  }

  Future<void> saveWebUrl(String webUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.serverWebUrlStorageKey, webUrl);
  }

  Future<void> clearWebUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.serverWebUrlStorageKey);
  }

  Future<void> clearServerUrls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.serverApiUrlStorageKey);
    await prefs.remove(AppConstants.serverWebUrlStorageKey);
  }

  Future<String?> loadGeocodingWebUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.geocodingWebUrlStorageKey);
  }

  Future<void> saveGeocodingWebUrl(String geocodingWebUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.geocodingWebUrlStorageKey,
      geocodingWebUrl,
    );
  }

  Future<void> clearGeocodingWebUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.geocodingWebUrlStorageKey);
  }
}
