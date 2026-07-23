import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/client_preferences.dart';

/// Device cache / offline fallback for UI preferences.
///
/// Signed-in users sync to the server; this storage is a local cache keyed by
/// auth user id, plus an unscoped key for unsigned / open-mode use.
abstract final class ClientUiPreferencesStorage {
  static const _legacyKey = 'wayfinder.clientUiPreferences';
  static const _userKeyPrefix = 'wayfinder.clientUiPreferences.user.';

  static String _keyForUser(String? authUserId) {
    if (authUserId == null || authUserId.isEmpty) {
      return _legacyKey;
    }
    return '$_userKeyPrefix$authUserId';
  }

  static Future<ClientPreferences?> read({String? authUserId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForUser(authUserId);
    var raw = prefs.getString(key);
    // Migrate pre-account-local cache into the signed-in user's key once.
    if ((raw == null || raw.isEmpty) &&
        authUserId != null &&
        authUserId.isNotEmpty) {
      raw = prefs.getString(_legacyKey);
    }
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return ClientPreferences.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(
    ClientPreferences preferences, {
    String? authUserId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(authUserId),
      jsonEncode(preferences.toLocalJson()),
    );
  }
}
