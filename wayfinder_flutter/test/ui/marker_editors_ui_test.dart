import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_checklists.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_inventory.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_radio.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_checklists_editor.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_inventory_editor.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_radio_editor.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../helpers/ui_test_harness.dart';

void main() {
  setUpAll(installTolerantGoldens);

  testWidgets('MarkerInventoryEditor adds an item', (tester) async {
    var items = <MarkerInventoryItem>[];
    await pumpUi(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: MarkerInventoryEditor(
              items: items,
              initiallyExpanded: true,
              onChanged: (next) => setState(() => items = next),
            ),
          );
        },
      ),
      surfaceSize: const Size(390, 720),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MarkerInventoryEditor)),
    )!;
    expect(find.text(l10n.markerInventoryTitle), findsOneWidget);

    await tester.tap(find.text(l10n.markerInventoryAddItem));
    await tester.pumpAndSettle();
    expect(items, hasLength(1));
    await expectGolden(tester, 'marker_inventory_editor_one_item');
  });

  testWidgets('MarkerChecklistsEditor shows checklist and add control', (
    tester,
  ) async {
    final checklists = [
      MarkerChecklist(
        id: 'c1',
        name: 'Bug-out bag',
        lastAuditedAt: DateTime.utc(2025, 1, 1),
        items: [
          MarkerChecklistItem(id: 'i1', label: 'Water', done: true),
          MarkerChecklistItem(id: 'i2', label: 'Radio'),
        ],
      ),
    ];

    await pumpUi(
      tester,
      SingleChildScrollView(
        child: MarkerChecklistsEditor(
          checklists: checklists,
          initiallyExpanded: true,
          onChanged: (_) {},
        ),
      ),
      surfaceSize: const Size(390, 720),
    );

    expect(find.text('Bug-out bag'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    await expectGolden(tester, 'marker_checklists_editor');
  });

  testWidgets('MarkerRadioEditor expands with contact fields', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: MarkerRadioEditor(
          contact: const MarkerRadioContact(
            callsign: 'W1AW',
            frequencyMHz: 146.52,
            mode: MarkerRadioMode.fm,
            role: MarkerRadioRole.station,
          ),
          initiallyExpanded: true,
          onChanged: (_) {},
        ),
      ),
      surfaceSize: const Size(390, 720),
    );

    expect(find.textContaining('W1AW'), findsWidgets);
    await expectGolden(tester, 'marker_radio_editor');
  });
}
