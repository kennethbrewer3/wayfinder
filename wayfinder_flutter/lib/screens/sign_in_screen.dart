import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../core/app_globals.dart';
import '../features/access/providers/access_session_provider.dart';
import 'server_url_setup_card.dart';

enum _AuthGateMode { app, signIn, connection }

/// Gates the app behind login when the server requires authentication.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  /// Nested navigator so connection / sign-in can push routes (URL editor)
  /// without depending on the app [GoRouter] navigator (which is not mounted
  /// while this gate replaces [child]).
  final _authNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(
      accessSessionProvider.select(_modeForSession),
    );

    if (mode == _AuthGateMode.app) {
      return widget.child;
    }

    return Navigator(
      key: _authNavigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const _AuthGateShell(),
        );
      },
    );
  }
}

class _AuthGateShell extends ConsumerStatefulWidget {
  const _AuthGateShell();

  @override
  ConsumerState<_AuthGateShell> createState() => _AuthGateShellState();
}

class _AuthGateShellState extends ConsumerState<_AuthGateShell> {
  /// Keeps [ServerUrlSetupCard] across connection / sign-in chrome changes.
  final _serverUrlCardKey = GlobalKey();
  final _signInKey = GlobalKey<_SignInCredentialsState>();

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(
      accessSessionProvider.select(_modeForSession),
    );
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Fixed Column index so the card is not reparented when
                  // connection ↔ sign-in chrome changes.
                  ServerUrlSetupCard(key: _serverUrlCardKey),
                  const SizedBox(height: 24),
                  if (mode == _AuthGateMode.connection) ...[
                    const _ConnectionStatusPanel(),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(accessSessionProvider.notifier).refresh(),
                      child: Text(l10n.accessRetry),
                    ),
                  ] else ...[
                    Text(
                      l10n.accessSignInSubtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _SignInCredentials(
                      key: _signInKey,
                      onAuthenticated: () {
                        ref.read(accessSessionProvider.notifier).refresh();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_AuthGateMode _modeForSession(AsyncValue<AccessSessionInfo> async) {
  final session = async.valueOrNull;
  if (session != null && (!session.authRequired || session.authenticated)) {
    return _AuthGateMode.app;
  }
  if (session != null && session.authRequired && !session.authenticated) {
    return _AuthGateMode.signIn;
  }
  return _AuthGateMode.connection;
}

class _ConnectionStatusPanel extends ConsumerWidget {
  const _ConnectionStatusPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sessionAsync = ref.watch(accessSessionProvider);
    final error = sessionAsync.error;
    final isLoading = sessionAsync.isLoading && !sessionAsync.hasValue;

    if (error != null) {
      return Column(
        children: [
          Text(
            l10n.accessSessionLoadFailed(error.toString()),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.accessConnectionHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return const SizedBox.shrink();
  }
}

class _SignInCredentials extends StatefulWidget {
  const _SignInCredentials({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  State<_SignInCredentials> createState() => _SignInCredentialsState();
}

class _SignInCredentialsState extends State<_SignInCredentials> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  final _usernameFocus = FocusNode(debugLabel: 'signInUsername');
  final _passwordFocus = FocusNode(debugLabel: 'signInPassword');
  late final Listenable _fieldsListenable;
  var _submitting = false;
  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _fieldsListenable = Listenable.merge([
      _usernameController,
      _passwordController,
    ]);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      _usernameController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          focusNode: _usernameFocus,
          keyboardType: TextInputType.text,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.accessUsernameLabel,
            helperText: l10n.accessUsernameHelp,
          ),
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
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
          onSubmitted: (_) {
            if (_canSubmit) {
              _submit();
            }
          },
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: _fieldsListenable,
          builder: (context, _) {
            return FilledButton(
              onPressed: _canSubmit ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.accessSignInAction),
            );
          },
        ),
      ],
    );
  }
}
