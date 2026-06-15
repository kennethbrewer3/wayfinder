import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';

/// Global Serverpod client used across the app.
late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = logUncaughtFlutterError;
  PlatformDispatcher.instance.onError = logUncaughtAsyncError;

  AppLogger.logApp.info('🚀 Wayfinder app starting');

  final serverUrl = await getServerUrl();
  AppLogger.logServer.info(
    '🔌 Server URL resolved',
    data: {'url': serverUrl},
  );

  client = Client(serverUrl)
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
