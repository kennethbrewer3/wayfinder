import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../access/providers/access_session_provider.dart';

final _accessUsersProvider = FutureProvider.autoDispose<List<AccessUserInfo>>((
  ref,
) {
  return ref.watch(serverClientProvider).accessControl.listUsers();
});

final _accessRolesProvider = FutureProvider.autoDispose<List<AccessRoleInfo>>((
  ref,
) {
  return ref.watch(serverClientProvider).accessControl.listRoles();
});

final _knownPermissionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return ref.watch(serverClientProvider).accessControl.listKnownPermissions();
});

class SettingsUsersTab extends ConsumerWidget {
  const SettingsUsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(accessSessionProvider).valueOrNull;
    final canUsers = ref.watch(canManageUsersProvider);
    final canRoles = ref.watch(canManageRolesProvider);

    if (session != null && session.authRequired && !session.authenticated) {
      return Center(child: Text(l10n.accessSignInRequired));
    }

    if (!canUsers && !canRoles) {
      return Center(child: Text(l10n.accessUsersPermissionDenied));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (session?.authenticated == true) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(session?.email ?? l10n.accessSignedIn),
            subtitle: Text(
              session?.roleName ?? session?.roleKey ?? l10n.accessUnknownRole,
            ),
            trailing: TextButton(
              onPressed: () =>
                  ref.read(accessSessionProvider.notifier).signOut(),
              child: Text(l10n.accessSignOut),
            ),
          ),
          const Divider(),
        ],
        Text(
          l10n.accessUsersTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(l10n.accessUsersHelp),
        const SizedBox(height: 12),
        if (canUsers)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _showCreateUserDialog(context, ref),
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.accessCreateUser),
            ),
          ),
        const SizedBox(height: 12),
        if (canUsers) const _UsersList(),
        const SizedBox(height: 24),
        Text(
          l10n.accessRolesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(l10n.accessRolesHelp),
        const SizedBox(height: 12),
        if (canRoles)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _showRoleEditor(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.accessCreateRole),
            ),
          ),
        const SizedBox(height: 12),
        const _RolesList(),
      ],
    );
  }
}

