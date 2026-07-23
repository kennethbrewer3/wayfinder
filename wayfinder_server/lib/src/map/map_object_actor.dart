import 'package:serverpod/serverpod.dart';

import '../access/access_control.dart';
import '../generated/protocol.dart';

/// Resolved actor for map-object mutations and audit rows.
class MapObjectActor {
  const MapObjectActor({
    this.authUserId,
    this.username,
  });

  final UuidValue? authUserId;
  final String? username;

  String get logLabel {
    final name = username?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    if (authUserId != null) {
      return authUserId.toString();
    }
    return 'anonymous';
  }

  /// Resolves the signed-in membership when present.
  ///
  /// [unauthenticatedLabel] is used when there is no session user (open server,
  /// REST API key, etc.).
  static Future<MapObjectActor> resolve(
    Session session, {
    String? unauthenticatedLabel,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      return MapObjectActor(
        username: unauthenticatedLabel ?? 'anonymous',
      );
    }

    final authUserId = AccessControl.authUserIdOf(auth);
    final membership = await UserMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    final username = membership?.email.trim().isNotEmpty == true
        ? membership!.email.trim()
        : membership?.displayName?.trim();
    return MapObjectActor(
      authUserId: authUserId,
      username: (username != null && username.isNotEmpty)
          ? username
          : authUserId.toString(),
    );
  }
}
