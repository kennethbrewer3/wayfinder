import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/access/presentation/signed_in_account_tile.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../helpers/access_session_fixtures.dart';
import '../helpers/ui_test_harness.dart';

void main() {
  setUpAll(installTolerantGoldens);

  testWidgets('renders account email and role', (tester) async {
    await pumpUi(
      tester,
      const SignedInAccountTile(),
      overrides: accessSessionOverrides(
        AccessSessionFixtures.signedInEditor(
          email: 'ranger@example.com',
          roleName: 'Editor',
        ),
      ),
      surfaceSize: const Size(390, 220),
    );

    expect(find.text('ranger@example.com'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.accessSignOut), findsOneWidget);
    await expectGolden(tester, 'signed_in_account_tile');
  });

  testWidgets('hidden when not authenticated', (tester) async {
    await pumpUi(
      tester,
      const SignedInAccountTile(),
      overrides: accessSessionOverrides(AccessSessionFixtures.signInRequired()),
    );
    expect(find.byType(SignedInAccountTile), findsOneWidget);
    expect(find.text('ranger@example.com'), findsNothing);
  });
}
