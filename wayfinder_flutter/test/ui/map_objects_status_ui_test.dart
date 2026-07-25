import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/presentation/map_objects_status.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../helpers/ui_test_harness.dart';

void main() {
  setUpAll(installTolerantGoldens);

  testWidgets('MapObjectsEmptyState shows title and message', (tester) async {
    await pumpUi(
      tester,
      const MapObjectsEmptyState(
        icon: Icons.place_outlined,
        title: 'No markers',
        message: 'Add a marker from the map.',
      ),
    );

    expect(find.text('No markers'), findsOneWidget);
    expect(find.text('Add a marker from the map.'), findsOneWidget);
    expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    await expectGolden(tester, 'map_objects_empty_state');
  });

  testWidgets('MapObjectsErrorState retry invokes callback', (tester) async {
    var retries = 0;
    await pumpUi(
      tester,
      MapObjectsErrorState(
        title: 'Could not load',
        message: 'Network error',
        onRetry: () => retries++,
      ),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MapObjectsErrorState)),
    )!;
    await tester.tap(find.text(l10n.actionTryAgain));
    await tester.pumpAndSettle();
    expect(retries, 1);
    await expectGolden(tester, 'map_objects_error_state');
  });
}
