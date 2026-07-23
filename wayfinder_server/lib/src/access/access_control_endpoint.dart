import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'access_admin_service.dart';
import 'access_control.dart';
import 'wayfinder_permissions.dart';

class AccessControlEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'accessControl';

  /// Public: whether login is required and the caller's effective permissions.
  Future<AccessSessionInfo> getSessionInfo(Session session) {
    return loggedCall(
      session,
      _tag,
      'getSessionInfo',
      () => AccessControl.sessionInfo(session),
      requiresWrite: false,
      skipAccessCheck: true,
    );
  }

  Future<List<String>> listKnownPermissions(Session session) {
    return loggedCall(
      session,
      _tag,
      'listKnownPermissions',
      () async {
        await AccessControl.assertPermission(
          session,
          WayfinderPermission.manageRoles,
        );
        return WayfinderPermission.all.toList(growable: false)..sort();
      },
      requiresWrite: false,
      requiredPermission: WayfinderPermission.manageRoles,
    );
  }

  Future<List<AccessUserInfo>> listUsers(Session session) {
    return loggedCall(
      session,
      _tag,
      'listUsers',
      () async {
        if (await AccessControl.isBootstrapOpen(session)) {
          return AccessAdminService.listUsers(session);
        }
        await AccessControl.assertPermission(
          session,
          WayfinderPermission.manageUsers,
        );
        return AccessAdminService.listUsers(session);
      },
      requiresWrite: false,
      skipAccessCheck: true,
    );
  }

  Future<AccessUserInfo> createUser(
    Session session,
    String email,
    String password,
    UuidValue roleId,
    String? displayName,
  ) {
    return loggedCall(
      session,
      _tag,
      'createUser',
      () async {
        if (!await AccessControl.isBootstrapOpen(session)) {
          await AccessControl.assertPermission(
            session,
            WayfinderPermission.manageUsers,
          );
        }
        return AccessAdminService.createUser(
          session,
          email: email,
          password: password,
          roleId: roleId,
          displayName: displayName,
        );
      },
      skipAccessCheck: true,
    );
  }

  /// Any signed-in user may change their own password (current password required).
  Future<bool> changeOwnPassword(
    Session session,
    String currentPassword,
    String newPassword,
  ) {
    return loggedCall(
      session,
      _tag,
      'changeOwnPassword',
      () => AccessAdminService.changeOwnPassword(
        session,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
      skipAccessCheck: true,
    );
  }

  Future<AccessUserInfo> updateUserRole(
    Session session,
    UuidValue membershipId,
    UuidValue roleId,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateUserRole',
      () => AccessAdminService.updateUserRole(
        session,
        membershipId: membershipId,
        roleId: roleId,
      ),
      requiredPermission: WayfinderPermission.manageUsers,
    );
  }

  Future<bool> setUserBlocked(
    Session session,
    UuidValue membershipId,
    bool blocked,
  ) {
    return loggedCall(
      session,
      _tag,
      'setUserBlocked',
      () async {
        await AccessAdminService.setUserBlocked(
          session,
          membershipId: membershipId,
          blocked: blocked,
        );
        return true;
      },
      requiredPermission: WayfinderPermission.manageUsers,
    );
  }

  Future<bool> deleteUser(Session session, UuidValue membershipId) {
    return loggedCall(
      session,
      _tag,
      'deleteUser',
      () async {
        await AccessAdminService.deleteUser(
          session,
          membershipId: membershipId,
        );
        return true;
      },
      requiredPermission: WayfinderPermission.manageUsers,
    );
  }

  /// Admin forgotten-password recovery: set a new password for a TOC user.
  Future<bool> resetUserPassword(
    Session session,
    UuidValue membershipId,
    String newPassword,
  ) {
    return loggedCall(
      session,
      _tag,
      'resetUserPassword',
      () => AccessAdminService.resetUserPassword(
        session,
        membershipId: membershipId,
        newPassword: newPassword,
      ),
      requiredPermission: WayfinderPermission.manageUsers,
    );
  }

  Future<List<AccessRoleInfo>> listRoles(Session session) {
    return loggedCall(
      session,
      _tag,
      'listRoles',
      () async {
        if (await AccessControl.isBootstrapOpen(session)) {
          return AccessAdminService.listRoles(session);
        }
        final canManageUsers = await AccessControl.hasPermission(
          session,
          WayfinderPermission.manageUsers,
        );
        final canManageRoles = await AccessControl.hasPermission(
          session,
          WayfinderPermission.manageRoles,
        );
        if (!canManageUsers && !canManageRoles) {
          await AccessControl.assertPermission(
            session,
            WayfinderPermission.manageUsers,
          );
        }
        return AccessAdminService.listRoles(session);
      },
      requiresWrite: false,
      skipAccessCheck: true,
    );
  }

  Future<AccessRoleInfo> createRole(
    Session session,
    String key,
    String name,
    String? description,
    List<String> permissions,
  ) {
    return loggedCall(
      session,
      _tag,
      'createRole',
      () => AccessAdminService.createRole(
        session,
        key: key,
        name: name,
        description: description,
        permissions: permissions,
      ),
      requiredPermission: WayfinderPermission.manageRoles,
    );
  }

  Future<AccessRoleInfo> updateRole(
    Session session,
    UuidValue roleId,
    String? name,
    String? description,
    List<String>? permissions,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateRole',
      () => AccessAdminService.updateRole(
        session,
        roleId: roleId,
        name: name,
        description: description,
        permissions: permissions,
      ),
      requiredPermission: WayfinderPermission.manageRoles,
    );
  }

  Future<bool> deleteRole(Session session, UuidValue roleId) {
    return loggedCall(
      session,
      _tag,
      'deleteRole',
      () async {
        await AccessAdminService.deleteRole(session, roleId: roleId);
        return true;
      },
      requiredPermission: WayfinderPermission.manageRoles,
    );
  }
}
