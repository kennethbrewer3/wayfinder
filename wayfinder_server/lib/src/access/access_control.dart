import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'wayfinder_permissions.dart';

/// Server-side authentication and permission checks for TOC roles.
abstract final class AccessControl {
  /// Auth is required once at least one membership exists.
  ///
  /// An empty user table always stays open so the first administrator can be
  /// created from Settings (or via bootstrap env). `WAYFINDER_AUTH_REQUIRED`
  /// cannot lock out a server with zero users.
  static Future<bool> isAuthRequired(Session session) async {
    final count = await UserMembership.db.count(session);
    return count > 0;
  }

  /// True when no TOC users exist yet (first-admin bootstrap window).
  static Future<bool> isBootstrapOpen(Session session) async {
    return UserMembership.db.count(session).then((count) => count == 0);
  }

  static Future<AccessSessionInfo> sessionInfo(Session session) async {
    final authRequired = await isAuthRequired(session);
    final auth = session.authenticated;
    if (auth == null) {
      return AccessSessionInfo(
        authRequired: authRequired,
        authenticated: false,
        isAdmin: false,
        permissions: const [],
        canEditMap: !authRequired,
        canManageUsers: !authRequired,
        canManageRoles: !authRequired,
        canManageSettings: !authRequired,
        canManageBackups: !authRequired,
        canManageApiKeys: !authRequired,
        canManageLayers: !authRequired,
        canManageTides: !authRequired,
        canManageGeocoding: !authRequired,
        canManageMarkerIcons: !authRequired,
        canManageThemes: !authRequired,
        canManagePmtiles: !authRequired,
        canManageMapHome: !authRequired,
        canManageMapZoom: !authRequired,
        canViewWatchLog: !authRequired,
        canAddWatchLog: !authRequired,
      );
    }

    final authUserId = authUserIdOf(auth);
    final membership = await UserMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (membership == null) {
      return AccessSessionInfo(
        authRequired: authRequired,
        authenticated: true,
        authUserId: authUserId,
        isAdmin: false,
        permissions: const [],
        canEditMap: false,
        canManageUsers: false,
        canManageRoles: false,
        canManageSettings: false,
        canManageBackups: false,
        canManageApiKeys: false,
        canManageLayers: false,
        canManageTides: false,
        canManageGeocoding: false,
        canManageMarkerIcons: false,
        canManageThemes: false,
        canManagePmtiles: false,
        canManageMapHome: false,
        canManageMapZoom: false,
        canViewWatchLog: false,
        canAddWatchLog: false,
      );
    }

    final role = await AccessRole.db.findById(session, membership.roleId);
    final permissions = role == null
        ? <String>{}
        : parsePermissions(role.permissionsJson);
    final isAdmin = role?.key == BuiltInAccessRole.admin;

    return AccessSessionInfo(
      authRequired: authRequired,
      authenticated: true,
      authUserId: authUserId,
      email: membership.email,
      displayName: membership.displayName,
      roleKey: role?.key,
      roleName: role?.name,
      isAdmin: isAdmin,
      permissions: permissions.toList(growable: false)..sort(),
      canEditMap:
          isAdmin || permissions.contains(WayfinderPermission.editMapObjects),
      canManageUsers:
          isAdmin || permissions.contains(WayfinderPermission.manageUsers),
      canManageRoles:
          isAdmin || permissions.contains(WayfinderPermission.manageRoles),
      canManageSettings:
          isAdmin || permissions.contains(WayfinderPermission.manageSettings),
      canManageBackups:
          isAdmin || permissions.contains(WayfinderPermission.manageBackups),
      canManageApiKeys:
          isAdmin || permissions.contains(WayfinderPermission.manageApiKeys),
      canManageLayers:
          isAdmin || permissions.contains(WayfinderPermission.manageLayers),
      canManageTides:
          isAdmin || permissions.contains(WayfinderPermission.manageTides),
      canManageGeocoding:
          isAdmin || permissions.contains(WayfinderPermission.manageGeocoding),
      canManageMarkerIcons:
          isAdmin ||
          permissions.contains(WayfinderPermission.manageMarkerIcons),
      canManageThemes:
          isAdmin || permissions.contains(WayfinderPermission.manageThemes),
      canManagePmtiles:
          isAdmin || permissions.contains(WayfinderPermission.managePmtiles),
      canManageMapHome:
          isAdmin || permissions.contains(WayfinderPermission.manageMapHome),
      canManageMapZoom:
          isAdmin || permissions.contains(WayfinderPermission.manageMapZoom),
      canViewWatchLog:
          isAdmin || permissions.contains(WayfinderPermission.viewWatchLog),
      canAddWatchLog:
          isAdmin || permissions.contains(WayfinderPermission.addWatchLog),
    );
  }

  /// Ensures the caller may invoke [operation] on endpoint [tag].
  static Future<void> assertAllowed(
    Session session, {
    required String tag,
    required String operation,
    required bool isWrite,
    String? requiredPermission,
  }) async {
    final authRequired = await isAuthRequired(session);
    if (!authRequired) {
      return;
    }

    final auth = session.authenticated;
    if (auth == null) {
      throw AccessDeniedException(
        'Authentication required. Sign in to continue.',
      );
    }

    final permission =
        requiredPermission ??
        WayfinderPermission.forEndpoint(tag: tag, isWrite: isWrite);
    if (permission == null) {
      return;
    }

    final allowed = await hasPermission(session, permission);
    if (!allowed) {
      throw AccessDeniedException(
        'Permission denied for $operation ($permission).',
      );
    }
  }

  static Future<bool> hasPermission(
    Session session,
    String permission,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      return false;
    }

    final authUserId = authUserIdOf(auth);
    final membership = await UserMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (membership == null) {
      return false;
    }

    final role = await AccessRole.db.findById(session, membership.roleId);
    if (role == null) {
      return false;
    }
    if (role.key == BuiltInAccessRole.admin) {
      return true;
    }
    return parsePermissions(role.permissionsJson).contains(permission);
  }

  static Future<void> assertPermission(
    Session session,
    String permission,
  ) async {
    final authRequired = await isAuthRequired(session);
    if (!authRequired) {
      return;
    }
    if (session.authenticated == null) {
      throw AccessDeniedException(
        'Authentication required. Sign in to continue.',
      );
    }
    if (!await hasPermission(session, permission)) {
      throw AccessDeniedException('Permission denied ($permission).');
    }
  }

  static Set<String> parsePermissions(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return {};
      }
      return decoded
          .map((e) => e.toString())
          .where(WayfinderPermission.isKnown)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  static String encodePermissions(Iterable<String> permissions) {
    final cleaned =
        permissions.where(WayfinderPermission.isKnown).toSet().toList()..sort();
    return jsonEncode(cleaned);
  }

  static UuidValue authUserIdOf(AuthenticationInfo auth) {
    return UuidValue.fromString(auth.userIdentifier.toString());
  }
}

/// Thrown when an authenticated (or missing) caller lacks access.
class AccessDeniedException implements Exception {
  AccessDeniedException(this.message);

  final String message;

  @override
  String toString() => message;
}
