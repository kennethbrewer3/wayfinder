import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_form_fields.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../helpers/ui_test_harness.dart';

void main() {
  setUpAll(installTolerantGoldens);

  testWidgets('MarkerColorPickerField shows color label', (tester) async {
    Color? selected;
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: MarkerColorPickerField(
          color: const Color(0xFF1B4965),
          onChanged: (value) => selected = value,
        ),
      ),
      surfaceSize: const Size(390, 640),
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.formColorLabel), findsOneWidget);
    expect(selected, isNull);
    await expectGolden(tester, 'marker_color_picker_field');
  });
}
