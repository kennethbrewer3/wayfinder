import 'package:serverpod/serverpod.dart';

/// Structured emoji logging for the Wayfinder Serverpod server.
class WfLog {
  WfLog._();

  static String _timestamp() => DateTime.now().toUtc().toIso8601String();

  static void trace(Session? session, String tag, String message) =>
      _write(session, '🔎', 'TRACE', tag, message);

  static void debug(Session? session, String tag, String message) =>
      _write(session, '🔍', 'DEBUG', tag, message);

  static void info(Session? session, String tag, String message) =>
      _write(session, 'ℹ️', 'INFO', tag, message);

  static void success(Session? session, String tag, String message) =>
      _write(session, '✅', 'OK', tag, message);

  static void warn(Session? session, String tag, String message) =>
      _write(session, '⚠️', 'WARN', tag, message);

  static void error(
    Session? session,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer(message);
    if (error != null) buffer.write(' | error=$error');
    if (stackTrace != null) buffer.write('\n📚 $stackTrace');
    _write(session, '❌', 'ERROR', tag, buffer.toString());
  }

  static Future<T> run<T>(
    Session session,
    String tag,
    String operation,
    Future<T> Function() action, {
    String Function(T result)? onSuccess,
  }) async {
    info(session, tag, '▶️ $operation started');
    try {
      final result = await action();
      final detail = onSuccess?.call(result);
      success(
        session,
        tag,
        detail == null ? '⏹️ $operation completed' : '⏹️ $operation completed | $detail',
      );
      return result;
    } catch (e, stackTrace) {
      WfLog.error(
        session,
        tag,
        '⏹️ $operation failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static void _write(
    Session? session,
    String emoji,
    String level,
    String tag,
    String message,
  ) {
    final line = '$emoji [$level] [$_timestamp()] [$tag] $message';
    // ignore: avoid_print
    print(line);
    session?.log(line);
  }
}
