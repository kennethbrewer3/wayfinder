import 'package:serverpod/serverpod.dart';

import 'wayfinder_log.dart';

/// Shared logging helpers for Serverpod endpoints.
mixin EndpointLogging on Endpoint {
  Future<T> loggedCall<T>(
    Session session,
    String tag,
    String operation,
    Future<T> Function() action, {
    String Function(T result)? onSuccess,
  }) {
    return WfLog.run(
      session,
      tag,
      operation,
      action,
      onSuccess: onSuccess,
    );
  }
}
