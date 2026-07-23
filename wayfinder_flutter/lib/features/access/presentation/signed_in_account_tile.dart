import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../providers/access_session_provider.dart';

/// Account row with sign-out for any signed-in user (including viewers).
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

    return ListTile(
      contentPadding: contentPadding,
      leading: const Icon(Icons.person_outline),
      title: Text(_accountTitle(session, l10n)),
      subtitle: Text(
        session.roleName ?? session.roleKey ?? l10n.accessUnknownRole,
      ),
      trailing: TextButton(
        onPressed: () => ref.read(accessSessionProvider.notifier).signOut(),
        child: Text(l10n.accessSignOut),
      ),
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
