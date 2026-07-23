import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../core/app_globals.dart';
import '../features/access/providers/access_session_provider.dart';

/// Gates the app behind login when the server requires authentication.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(accessSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    return sessionAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.accessSessionLoadFailed(error.toString())),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(accessSessionProvider.notifier).refresh(),
                  child: Text(l10n.accessRetry),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (session) {
        if (!session.authRequired || session.authenticated) {
          return child;
        }
        return SignInScreen(
          onAuthenticated: () {
            ref.read(accessSessionProvider.notifier).refresh();
          },
        );
      },
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _submitting = false;
  var _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final authSuccess = await client.emailIdp.login(
        email: username,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      widget.onAuthenticated?.call();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authFailed(error.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canSubmit =
        !_submitting &&
        _usernameController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.accessSignInSubtitle,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  enabled: !_submitting,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(
                    labelText: l10n.accessUsernameLabel,
                    helperText: l10n.accessUsernameHelp,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  enabled: !_submitting,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: l10n.accessPasswordLabel,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (canSubmit) {
                      _submit();
                    }
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.accessSignInAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
