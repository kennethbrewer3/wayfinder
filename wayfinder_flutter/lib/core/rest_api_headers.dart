import 'rest_api_key_storage.dart';

/// Headers for authenticated calls to the Wayfinder REST API on the web server.
abstract final class RestApiHeaders {
  static const apiKeyHeader = 'X-API-Key';

  static Future<Map<String, String>> json({Map<String, String>? extra}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };
    final apiKey = await RestApiKeyStorage.read();
    if (apiKey != null && apiKey.isNotEmpty) {
      headers[apiKeyHeader] = apiKey;
    }
    return headers;
  }

  static Future<Map<String, String>> readOnly({Map<String, String>? extra}) async {
    final headers = <String, String>{...?extra};
    final apiKey = await RestApiKeyStorage.read();
    if (apiKey != null && apiKey.isNotEmpty) {
      headers[apiKeyHeader] = apiKey;
    }
    return headers;
  }
}
