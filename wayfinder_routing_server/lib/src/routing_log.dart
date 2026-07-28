import 'dart:io';

import 'package:logging/logging.dart';

final Logger routingLog = Logger('wayfinder.routing');

/// Configures root logging for the routing appliance.
///
/// Level from `LOG_LEVEL` (default `INFO`): `ALL`, `FINEST`, `FINER`, `FINE`,
/// `CONFIG`, `INFO`, `WARNING`, `SEVERE`, `SHOUT`, `OFF`.
///
/// All records are written to **stderr** and flushed immediately. Docker does
/// not allocate a TTY by default; Dart fully-buffers stdout in that case, so
/// INFO logs on stdout never appear in `docker compose logs` until exit.
void configureRoutingLogging() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = _levelFromEnv(Platform.environment['LOG_LEVEL']);
  Logger.root.onRecord.listen((record) {
    final time = record.time.toUtc().toIso8601String();
    final name = record.loggerName;
    final level = record.level.name.padRight(7);
    final buffer = StringBuffer('$time [$level] $name: ${record.message}');
    if (record.error != null) {
      buffer.write('\n  error: ${record.error}');
    }
    if (record.stackTrace != null) {
      buffer.write('\n${record.stackTrace}');
    }
    // Always stderr + flush so lines show up live under Docker.
    stderr.writeln(buffer);
  });
}

/// Unconditional console line (bypasses [Logger] level filtering).
void routingConsole(String message) {
  stderr.writeln(
    '${DateTime.now().toUtc().toIso8601String()} [CONSOLE] $message',
  );
}

Level _levelFromEnv(String? raw) {
  switch ((raw ?? 'INFO').trim().toUpperCase()) {
    case 'ALL':
      return Level.ALL;
    case 'FINEST':
      return Level.FINEST;
    case 'FINER':
      return Level.FINER;
    case 'FINE':
    case 'DEBUG':
      return Level.FINE;
    case 'CONFIG':
      return Level.CONFIG;
    case 'INFO':
      return Level.INFO;
    case 'WARNING':
    case 'WARN':
      return Level.WARNING;
    case 'SEVERE':
    case 'ERROR':
      return Level.SEVERE;
    case 'SHOUT':
      return Level.SHOUT;
    case 'OFF':
      return Level.OFF;
    default:
      return Level.INFO;
  }
}

String formatByteSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KiB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GiB';
}

/// Image build identity from Docker `ENV` (see Dockerfile build-args).
String get routingBuildSha {
  final sha = Platform.environment['WAYFINDER_BUILD_SHA']?.trim();
  if (sha == null || sha.isEmpty) {
    return 'unknown';
  }
  return sha;
}

String get routingBuildTime {
  final time = Platform.environment['WAYFINDER_BUILD_TIME']?.trim();
  if (time == null || time.isEmpty) {
    return 'unknown';
  }
  return time;
}
