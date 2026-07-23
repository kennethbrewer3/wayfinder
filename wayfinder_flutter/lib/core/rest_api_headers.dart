import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'app_globals.dart';
import 'rest_api_key_storage.dart';

/// Headers for authenticated calls to the Wayfinder REST API on the web server.
abstract final class RestApiHeaders {
  static const apiKeyHeader = 'X-API-Key';

  static Future<Map<String, String>> json({Map<String, String>? extra}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };
    await _attachCredentials(headers);
    return headers;
  }

  static Future<Map<String, String>> readOnly({
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{...?extra};
    await _attachCredentials(headers);
    return headers;
  }

  static Future<void> _attachCredentials(Map<String, String> headers) async {
    final apiKey = await RestApiKeyStorage.read();
    if (apiKey != null && apiKey.isNotEmpty) {
      headers[apiKeyHeader] = apiKey;
      return;
    }

    try {
      final authHeader = await client.auth.authHeaderValue;
      if (authHeader != null && authHeader.isNotEmpty) {
        headers['Authorization'] = authHeader;
      }
    } catch (_) {
      // Auth session manager may not be configured yet (e.g. early startup).
    }
  }
}
