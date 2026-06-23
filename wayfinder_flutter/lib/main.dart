import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'app/app.dart';
import 'core/app_globals.dart';
import 'core/logging/app_logger.dart';
import 'core/server_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = logUncaughtFlutterError;
  PlatformDispatcher.instance.onError = logUncaughtAsyncError;

  AppLogger.logApp.info('🚀 Wayfinder app starting');

  appServerConfig = await loadAppServerConfig();
  AppLogger.logServer.info(
    '🔌 Server URLs resolved',
    data: {
      'apiUrl': appServerConfig.apiUrl,
      'webUrl': appServerConfig.webUrl,
      'geocodingWebUrl': appServerConfig.geocodingWebUrl,
    },
  );

  client = Client(appServerConfig.apiUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();
  AppLogger.logServer.success('🔐 Auth session initialized');

  runApp(
    const WayfinderAppScope(
      child: WayfinderApp(),
    ),
  );

  AppLogger.logApp.success('🎬 runApp completed');
}
