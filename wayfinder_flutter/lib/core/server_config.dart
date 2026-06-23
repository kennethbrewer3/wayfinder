import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'server_config_storage.dart';

class AppServerConfig {
  const AppServerConfig({
    required this.apiUrl,
    required this.webUrl,
    this.geocodingWebUrl,
  });

  final String apiUrl;
  final String webUrl;
  final String? geocodingWebUrl;
}

const defaultApiUrl = 'http://localhost:18080';
const defaultWebUrl = 'http://localhost:18082';
const defaultGeocodingWebUrl = 'http://localhost:18182';

Future<AppServerConfig> loadAppServerConfig() async {
  const apiUrlFromEnv = String.fromEnvironment('SERVER_URL');
  const webUrlFromEnv = String.fromEnvironment('WEB_SERVER_URL');
  const geocodingWebUrlFromEnv = String.fromEnvironment('GEOCODING_SERVER_URL');

  if (apiUrlFromEnv.isNotEmpty) {
    return AppServerConfig(
      apiUrl: normalizeApiUrl(apiUrlFromEnv),
      webUrl: webUrlFromEnv.isNotEmpty
          ? normalizeWebUrl(webUrlFromEnv)
          : (defaultWebUrlForApi(apiUrlFromEnv) ?? defaultWebUrl),
      geocodingWebUrl: geocodingWebUrlFromEnv.isNotEmpty
          ? normalizeWebUrl(geocodingWebUrlFromEnv)
          : null,
    );
  }

  final storage = ServerConfigStorage();
  final savedApiUrl = await storage.loadApiUrl();
  final savedGeocodingWebUrl = await storage.loadGeocodingWebUrl();
  if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
    final apiUrl = normalizeApiUrl(savedApiUrl);
    return AppServerConfig(
      apiUrl: apiUrl,
      webUrl: defaultWebUrlForApi(apiUrl) ?? defaultWebUrl,
      geocodingWebUrl: savedGeocodingWebUrl != null &&
              savedGeocodingWebUrl.isNotEmpty
          ? normalizeWebUrl(savedGeocodingWebUrl)
          : null,
    );
  }

  final deployedConfig = await _loadDeployedWebConfig();
  if (deployedConfig != null) {
    return deployedConfig;
  }

  try {
    final data = await rootBundle.loadString('assets/config.json');
    return _configFromJsonMap(jsonDecode(data) as Map<String, dynamic>);
  } catch (_) {
    return const AppServerConfig(
      apiUrl: defaultApiUrl,
      webUrl: defaultWebUrl,
    );
  }
}

AppServerConfig _configFromJsonMap(Map<String, dynamic> config) {
  final apiUrl = normalizeApiUrl(
    config['apiUrl'] as String? ?? defaultApiUrl,
  );
  final webUrl = normalizeWebUrl(
    config['webUrl'] as String? ??
        defaultWebUrlForApi(apiUrl) ??
        defaultWebUrl,
  );
  final geocodingRaw = config['geocodingWebUrl'] as String?;
  final geocodingWebUrl = geocodingRaw == null || geocodingRaw.trim().isEmpty
      ? null
      : normalizeWebUrl(geocodingRaw);
  return AppServerConfig(
    apiUrl: apiUrl,
    webUrl: webUrl,
    geocodingWebUrl: geocodingWebUrl,
  );
}

Future<AppServerConfig?> _loadDeployedWebConfig() async {
  if (!kIsWeb) {
    return null;
  }

  try {
    final response = await http
        .get(Uri.base.resolve('config.json'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      return null;
    }

    return _configFromJsonMap(jsonDecode(response.body) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

/// Backwards-compatible helper used by existing startup code.
Future<String> getServerUrl() async {
  final config = await loadAppServerConfig();
  return config.apiUrl;
}

String normalizeApiUrl(String input) {
  final uri = _parseServerUri(input);
  return _formatServerUri(uri);
}

String normalizeWebUrl(String input) {
  final uri = _parseServerUri(input);
  return _formatServerUri(uri);
}

Uri _parseServerUri(String input) {
  var trimmed = input.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('Server URL is required.');
  }

  if (!trimmed.contains('://')) {
    trimmed = 'http://$trimmed';
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) {
    throw FormatException('Invalid server URL: $input');
  }

  if (uri.scheme != 'http' && uri.scheme != 'https') {
    throw FormatException('Server URL must use http or https: $input');
  }

  return uri;
}

String _formatServerUri(Uri uri) {
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  ).toString();
}

String? defaultWebUrlForApi(String apiUrl) {
  final uri = Uri.tryParse(apiUrl);
  if (uri == null || uri.port == 0) {
    return null;
  }

  return uri.replace(port: uri.port + 2).toString();
}
