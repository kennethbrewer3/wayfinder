import 'dart:io';

import 'package:serverpod/serverpod.dart';

import 'generated/endpoints.dart';
import 'generated/protocol.dart';
import 'core/wayfinder_log.dart';
import 'geocoding/geocoding_import_recovery.dart';
import 'geocoding/geocoding_search_indexes.dart';
import 'web/middleware/rest_cors_middleware.dart';
import 'web/rest/geocoding_rest_api_route.dart';

void run(List<String> args) async {
  WfLog.info(null, 'server', '🚀 Wayfinder geocoding server starting | args=$args');

  final pod = Serverpod(args, Protocol(), Endpoints());
  WfLog.info(
    null,
    'server',
    '⚙️ Serverpod initialized | apiPort=${pod.config.apiServer.port} '
    'webPort=${pod.config.webServer?.port} '
    'db=${pod.config.database?.name}@${pod.config.database?.host}:${pod.config.database?.port}',
  );

  final webConfig = pod.config.webServer;
  if (webConfig == null) {
    WfLog.warn(null, 'server', '🌐 Web server disabled — REST API unavailable');
  } else {
    pod.webServer.addMiddleware(const RestCorsMiddleware(), '/api');
    pod.webServer.addRoute(GeocodingRestApiRoute(), '/api');
    WfLog.info(null, 'server', '🌐 Geocoding REST API available at /api/geocoding/*');
  }

  final root = Directory(Uri(path: 'web/static').toFilePath());
  if (root.existsSync()) {
    pod.webServer.addRoute(StaticRoute.directory(root), '/');
  }

  await pod.start();

  final recoverySession = await pod.createSession();
  try {
    await GeocodingImportRecovery.recoverStaleImportsOnStartup(recoverySession);
  } catch (error, stackTrace) {
    WfLog.error(
      recoverySession,
      'geocoding',
      '⚠️ Stale import recovery failed on startup (server will continue)',
      error: error,
      stackTrace: stackTrace,
    );
  } finally {
    await recoverySession.close();
  }

  await _ensureGeocodingSearchIndexes(pod);

  WfLog.success(null, 'server', '🏁 Geocoding server started');
}

Future<void> _ensureGeocodingSearchIndexes(Serverpod pod) async {
  final session = await pod.createSession();
  try {
    await GeocodingSearchIndexes.ensureReady(session);
  } catch (error, stackTrace) {
    WfLog.error(
      null,
      'geocoding',
      '🔎 Failed to build geocoding search indexes',
      error: error,
      stackTrace: stackTrace,
    );
  } finally {
    await session.close();
  }
}
