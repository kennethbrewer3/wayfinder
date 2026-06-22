import 'dart:async';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/core/wayfinder_log.dart';
import 'src/core/wayfinder_env.dart';
import 'src/settings/app_settings_store.dart';
import 'src/geocoding/geocoding_import_recovery.dart';
import 'src/geocoding/geocoding_search_indexes.dart';
import 'src/pmtiles/pmtiles_catalog_sync.dart';
import 'src/pmtiles/pmtiles_storage.dart';
import 'src/web/middleware/cors_middleware.dart';
import 'src/web/middleware/rest_cors_middleware.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/pmtiles_file_route.dart';
import 'src/web/routes/pmtiles_upload_route.dart';
import 'src/web/routes/root.dart';
import 'src/web/rest/rest_api_route.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  WfLog.info(null, 'server', '🚀 Wayfinder server starting | args=$args');

  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());
  WfLog.info(
    null,
    'server',
    '⚙️ Serverpod initialized | apiPort=${pod.config.apiServer.port} '
    'webPort=${pod.config.webServer?.port} '
    'db=${pod.config.database?.name}@${pod.config.database?.host}:${pod.config.database?.port} '
    'pmtiles=${WayfinderEnv.pmtilesStoragePath}',
  );

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  final webConfig = pod.config.webServer;
  if (webConfig == null) {
    WfLog.warn(null, 'server', '🌐 Web server disabled — PMTiles HTTP routes skipped');
  } else {
    pod.webServer.addRoute(
      AppConfigRoute(apiConfig: pod.config.apiServer, webConfig: webConfig),
      '/app/assets/assets/config.json',
    );

    // Serve uploaded PMTiles archives with HTTP range support for all clients.
    pod.webServer.addMiddleware(const CorsMiddleware(), '/pmtiles');
    pod.webServer.addRoute(
      PmtilesUploadRoute(),
      '/pmtiles/upload',
    );
    pod.webServer.addRoute(
      PmtilesFileRoute(),
      '/pmtiles/files',
    );

    pod.webServer.addMiddleware(const RestCorsMiddleware(), '/api');
    pod.webServer.addRoute(RestApiRoute(), '/api');
    WfLog.info(null, 'server', '🌐 REST API available at /api');
  }

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    WfLog.success(null, 'server', '🌐 Serving Flutter web app from web/app at /app');
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    WfLog.warn(null, 'server', '🌐 Flutter web build not found — serving build instructions at /app');
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  WfLog.info(null, 'server', '🎬 Calling pod.start()');
  await pod.start();

  final syncSession = await pod.createSession();
  try {
    final settings = await AppSettingsStore.getOrCreate(syncSession);
    final pmtilesPath = AppSettingsStore.effectivePmtilesStoragePath(settings);
    PmtilesStorage.configure(pmtilesPath);
    final pmtilesReady = await PmtilesStorage().ensureReady();
    if (pmtilesReady) {
      WfLog.info(
        syncSession,
        'server',
        '🗺️ PMTiles storage configured | path=$pmtilesPath',
      );
      await PmtilesCatalogSync.sync(syncSession);
    } else {
      WfLog.warn(
        syncSession,
        'server',
        '🗺️ PMTiles storage unavailable | path=$pmtilesPath '
        '(mount the drive or update WAYFINDER_PMTILES_HOST_PATH in .env)',
      );
    }
    try {
      await GeocodingImportRecovery.recoverStaleImportsOnStartup(syncSession);
    } catch (error, stackTrace) {
      WfLog.error(
        syncSession,
        'geocoding',
        '⚠️ Stale import recovery failed on startup (server will continue)',
        error: error,
        stackTrace: stackTrace,
      );
    }
    unawaited(_ensureGeocodingSearchIndexes(pod));
  } finally {
    await syncSession.close();
  }

  WfLog.success(null, 'server', '🏁 Server started');
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

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
  WfLog.info(session, 'auth', '📧 Registration code sent to $email');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
  WfLog.info(session, 'auth', '🔑 Password reset code sent to $email');
}
