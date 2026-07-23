import 'package:serverpod/serverpod.dart';

import '../access/access_control.dart';
import 'read_only_mode.dart';
import 'wayfinder_log.dart';

/// Shared logging helpers for Serverpod endpoints.
mixin EndpointLogging on Endpoint {
  Future<T> loggedCall<T>(
    Session session,
    String tag,
    String operation,
    Future<T> Function() action, {
    String Function(T result)? onSuccess,
    bool? requiresWrite,
    String? requiredPermission,
    bool skipAccessCheck = false,
  }) async {
    final write = requiresWrite ?? ReadOnlyMode.isWriteOperation(operation);
    if (write) {
      ReadOnlyMode.assertWritable(operation: operation);
    }
    if (!skipAccessCheck) {
      await AccessControl.assertAllowed(
        session,
        tag: tag,
        operation: operation,
        isWrite: write,
        requiredPermission: requiredPermission,
      );
    }
    return WfLog.run(
      session,
      tag,
      operation,
      action,
      onSuccess: onSuccess,
    );
  }
}