class _UsersList extends ConsumerWidget {
  const _UsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final usersAsync = ref.watch(_accessUsersProvider);
    final rolesAsync = ref.watch(_accessRolesProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(l10n.accessUsersLoadFailed(error.toString())),
      data: (users) {
        if (users.isEmpty) {
          return Text(l10n.accessUsersEmpty);
        }
        final roles = rolesAsync.valueOrNull ?? const <AccessRoleInfo>[];
        return Column(
          children: [
            for (final user in users)
              Card(
                child: ListTile(
                  title: Text(user.email),
                  subtitle: Text(
                    [
                      user.roleName,
                      if (user.displayName != null &&
                          user.displayName!.isNotEmpty)
                        user.displayName!,
                      if (user.blocked) l10n.accessUserBlocked,
                    ].join(' · '),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final client = ref.read(serverClientProvider);
                      try {
                        switch (value) {
                          case 'role':
                            if (roles.isEmpty) {
                              return;
                            }
                            final roleId = await showDialog<UuidValue>(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: Text(l10n.accessChangeRole),
                                children: [
                                  for (final role in roles)
                                    SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.pop(context, role.id),
                                      child: Text(role.name),
                                    ),
                                ],
                              ),
                            );
                            if (roleId == null) {
                              return;
                            }
                            await client.accessControl.updateUserRole(
                              user.membershipId,
                              roleId,
                            );
                          case 'block':
                            await client.accessControl.setUserBlocked(
                              user.membershipId,
                              !user.blocked,
                            );
                          case 'delete':
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.accessDeleteUserTitle),
                                content: Text(
                                  l10n.accessDeleteUserConfirm(user.email),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(l10n.actionCancel),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(l10n.actionDelete),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) {
                              return;
                            }
                            await client.accessControl.deleteUser(
                              user.membershipId,
                            );
                        }
                        ref.invalidate(_accessUsersProvider);
                        ref.invalidate(_accessRolesProvider);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'role',
                        child: Text(l10n.accessChangeRole),
                      ),
                      PopupMenuItem(
                        value: 'block',
                        child: Text(
                          user.blocked
                              ? l10n.accessUnblockUser
                              : l10n.accessBlockUser,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.accessDeleteUser),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RolesList extends ConsumerWidget {
  const _RolesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canRoles = ref.watch(canManageRolesProvider);
    final rolesAsync = ref.watch(_accessRolesProvider);

    return rolesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(l10n.accessRolesLoadFailed(error.toString())),
      data: (roles) {
        if (roles.isEmpty) {
          return Text(l10n.accessRolesEmpty);
        }
        return Column(
          children: [
            for (final role in roles)
              Card(
                child: ListTile(
                  title: Text(role.name),
                  subtitle: Text(
                    '${role.key} · ${l10n.accessRoleMemberCount(role.memberCount)} · '
                    '${role.permissions.join(', ')}',
                  ),
                  trailing: canRoles
                      ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _showRoleEditor(
                                context,
                                ref,
                                existing: role,
                              );
                            } else if (value == 'delete') {
                              try {
                                await ref
                                    .read(serverClientProvider)
                                    .accessControl
                                    .deleteRole(role.id);
                                ref.invalidate(_accessRolesProvider);
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(l10n.accessEditRole),
                            ),
                            if (!role.isSystem)
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.accessDeleteRole),
                              ),
                          ],
                        )
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<void> _showCreateUserDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final roles = await ref.read(_accessRolesProvider.future);
  if (!context.mounted) {
    return;
  }
  if (roles.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.accessRolesEmpty)));
    return;
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  var roleId = roles.first.id;

  final created = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.accessCreateUser),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: l10n.accessEmailLabel,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.accessPasswordLabel,
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.accessDisplayNameLabel,
                    ),
                  ),
                  DropdownButtonFormField<UuidValue>(
                    initialValue: roleId,
                    decoration: InputDecoration(
                      labelText: l10n.accessRoleLabel,
                    ),
                    items: [
                      for (final role in roles)
                        DropdownMenuItem(
                          value: role.id,
                          child: Text(role.name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => roleId = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.actionCreate),
              ),
            ],
          );
        },
      );
    },
  );

  if (created != true || !context.mounted) {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    return;
  }

  try {
    await ref
        .read(serverClientProvider)
        .accessControl
        .createUser(
          emailController.text.trim(),
          passwordController.text,
          roleId,
          nameController.text.trim().isEmpty
              ? null
              : nameController.text.trim(),
        );
    ref.invalidate(_accessUsersProvider);
    ref.invalidate(_accessRolesProvider);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  } finally {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }
}

Future<void> _showRoleEditor(
  BuildContext context,
  WidgetRef ref, {
  AccessRoleInfo? existing,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final permissions = await ref.read(_knownPermissionsProvider.future);
  if (!context.mounted) {
    return;
  }

  final keyController = TextEditingController(text: existing?.key ?? '');
  final nameController = TextEditingController(text: existing?.name ?? '');
  final descriptionController = TextEditingController(
    text: existing?.description ?? '',
  );
  final selected = {...?existing?.permissions};

  final saved = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? l10n.accessCreateRole : l10n.accessEditRole,
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (existing == null)
                      TextField(
                        controller: keyController,
                        decoration: InputDecoration(
                          labelText: l10n.accessRoleKeyLabel,
                          helperText: l10n.accessRoleKeyHelp,
                        ),
                      ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.accessRoleNameLabel,
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.accessRoleDescriptionLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l10n.accessPermissionsLabel),
                    ),
                    for (final permission in permissions)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value:
                            selected.contains(permission) ||
                            existing?.key == 'admin',
                        onChanged: existing?.key == 'admin'
                            ? null
                            : (value) {
                                setState(() {
                                  if (value == true) {
                                    selected.add(permission);
                                  } else {
                                    selected.remove(permission);
                                  }
                                });
                              },
                        title: Text(permission),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.actionSave),
              ),
            ],
          );
        },
      );
    },
  );

  if (saved != true || !context.mounted) {
    keyController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    return;
  }

  try {
    final client = ref.read(serverClientProvider);
    if (existing == null) {
      await client.accessControl.createRole(
        keyController.text.trim(),
        nameController.text.trim(),
        descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        selected.toList(),
      );
    } else {
      await client.accessControl.updateRole(
        existing.id,
        nameController.text.trim(),
        descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        existing.key == 'admin' ? null : selected.toList(),
      );
    }
    ref.invalidate(_accessRolesProvider);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  } finally {
    keyController.dispose();
    nameController.dispose();
    descriptionController.dispose();
  }
}
