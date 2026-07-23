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

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                SignInWidget(
                  client: client,
                  disableAnonymousSignInWidget: true,
                  emailSignInWidget: EmailSignInWidget(
                    client: client,
                    startScreen: EmailFlowScreen.login,
                    onAuthenticated: () {
                      onAuthenticated?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.authSuccess),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.authFailed(error.toString())),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    },
                  ),
                  onAuthenticated: onAuthenticated,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.authFailed(error.toString())),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
