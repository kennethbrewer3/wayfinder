import 'wayfinder_env.dart';

/// Server-wide write lock for spare viewer / air-gap appliances.
///
/// Enabled with `WAYFINDER_READ_ONLY=1` (or `true`). Reads and exports stay
/// available; create/update/delete and other mutations are rejected.
abstract final class ReadOnlyMode {
  static bool get enabled => WayfinderEnv.readOnly;

  /// Throws [StateError] when the server is in read-only mode.
  static void assertWritable({String? operation}) {
    if (!enabled) {
      return;
    }
    final suffix = operation == null || operation.isEmpty
        ? ''
        : ' ($operation)';
    throw StateError(
      'Server is in read-only / kiosk mode$suffix. '
      'Unset WAYFINDER_READ_ONLY to allow writes.',
    );
  }

  /// Whether [operation] should be treated as a write for read-only gating.
  ///
  /// Used by [EndpointLogging.loggedCall] so mutate methods are covered without
  /// annotating every call site. Prefer explicit `requiresWrite:` when a name
  /// is ambiguous.
  static bool isWriteOperation(String operation) {
    final op = operation.trim().toLowerCase();
    if (op.isEmpty) {
      return true;
    }

    const readPrefixes = <String>[
      'get',
      'list',
      'query',
      'export',
      'find',
      'load',
      'check',
      'ping',
      'hello',
      'active', // e.g. activeFileId
    ];
    for (final prefix in readPrefixes) {
      if (op.startsWith(prefix)) {
        return false;
      }
    }
    return true;
  }
}
