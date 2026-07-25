import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/kiosk/presentation/kiosk_mode_banner.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../helpers/ui_test_harness.dart';

void main() {
  setUpAll(installTolerantGoldens);

  testWidgets('hidden when kiosk inactive', (tester) async {
    await pumpUi(
      tester,
      const KioskModeBanner(),
      overrides: kioskOverrides(active: false),
    );
    expect(find.byType(KioskModeBanner), findsOneWidget);
    expect(find.byIcon(Icons.desktop_windows_outlined), findsNothing);
  });

  testWidgets('shows exit when locally enabled', (tester) async {
    await pumpUi(
      tester,
      const KioskModeBanner(),
      overrides: kioskOverrides(active: true),
      surfaceSize: const Size(390, 120),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KioskModeBanner)),
    )!;
    expect(find.text(l10n.kioskModeBannerTitle), findsOneWidget);
    expect(find.text(l10n.kioskModeExit), findsOneWidget);
    await expectGolden(tester, 'kiosk_banner_local');
  });

  testWidgets('hides exit when server-enforced', (tester) async {
    await pumpUi(
      tester,
      const KioskModeBanner(),
      overrides: kioskOverrides(active: true, serverEnforced: true),
      surfaceSize: const Size(390, 120),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KioskModeBanner)),
    )!;
    expect(find.text(l10n.kioskModeBannerServerEnforced), findsOneWidget);
    expect(find.text(l10n.kioskModeExit), findsNothing);
    await expectGolden(tester, 'kiosk_banner_server_enforced');
  });
}
