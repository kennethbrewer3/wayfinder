import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import 'logging/app_logger.dart';
import 'server_config.dart';

/// Global Serverpod client and resolved server URLs.
///
/// Not `final` so Settings / connection setup can re-point the client without
/// forcing a full process restart on mobile.
late Client client;
late AppServerConfig appServerConfig;

/// Updates optional server URLs without reconnecting the API client
/// (geocoding / routing use separate HTTP bases).
void updateOptionalAppServerUrls({
  String? geocodingWebUrl,
  String? routingWebUrl,
  bool clearGeocodingWebUrl = false,
  bool clearRoutingWebUrl = false,
}) {
  appServerConfig = AppServerConfig(
    apiUrl: appServerConfig.apiUrl,
    webUrl: appServerConfig.webUrl,
    geocodingWebUrl: clearGeocodingWebUrl
        ? null
        : (geocodingWebUrl ?? appServerConfig.geocodingWebUrl),
    routingWebUrl: clearRoutingWebUrl
        ? null
        : (routingWebUrl ?? appServerConfig.routingWebUrl),
  );
}

/// Rebuilds the global [client] against [config] and re-initializes auth.
Future<void> applyAppServerConfig(AppServerConfig config) async {
  appServerConfig = config;
  client =
      Client(
          config.apiUrl,
          onSucceededCall: (context) {
            AppLogger.logApi.success(
              'RPC ← ${context.endpointName}.${context.methodName}',
            );
          },
          onFailedCall: (context, error, stackTrace) {
            AppLogger.logApi.error(
              'RPC ✕ ${context.endpointName}.${context.methodName}',
              error: error,
              stackTrace: stackTrace,
            );
          },
        )
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = FlutterAuthSessionManager();
  // Must await: Secure Storage restore is async on mobile. Firing themes /
  // other RPCs before this finishes looks "unauthenticated" and the server
  // returns HTTP 500 for AccessDeniedException.
  final authReady = await client.auth.initialize();
  AppLogger.logServer.info(
    '🔌 Server client re-pointed',
    data: {
      'apiUrl': config.apiUrl,
      'webUrl': config.webUrl,
      'authRestored': authReady || client.auth.isAuthenticated,
    },
  );
  AppLogger.logApi.info(
    'RPC client ready (Serverpod calls will log as RPC ← / RPC ✕)',
    data: config.apiUrl,
  );
}
