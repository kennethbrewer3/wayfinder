import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Structured console + DevTools logging for the Wayfinder Flutter app.
class AppLogger {
  const AppLogger(this.tag);

  final String tag;

  static const _logName = 'wayfinder';

  static const logApp = AppLogger('app');
  static const logServer = AppLogger('server');
  static const logMap = AppLogger('map');
  static const logSettings = AppLogger('settings');
  static const logPmtiles = AppLogger('pmtiles');
  static const logStorage = AppLogger('storage');
  static const logNav = AppLogger('nav');
  static const logMarkers = AppLogger('markers');
  static const logZones = AppLogger('zones');

  void trace(String message, {Object? data}) =>
      _emit('🔎', 'TRACE', message, data: data);

  void debug(String message, {Object? data}) =>
      _emit('🔍', 'DEBUG', message, data: data);

  void info(String message, {Object? data}) =>
      _emit('ℹ️', 'INFO', message, data: data);

  void success(String message, {Object? data}) =>
      _emit('✅', 'OK', message, data: data);

  void warn(String message, {Object? data, Object? error}) =>
      _emit('⚠️', 'WARN', message, data: data, error: error);

  void error(
    String message, {
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer(message);
    if (data != null) buffer.write(' | $data');
    if (error != null) buffer.write('\n💥 $error');
    if (stackTrace != null) buffer.write('\n📚 $stackTrace');

    final line = '❌ [ERROR] [$tag] $buffer';
    developer.log(
      line,
      name: _logName,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint(line);
  }

  void _emit(
    String emoji,
    String level,
    String message, {
    Object? data,
    Object? error,
  }) {
    final buffer = StringBuffer(message);
    if (data != null) buffer.write(' | $data');
    if (error != null) buffer.write(' | error=$error');

    final line = '$emoji [$level] [$tag] $buffer';
    developer.log(line, name: _logName);
    debugPrint(line);
  }
}

void logUncaughtFlutterError(FlutterErrorDetails details) {
  AppLogger('flutter').error(
    'Flutter framework error',
    error: details.exception,
    stackTrace: details.stack,
    data: details.context ?? details.library,
  );
}

bool logUncaughtAsyncError(Object error, StackTrace stackTrace) {
  AppLogger('zone').error(
    'Uncaught async error',
    error: error,
    stackTrace: stackTrace,
  );
  return true;
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
