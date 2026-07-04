import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_form_fields.dart';

void main() {
  group('markerIconPickerForceTint', () {
    test('tints monochrome icons on dark themes', () {
      final theme = ThemeData(brightness: Brightness.dark);

      expect(
        markerIconPickerForceTint(theme, coloredAsset: false),
        isTrue,
      );
    });

    test('preserves full-color icons on dark themes', () {
      final theme = ThemeData(brightness: Brightness.dark);

      expect(
        markerIconPickerForceTint(theme, coloredAsset: true),
        isFalse,
      );
    });

    test('does not tint icons on light themes', () {
      final theme = ThemeData(brightness: Brightness.light);

      expect(
        markerIconPickerForceTint(theme, coloredAsset: false),
        isFalse,
      );
    });
  });

  group('markerIconPickerGlyphColor', () {
    test('uses white for monochrome icons on dark themes', () {
      final theme = ThemeData(brightness: Brightness.dark);

      expect(
        markerIconPickerGlyphColor(
          theme,
          selected: false,
          markerColor: Colors.blue,
          coloredAsset: false,
        ),
        Colors.white,
      );
    });

    test('keeps marker color for full-color icons on dark themes', () {
      final theme = ThemeData(brightness: Brightness.dark);

      expect(
        markerIconPickerGlyphColor(
          theme,
          selected: true,
          markerColor: Colors.blue,
          coloredAsset: true,
        ),
        Colors.blue,
      );
    });
  });
}
