import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';
import 'package:wayfinder_flutter/screens/sign_in_screen.dart';

import '../helpers/access_session_fixtures.dart';
import '../helpers/ui_test_harness.dart';

void main() {
  setUpAll(() {
    installTolerantGoldens();
    ensureTestAppServerConfig();
  });

  testWidgets('AuthGate shows app child when authenticated', (tester) async {
    await pumpUi(
      tester,
      const AuthGate(
        child: Text('MAP_CHILD'),
      ),
      overrides: accessSessionOverrides(AccessSessionFixtures.signedInEditor()),
    );

    expect(find.text('MAP_CHILD'), findsOneWidget);
  });

  testWidgets('AuthGate connection chrome shows retry', (tester) async {
    await pumpUi(
      tester,
      const AuthGate(child: SizedBox.shrink()),
      overrides: connectionGateOverrides(),
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.accessRetry), findsOneWidget);
    await expectGolden(tester, 'auth_gate_connection');
  });

  testWidgets('AuthGate sign-in chrome shows credentials form', (tester) async {
    await pumpUi(
      tester,
      const AuthGate(child: SizedBox.shrink()),
      overrides: signInGateOverrides(),
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.accessSignInSubtitle), findsOneWidget);
    // Soft-keyboard platforms use summary rows; desktop/web use text fields.
    expect(
      find.textContaining('wayfinder-api.example.com'),
      findsWidgets,
    );
    await expectGolden(tester, 'auth_gate_sign_in');
  });
}
