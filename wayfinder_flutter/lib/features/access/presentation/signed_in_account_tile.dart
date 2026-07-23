import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../providers/access_session_provider.dart';

/// Account row with change-password and sign-out for any signed-in user.
class SignedInAccountTile extends ConsumerWidget {
  const SignedInAccountTile({super.key, this.contentPadding});

  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(accessSessionProvider).valueOrNull;
    if (session == null || !session.authenticated) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: contentPadding,
          leading: const Icon(Icons.person_outline),
          title: Text(_accountTitle(session, l10n)),
          subtitle: Text(
            session.roleName ?? session.roleKey ?? l10n.accessUnknownRole,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: contentPadding is EdgeInsets
                ? (contentPadding as EdgeInsets).left
                : 16,
            right: contentPadding is EdgeInsets
                ? (contentPadding as EdgeInsets).right
                : 16,
            bottom: 4,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showChangePasswordDialog(context, ref),
                icon: const Icon(Icons.lock_outline, size: 18),
                label: Text(l10n.accessChangePassword),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(accessSessionProvider.notifier).signOut(),
                child: Text(l10n.accessSignOut),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _accountTitle(
    AccessSessionInfo session,
    AppLocalizations l10n,
  ) {
    final email = session.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    final displayName = session.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return l10n.accessSignedIn;
  }
}

Future<void> _showChangePasswordDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  var obscureCurrent = true;
  var obscureNew = true;
  var obscureConfirm = true;
  var submitting = false;
  String? errorText;

  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> submit() async {
              final current = currentController.text;
              final next = newController.text;
              final confirm = confirmController.text;
              if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                setLocalState(() {
                  errorText = l10n.accessChangePasswordFieldsRequired;
                });
                return;
              }
              if (next.trim().length < 8) {
                setLocalState(() {
                  errorText = l10n.accessChangePasswordTooShort;
                });
                return;
              }
              if (next != confirm) {
                setLocalState(() {
                  errorText = l10n.accessChangePasswordMismatch;
                });
                return;
              }
              if (current == next) {
                setLocalState(() {
                  errorText = l10n.accessChangePasswordSameAsCurrent;
                });
                return;
              }

              setLocalState(() {
                submitting = true;
                errorText = null;
              });
              try {
                await ref
                    .read(serverClientProvider)
                    .accessControl
                    .changeOwnPassword(current, next);
                if (!dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.accessChangePasswordSuccess)),
                );
              } catch (error) {
                setLocalState(() {
                  submitting = false;
                  errorText = l10n.accessChangePasswordFailed(error.toString());
                });
              }
            }

            return AlertDialog(
              title: Text(l10n.accessChangePasswordTitle),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentController,
                      obscureText: obscureCurrent,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: l10n.accessCurrentPasswordLabel,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setLocalState(() {
                              obscureCurrent = !obscureCurrent;
                            });
                          },
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newController,
                      obscureText: obscureNew,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.accessNewPasswordLabel,
                        helperText: l10n.accessChangePasswordTooShort,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setLocalState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.accessConfirmPasswordLabel,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setLocalState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: submitting ? null : submit,
                  child: Text(
                    submitting
                        ? l10n.actionSaving
                        : l10n.accessChangePasswordSave,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }
}
