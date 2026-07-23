import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import '../settings/user_client_preferences_store.dart';
import 'access_control.dart';
import 'wayfinder_permissions.dart';

/// Admin operations for users and roles.
abstract final class AccessAdminService {
  static Future<List<AccessUserInfo>> listUsers(Session session) async {
    final memberships = await UserMembership.db.find(
      session,
      orderBy: (t) => t.email,
    );
    final roles = {
      for (final role in await AccessRole.db.find(session)) role.id: role,
    };
    final authUsers = {
      for (final user in await AuthServices.instance.authUsers.list(session))
        user.id: user,
    };

    return [
      for (final membership in memberships)
        AccessUserInfo(
          membershipId: membership.id,
          authUserId: membership.authUserId,
          email: membership.email,
          displayName: membership.displayName,
          roleId: membership.roleId,
          roleKey: roles[membership.roleId]?.key ?? 'unknown',
          roleName: roles[membership.roleId]?.name ?? 'Unknown',
          blocked: authUsers[membership.authUserId]?.blocked ?? false,
          createdAt: membership.createdAt,
          updatedAt: membership.updatedAt,
        ),
    ];
  }

  static Future<AccessUserInfo> createUser(
    Session session, {
    required String email,
    required String password,
    required UuidValue roleId,
    String? displayName,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!_isValidUsername(normalized)) {
      throw ArgumentError(
        'Username must be 2–64 characters with no spaces.',
      );
    }
    if (password.trim().length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }

    final role = await AccessRole.db.findById(session, roleId);
    if (role == null) {
      throw ArgumentError('Role not found.');
    }

    final duplicate = await UserMembership.db.findFirstRow(
      session,
      where: (t) => t.email.equals(normalized),
    );
    if (duplicate != null) {
      throw StateError('A user with that username already exists.');
    }

    final authUser = await AuthServices.instance.authUsers.create(
      session,
      scopes: {Scope(role.key)},
    );

    await AuthServices.instance.emailIdp.admin.createEmailAuthentication(
      session,
      authUserId: authUser.id,
      email: normalized,
      password: password,
    );

    final now = DateTime.now().toUtc();
    final membership = await UserMembership.db.insertRow(
      session,
      UserMembership(
        authUserId: authUser.id,
        roleId: role.id,
        email: normalized,
        displayName: displayName?.trim().isEmpty == true
            ? null
            : displayName?.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return AccessUserInfo(
      membershipId: membership.id,
      authUserId: membership.authUserId,
      email: membership.email,
      displayName: membership.displayName,
      roleId: membership.roleId,
      roleKey: role.key,
      roleName: role.name,
      blocked: false,
      createdAt: membership.createdAt,
      updatedAt: membership.updatedAt,
    );
  }

  /// Lets a signed-in user change their own password after verifying the current one.
  static Future<bool> changeOwnPassword(
    Session session, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw AccessDeniedException(
        'Authentication required. Sign in to continue.',
      );
    }

    final authUserId = AccessControl.authUserIdOf(auth);
    final membership = await UserMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (membership == null) {
      throw AccessDeniedException(
        'Authentication required. Sign in to continue.',
      );
    }

    if (newPassword.trim().length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }
    if (currentPassword == newPassword) {
      throw ArgumentError(
        'New password must be different from the current password.',
      );
    }

    try {
      final verifiedAuthUserId = await AuthServices
          .instance
          .emailIdp
          .utils
          .authentication
          .authenticate(
            session,
            email: membership.email,
            password: currentPassword,
            transaction: null,
          );
      if (verifiedAuthUserId != authUserId) {
        throw ArgumentError('Current password is incorrect.');
      }
    } on EmailAuthenticationInvalidCredentialsException {
      throw ArgumentError('Current password is incorrect.');
    } on EmailAccountNotFoundException {
      throw ArgumentError('Current password is incorrect.');
    } on EmailAuthenticationTooManyAttemptsException {
      throw StateError(
        'Too many failed password attempts. Try again later.',
      );
    }

    await AuthServices.instance.emailIdp.admin.setPassword(
      session,
      email: membership.email,
      password: newPassword,
    );
    return true;
  }

  static Future<AccessUserInfo> updateUserRole(
    Session session, {
    required UuidValue membershipId,
    required UuidValue roleId,
  }) async {
    final membership = await UserMembership.db.findById(session, membershipId);
    if (membership == null) {
      throw StateError('User not found.');
    }
    final role = await AccessRole.db.findById(session, roleId);
    if (role == null) {
      throw ArgumentError('Role not found.');
    }

    await _ensureNotLastAdminDemotion(
      session,
      membership: membership,
      nextRole: role,
    );

    final updated = await UserMembership.db.updateRow(
      session,
      membership.copyWith(
        roleId: role.id,
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    await AuthServices.instance.authUsers.update(
      session,
      authUserId: membership.authUserId,
      scopes: {Scope(role.key)},
    );

    final authUser = await AuthServices.instance.authUsers.get(
      session,
      authUserId: membership.authUserId,
    );

    return AccessUserInfo(
      membershipId: updated.id,
      authUserId: updated.authUserId,
      email: updated.email,
      displayName: updated.displayName,
      roleId: updated.roleId,
      roleKey: role.key,
      roleName: role.name,
      blocked: authUser.blocked,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    );
  }

  static Future<void> setUserBlocked(
    Session session, {
    required UuidValue membershipId,
    required bool blocked,
  }) async {
    final membership = await UserMembership.db.findById(session, membershipId);
    if (membership == null) {
      throw StateError('User not found.');
    }
    if (blocked) {
      await _ensureNotLastAdminRemoval(session, membership);
    }
    await AuthServices.instance.authUsers.update(
      session,
      authUserId: membership.authUserId,
      blocked: blocked,
    );
  }

  static Future<void> deleteUser(
    Session session, {
    required UuidValue membershipId,
  }) async {
    final membership = await UserMembership.db.findById(session, membershipId);
    if (membership == null) {
      throw StateError('User not found.');
    }
    await _ensureNotLastAdminRemoval(session, membership);
    await UserClientPreferencesStore.deleteForAuthUser(
      session,
      membership.authUserId,
    );
    await UserMembership.db.deleteRow(session, membership);
    await AuthServices.instance.authUsers.delete(
      session,
      authUserId: membership.authUserId,
    );
  }

  static Future<List<AccessRoleInfo>> listRoles(Session session) async {
    final roles = await AccessRole.db.find(
      session,
      orderBy: (t) => t.name,
    );
    final memberships = await UserMembership.db.find(session);
    final counts = <UuidValue, int>{};
    for (final membership in memberships) {
      counts[membership.roleId] = (counts[membership.roleId] ?? 0) + 1;
    }

    return [
      for (final role in roles)
        AccessRoleInfo(
          id: role.id,
          key: role.key,
          name: role.name,
          description: role.description,
          isSystem: role.isSystem,
          permissions: AccessControl.parsePermissions(
            role.permissionsJson,
          ).toList(growable: false)..sort(),
          memberCount: counts[role.id] ?? 0,
          createdAt: role.createdAt,
          updatedAt: role.updatedAt,
        ),
    ];
  }

  static Future<AccessRoleInfo> createRole(
    Session session, {
    required String key,
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    final normalizedKey = _normalizeRoleKey(key);
    if (BuiltInAccessRole.all.contains(normalizedKey)) {
      throw ArgumentError('That role key is reserved.');
    }
    final existing = await AccessRole.db.findFirstRow(
      session,
      where: (t) => t.key.equals(normalizedKey),
    );
    if (existing != null) {
      throw StateError('A role with that key already exists.');
    }

    final now = DateTime.now().toUtc();
    final role = await AccessRole.db.insertRow(
      session,
      AccessRole(
        key: normalizedKey,
        name: name.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        isSystem: false,
        permissionsJson: AccessControl.encodePermissions(permissions),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return AccessRoleInfo(
      id: role.id,
      key: role.key,
      name: role.name,
      description: role.description,
      isSystem: role.isSystem,
      permissions: AccessControl.parsePermissions(
        role.permissionsJson,
      ).toList(growable: false)..sort(),
      memberCount: 0,
      createdAt: role.createdAt,
      updatedAt: role.updatedAt,
    );
  }

  static Future<AccessRoleInfo> updateRole(
    Session session, {
    required UuidValue roleId,
    String? name,
    String? description,
    List<String>? permissions,
  }) async {
    final role = await AccessRole.db.findById(session, roleId);
    if (role == null) {
      throw StateError('Role not found.');
    }

    var nextPermissions = role.permissionsJson;
    if (permissions != null) {
      if (role.key == BuiltInAccessRole.admin) {
        nextPermissions = AccessControl.encodePermissions(
          WayfinderPermission.all,
        );
      } else {
        nextPermissions = AccessControl.encodePermissions(permissions);
      }
    }

    final updated = await AccessRole.db.updateRow(
      session,
      role.copyWith(
        name: name?.trim().isNotEmpty == true ? name!.trim() : role.name,
        description: description == null
            ? role.description
            : (description.trim().isEmpty ? null : description.trim()),
        permissionsJson: nextPermissions,
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    final memberCount = await UserMembership.db.count(
      session,
      where: (t) => t.roleId.equals(roleId),
    );

    return AccessRoleInfo(
      id: updated.id,
      key: updated.key,
      name: updated.name,
      description: updated.description,
      isSystem: updated.isSystem,
      permissions: AccessControl.parsePermissions(
        updated.permissionsJson,
      ).toList(growable: false)..sort(),
      memberCount: memberCount,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    );
  }

  static Future<void> deleteRole(
    Session session, {
    required UuidValue roleId,
  }) async {
    final role = await AccessRole.db.findById(session, roleId);
    if (role == null) {
      throw StateError('Role not found.');
    }
    if (role.isSystem) {
      throw StateError('Built-in roles cannot be deleted.');
    }
    final members = await UserMembership.db.count(
      session,
      where: (t) => t.roleId.equals(roleId),
    );
    if (members > 0) {
      throw StateError('Reassign users before deleting this role.');
    }
    await AccessRole.db.deleteRow(session, role);
  }

  static Future<void> _ensureNotLastAdminDemotion(
    Session session, {
    required UserMembership membership,
    required AccessRole nextRole,
  }) async {
    if (nextRole.key == BuiltInAccessRole.admin) {
      return;
    }
    final currentRole = await AccessRole.db.findById(
      session,
      membership.roleId,
    );
    if (currentRole?.key != BuiltInAccessRole.admin) {
      return;
    }
    final adminCount = await _adminMembershipCount(session);
    if (adminCount <= 1) {
      throw StateError('Cannot demote the last administrator.');
    }
  }

  static Future<void> _ensureNotLastAdminRemoval(
    Session session,
    UserMembership membership,
  ) async {
    final currentRole = await AccessRole.db.findById(
      session,
      membership.roleId,
    );
    if (currentRole?.key != BuiltInAccessRole.admin) {
      return;
    }
    final adminCount = await _adminMembershipCount(session);
    if (adminCount <= 1) {
      throw StateError('Cannot remove or block the last administrator.');
    }
  }

  static Future<int> _adminMembershipCount(Session session) async {
    final adminRole = await AccessRole.db.findFirstRow(
      session,
      where: (t) => t.key.equals(BuiltInAccessRole.admin),
    );
    if (adminRole == null) {
      return 0;
    }
    return UserMembership.db.count(
      session,
      where: (t) => t.roleId.equals(adminRole.id),
    );
  }

  static String _normalizeRoleKey(String raw) {
    final key = raw.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]+'),
      '_',
    );
    if (key.isEmpty) {
      throw ArgumentError('Role key is required.');
    }
    return key;
  }

  /// Offline-friendly login id (stored in the email IdP field).
  static bool _isValidUsername(String value) {
    if (value.length < 2 || value.length > 64) {
      return false;
    }
    // Allow plain usernames (admin) or legacy email-shaped ids.
    return !value.contains(RegExp(r'\s'));
  }
}
