import 'package:shared_preferences/shared_preferences.dart';

const _restApiKeyPrefsKey = 'wayfinder.restApiKey';

class RestApiKeyStorage {
  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_restApiKeyPrefsKey)?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  static Future<void> write(String? apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = apiKey?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await prefs.remove(_restApiKeyPrefsKey);
      return;
    }
    await prefs.setString(_restApiKeyPrefsKey, trimmed);
  }
}
