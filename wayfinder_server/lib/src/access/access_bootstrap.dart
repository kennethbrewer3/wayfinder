import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../core/wayfinder_env.dart';
import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'access_control.dart';
import 'wayfinder_permissions.dart';

/// Seeds built-in roles and optional bootstrap admin from env.
abstract final class AccessBootstrap {
  static Future<void> ensureReady(Session session) async {
    await _seedBuiltInRoles(session);
    await _seedBootstrapAdmin(session);
  }

  static Future<void> _seedBuiltInRoles(Session session) async {
    final now = DateTime.now().toUtc();
    final specs =
        <({String key, String name, String description, Set<String> perms})>[
          (
            key: BuiltInAccessRole.admin,
            name: 'Administrator',
            description: 'Full TOC privileges, including users and roles.',
            perms: WayfinderPermission.all,
          ),
          (
            key: BuiltInAccessRole.editor,
            name: 'Editor',
            description: 'Create and edit map objects, layers, and backups.',
            perms: WayfinderPermission.editorDefaults,
          ),
          (
            key: BuiltInAccessRole.viewer,
            name: 'Viewer',
            description: 'View the map only; cannot change TOC data.',
            perms: WayfinderPermission.viewerDefaults,
          ),
        ];

    for (final spec in specs) {
      final existing = await AccessRole.db.findFirstRow(
        session,
        where: (t) => t.key.equals(spec.key),
      );
      final encoded = AccessControl.encodePermissions(spec.perms);
      if (existing == null) {
        await AccessRole.db.insertRow(
          session,
          AccessRole(
            key: spec.key,
            name: spec.name,
            description: spec.description,
            isSystem: true,
            permissionsJson: encoded,
            createdAt: now,
            updatedAt: now,
          ),
        );
        WfLog.info(
          session,
          'access',
          '🔐 Seeded built-in role | key=${spec.key}',
        );
        continue;
      }

      if (!existing.isSystem) {
        continue;
      }

      // Merge newly added default keys onto built-in roles without removing
      // permissions an admin may have granted (e.g. manage_map_zoom on editor).
      final current = AccessControl.parsePermissions(existing.permissionsJson);
      final merged = {...current, ...spec.perms};
      final mergedEncoded = AccessControl.encodePermissions(merged);
      if (mergedEncoded == existing.permissionsJson &&
          existing.name == spec.name &&
          existing.description == spec.description) {
        continue;
      }
      await AccessRole.db.updateRow(
        session,
        existing.copyWith(
          name: spec.name,
          description: spec.description,
          permissionsJson: mergedEncoded,
          updatedAt: now,
        ),
      );
      WfLog.info(
        session,
        'access',
        '🔐 Synced built-in role permissions | key=${spec.key}',
      );
    }
  }

  static Future<void> _seedBootstrapAdmin(Session session) async {
    final email = WayfinderEnv.bootstrapAdminEmail;
    final password = WayfinderEnv.bootstrapAdminPassword;
    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return;
    }

    final existing = await UserMembership.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email.toLowerCase()),
    );
    if (existing != null) {
      return;
    }

    final adminRole = await AccessRole.db.findFirstRow(
      session,
      where: (t) => t.key.equals(BuiltInAccessRole.admin),
    );
    if (adminRole == null) {
      WfLog.warn(session, 'access', '🔐 Admin role missing; skip bootstrap');
      return;
    }

    final authUser = await AuthServices.instance.authUsers.create(
      session,
      scopes: {Scope(BuiltInAccessRole.admin)},
    );

    await AuthServices.instance.emailIdp.admin.createEmailAuthentication(
      session,
      authUserId: authUser.id,
      email: email,
      password: password,
    );

    final now = DateTime.now().toUtc();
    await UserMembership.db.insertRow(
      session,
      UserMembership(
        authUserId: authUser.id,
        roleId: adminRole.id,
        email: email.toLowerCase(),
        displayName: 'Administrator',
        createdAt: now,
        updatedAt: now,
      ),
    );

    WfLog.success(
      session,
      'access',
      '🔐 Bootstrap admin created | email=$email',
    );
  }
}
