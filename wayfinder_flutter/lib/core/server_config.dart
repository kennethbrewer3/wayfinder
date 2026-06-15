import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

class AppServerConfig {
  const AppServerConfig({
    required this.apiUrl,
    required this.webUrl,
  });

  final String apiUrl;
  final String webUrl;
}

Future<AppServerConfig> loadAppServerConfig() async {
  const apiUrlFromEnv = String.fromEnvironment('SERVER_URL');
  const webUrlFromEnv = String.fromEnvironment('WEB_SERVER_URL');

  if (apiUrlFromEnv.isNotEmpty) {
    return AppServerConfig(
      apiUrl: apiUrlFromEnv,
      webUrl: webUrlFromEnv.isNotEmpty
          ? webUrlFromEnv
          : (_defaultWebUrlForApi(apiUrlFromEnv) ??
              'http://$localhost:18082/'),
    );
  }

  try {
    final data = await rootBundle.loadString('assets/config.json');
    final config = jsonDecode(data) as Map<String, dynamic>;
    final apiUrl = config['apiUrl'] as String? ?? 'http://$localhost:18080/';
    final webUrl = config['webUrl'] as String? ??
        _defaultWebUrlForApi(apiUrl) ??
        'http://$localhost:18082/';
    return AppServerConfig(apiUrl: apiUrl, webUrl: webUrl);
  } catch (_) {
    return AppServerConfig(
      apiUrl: 'http://$localhost:18080/',
      webUrl: 'http://$localhost:18082/',
    );
  }
}

/// Backwards-compatible helper used by existing startup code.
Future<String> getServerUrl() async {
  final config = await loadAppServerConfig();
  return config.apiUrl;
}

String? _defaultWebUrlForApi(String apiUrl) {
  final uri = Uri.tryParse(apiUrl);
  if (uri == null || uri.port == 0) {
    return null;
  }

  return uri.replace(port: uri.port + 2).toString();
}
