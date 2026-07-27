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
    this.routingWebUrl,
  });

  final String apiUrl;
  final String webUrl;
  final String? geocodingWebUrl;
  final String? routingWebUrl;
}

const defaultApiUrl = 'http://localhost:18080';
const defaultWebUrl = 'http://localhost:18082';
const defaultGeocodingWebUrl = 'http://localhost:18182';
const defaultRoutingWebUrl = 'http://localhost:18382';

Future<AppServerConfig> loadAppServerConfig() async {
  const apiUrlFromEnv = String.fromEnvironment('SERVER_URL');
  const webUrlFromEnv = String.fromEnvironment('WEB_SERVER_URL');
  const geocodingWebUrlFromEnv = String.fromEnvironment('GEOCODING_SERVER_URL');
  const routingWebUrlFromEnv = String.fromEnvironment('ROUTING_SERVER_URL');

  late final AppServerConfig baseConfig;
  if (apiUrlFromEnv.isNotEmpty) {
    baseConfig = AppServerConfig(
      apiUrl: normalizeApiUrl(apiUrlFromEnv),
      webUrl: webUrlFromEnv.isNotEmpty
          ? normalizeWebUrl(webUrlFromEnv)
          : (defaultWebUrlForApi(apiUrlFromEnv) ?? defaultWebUrl),
      geocodingWebUrl: geocodingWebUrlFromEnv.isNotEmpty
          ? normalizeWebUrl(geocodingWebUrlFromEnv)
          : null,
      routingWebUrl: routingWebUrlFromEnv.isNotEmpty
          ? normalizeWebUrl(routingWebUrlFromEnv)
          : null,
    );
  } else {
    final storage = ServerConfigStorage();
    final savedApiUrl = await storage.loadApiUrl();
    final savedWebUrl = await storage.loadWebUrl();
    if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
      final apiUrl = normalizeApiUrl(savedApiUrl);
      final webUrl = savedWebUrl != null && savedWebUrl.trim().isNotEmpty
          ? normalizeWebUrl(savedWebUrl)
          : (defaultWebUrlForApi(apiUrl) ?? defaultWebUrl);
      baseConfig = AppServerConfig(apiUrl: apiUrl, webUrl: webUrl);
    } else {
      final deployedConfig = await _loadDeployedWebConfig();
      if (deployedConfig != null) {
        baseConfig = deployedConfig;
      } else {
        try {
          final data = await rootBundle.loadString('assets/config.json');
          baseConfig = _configFromJsonMap(
            jsonDecode(data) as Map<String, dynamic>,
          );
        } catch (_) {
          baseConfig = const AppServerConfig(
            apiUrl: defaultApiUrl,
            webUrl: defaultWebUrl,
          );
        }
      }
    }
  }

  // User-saved geocoding/routing URLs must apply even when API URL comes from
  // config.json / dart-define (common on web Docker). Compile-time defines for
  // those optional servers still win over SharedPreferences.
  return _overlaySavedOptionalServerUrls(
    baseConfig,
    geocodingFromEnv: geocodingWebUrlFromEnv,
    routingFromEnv: routingWebUrlFromEnv,
  );
}

Future<AppServerConfig> _overlaySavedOptionalServerUrls(
  AppServerConfig config, {
  required String geocodingFromEnv,
  required String routingFromEnv,
}) async {
  final storage = ServerConfigStorage();
  var geocodingWebUrl = config.geocodingWebUrl;
  var routingWebUrl = config.routingWebUrl;

  if (geocodingFromEnv.isEmpty) {
    final saved = await storage.loadGeocodingWebUrl();
    if (saved != null && saved.trim().isNotEmpty) {
      geocodingWebUrl = normalizeWebUrl(saved);
    }
  }
  if (routingFromEnv.isEmpty) {
    final saved = await storage.loadRoutingWebUrl();
    if (saved != null && saved.trim().isNotEmpty) {
      routingWebUrl = normalizeWebUrl(saved);
    }
  }

  if (geocodingWebUrl == config.geocodingWebUrl &&
      routingWebUrl == config.routingWebUrl) {
    return config;
  }
  return AppServerConfig(
    apiUrl: config.apiUrl,
    webUrl: config.webUrl,
    geocodingWebUrl: geocodingWebUrl,
    routingWebUrl: routingWebUrl,
  );
}

