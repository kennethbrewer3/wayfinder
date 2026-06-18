import 'dart:convert';

import 'package:flutter/services.dart';

import 'server_config_storage.dart';

class AppServerConfig {
  const AppServerConfig({
    required this.apiUrl,
    required this.webUrl,
  });

  final String apiUrl;
  final String webUrl;
}

const defaultApiUrl = 'http://localhost:18080';
const defaultWebUrl = 'http://localhost:18082';

Future<AppServerConfig> loadAppServerConfig() async {
  const apiUrlFromEnv = String.fromEnvironment('SERVER_URL');
  const webUrlFromEnv = String.fromEnvironment('WEB_SERVER_URL');

  if (apiUrlFromEnv.isNotEmpty) {
    return AppServerConfig(
      apiUrl: normalizeApiUrl(apiUrlFromEnv),
      webUrl: webUrlFromEnv.isNotEmpty
          ? normalizeWebUrl(webUrlFromEnv)
          : (defaultWebUrlForApi(apiUrlFromEnv) ?? defaultWebUrl),
    );
  }

  final savedApiUrl = await ServerConfigStorage().loadApiUrl();
  if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
    final apiUrl = normalizeApiUrl(savedApiUrl);
    return AppServerConfig(
      apiUrl: apiUrl,
      webUrl: defaultWebUrlForApi(apiUrl) ?? defaultWebUrl,
    );
  }

  try {
    final data = await rootBundle.loadString('assets/config.json');
    final config = jsonDecode(data) as Map<String, dynamic>;
    final apiUrl = normalizeApiUrl(
      config['apiUrl'] as String? ?? defaultApiUrl,
    );
    final webUrl = normalizeWebUrl(
      config['webUrl'] as String? ??
          defaultWebUrlForApi(apiUrl) ??
          defaultWebUrl,
    );
    return AppServerConfig(apiUrl: apiUrl, webUrl: webUrl);
  } catch (_) {
    return const AppServerConfig(
      apiUrl: defaultApiUrl,
      webUrl: defaultWebUrl,
    );
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
