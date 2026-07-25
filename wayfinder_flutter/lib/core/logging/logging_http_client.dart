import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_logger.dart';

/// [http.Client] that logs every request start and response status.
class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient({http.Client? inner, AppLogger? logger})
    : _inner = inner ?? http.Client(),
      _log = logger ?? AppLogger.logApi;

  final http.Client _inner;
  final AppLogger _log;
  var _closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final started = DateTime.now();
    final range = request.headers['range'] ?? request.headers['Range'];
    _log.info(
      'HTTP → ${request.method} ${request.url}',
      data: range == null ? null : 'range=$range',
    );
    try {
      final response = await _inner.send(request);
      final ms = DateTime.now().difference(started).inMilliseconds;
      _log.success(
        'HTTP ← ${response.statusCode} ${request.method} ${request.url}',
        data: '${ms}ms',
      );
      return response;
    } catch (error, stackTrace) {
      final ms = DateTime.now().difference(started).inMilliseconds;
      _log.error(
        'HTTP ✕ ${request.method} ${request.url}',
        data: '${ms}ms',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    _inner.close();
  }
}

/// One-shot GET with request/response logging (for REST repositories).
Future<http.Response> loggedHttpGet(
  Uri url, {
  Map<String, String>? headers,
  Duration? timeout,
  AppLogger? logger,
}) {
  return _logged(
    method: 'GET',
    url: url,
    logger: logger,
    timeout: timeout,
    send: (client) => client.get(url, headers: headers),
  );
}

/// One-shot POST with request/response logging.
Future<http.Response> loggedHttpPost(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  Duration? timeout,
  AppLogger? logger,
}) {
  return _logged(
    method: 'POST',
    url: url,
    logger: logger,
    timeout: timeout,
    send: (client) => client.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    ),
  );
}

/// One-shot PUT with request/response logging.
Future<http.Response> loggedHttpPut(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  Duration? timeout,
  AppLogger? logger,
}) {
  return _logged(
    method: 'PUT',
    url: url,
    logger: logger,
    timeout: timeout,
    send: (client) => client.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    ),
  );
}

/// One-shot DELETE with request/response logging.
Future<http.Response> loggedHttpDelete(
  Uri url, {
  Map<String, String>? headers,
  Duration? timeout,
  AppLogger? logger,
}) {
  return _logged(
    method: 'DELETE',
    url: url,
    logger: logger,
    timeout: timeout,
    send: (client) => client.delete(url, headers: headers),
  );
}

Future<http.Response> _logged({
  required String method,
  required Uri url,
  required Future<http.Response> Function(http.Client client) send,
  Duration? timeout,
  AppLogger? logger,
}) async {
  final log = logger ?? AppLogger.logApi;
  final client = LoggingHttpClient(logger: log);
  try {
    final future = send(client);
    return timeout == null ? await future : await future.timeout(timeout);
  } on TimeoutException catch (error, stackTrace) {
    log.error(
      'HTTP ✕ $method $url',
      data: 'timeout',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  } finally {
    client.close();
  }
}