AppServerConfig _configFromJsonMap(Map<String, dynamic> config) {
  final apiUrl = normalizeApiUrl(
    config['apiUrl'] as String? ?? defaultApiUrl,
  );
  final webUrl = normalizeWebUrl(
    config['webUrl'] as String? ?? defaultWebUrlForApi(apiUrl) ?? defaultWebUrl,
  );
  final geocodingRaw = config['geocodingWebUrl'] as String?;
  final geocodingWebUrl = geocodingRaw == null || geocodingRaw.trim().isEmpty
      ? null
      : normalizeWebUrl(geocodingRaw);
  final routingRaw = config['routingWebUrl'] as String?;
  final routingWebUrl = routingRaw == null || routingRaw.trim().isEmpty
      ? null
      : normalizeWebUrl(routingRaw);
  return AppServerConfig(
    apiUrl: apiUrl,
    webUrl: webUrl,
    geocodingWebUrl: geocodingWebUrl,
    routingWebUrl: routingWebUrl,
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

    return _configFromJsonMap(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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

/// Derives the REST/PMTiles web base URL from an API URL.
///
/// - Local Serverpod (`:18080` etc.): web is API port + 2 (`:18082`).
/// - Public HTTPS (`:443` / no port): keep the public port — never invent
///   `:445` from `443 + 2`.
/// - Hostnames like `wayfinder-api.example.com` or `api.example.com` map to
///   `wayfinder-web.example.com` / `web.example.com` (common reverse-proxy
///   split). Otherwise the web host matches the API host.
String? defaultWebUrlForApi(String apiUrl) {
  final uri = Uri.tryParse(apiUrl);
  if (uri == null || uri.host.isEmpty) {
    return null;
  }

  final webHost = _defaultWebHostForApiHost(uri.host);
  final useDevPortOffset = uri.hasPort && uri.port != 80 && uri.port != 443;
  final webPort = useDevPortOffset
      ? uri.port + 2
      : (uri.hasPort ? uri.port : null);

  return Uri(
    scheme: uri.scheme.isEmpty ? 'https' : uri.scheme,
    host: webHost,
    port: webPort,
  ).toString();
}

String _defaultWebHostForApiHost(String apiHost) {
  final host = apiHost.toLowerCase();
  if (host.startsWith('api.') && host.length > 4) {
    return 'web.${host.substring(4)}';
  }
  if (host.contains('-api.')) {
    return host.replaceFirst('-api.', '-web.');
  }
  if (host.endsWith('-api') && host.length > 4) {
    return '${host.substring(0, host.length - 4)}-web';
  }
  return host;
}

/// Whether [apiUrl] points at this device (never usable from a phone/tablet).
bool isLoopbackApiUrl(String apiUrl) {
  final uri = Uri.tryParse(apiUrl.trim());
  if (uri == null || uri.host.isEmpty) {
    return true;
  }
  final host = uri.host.toLowerCase();
  return host == 'localhost' ||
      host == '127.0.0.1' ||
      host == '::1' ||
      host == '0.0.0.0';
}

/// Value for API/web URL text fields on device setup / sign-in.
///
/// Returns null (empty field + hint only) when the resolved URL is loopback,
/// since that cannot work from a physical device. Otherwise returns the saved
/// or configured URL so the user does not have to retype it.
String? apiUrlForDeviceForm(String apiUrl) {
  if (isLoopbackApiUrl(apiUrl)) {
    return null;
  }
  return apiUrl;
}

/// Same as [apiUrlForDeviceForm] for the web/PMTiles base URL.
String? webUrlForDeviceForm(String webUrl) {
  if (isLoopbackApiUrl(webUrl)) {
    return null;
  }
  return webUrl;
}
