import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/app/app_locale_choice.dart';
import 'package:wayfinder_flutter/app/app_theme_ids.dart';
import 'package:wayfinder_flutter/features/lines/models/measurement_units.dart';
import 'package:wayfinder_flutter/features/settings/models/client_preferences.dart';

void main() {
  group('ClientPreferences', () {
    test('defaults round-trip through JSON', () {
      final original = ClientPreferences.defaults;
      final decoded = ClientPreferences.fromJson(original.toJson());

      expect(decoded.measurementUnits, original.measurementUnits);
      expect(decoded.angleDisplayFormat, original.angleDisplayFormat);
      expect(decoded.bearingReference, original.bearingReference);
      expect(decoded.circleSizeDisplay, original.circleSizeDisplay);
      expect(decoded.appTheme, AppThemeIds.defaultId);
      expect(decoded.appLocale, AppLocaleChoice.system);
      expect(decoded.mapMarkerSizeScale, original.mapMarkerSizeScale);
      expect(decoded.mapCompassRoseEnabled, isTrue);
      expect(decoded.mapMgrsGridEnabled, isFalse);
      expect(decoded.polygonSnapRightAngles, isTrue);
      expect(decoded.mapMinZoom, original.mapMinZoom);
      expect(decoded.mapMaxZoom, original.mapMaxZoom);
    });

    test('falls back safely for unknown enum/theme values', () {
      final decoded = ClientPreferences.fromJson({
        'measurementUnits': 'cubits',
        'angleDisplayFormat': 'nope',
        'bearingReference': 'magnetic-maybe',
        'circleSizeDisplay': 'diameter-ish',
        'appTheme': 'not-a-real-theme',
        'appLocale': 'xx',
        'mapMarkerSizeScale': 999,
        'mapMinZoom': 20,
        'mapMaxZoom': 2,
      });

      expect(decoded.measurementUnits, MeasurementUnits.metric);
      expect(decoded.appTheme, AppThemeIds.defaultId);
      expect(decoded.mapMarkerSizeScale, 1.75);
      expect(decoded.mapMinZoom, lessThan(decoded.mapMaxZoom));
    });

    test('copyWith updates selected fields', () {
      final next = ClientPreferences.defaults.copyWith(
        measurementUnits: MeasurementUnits.imperial,
        mapMgrsGridEnabled: true,
        appTheme: 'dark',
      );
      expect(next.measurementUnits, MeasurementUnits.imperial);
      expect(next.mapMgrsGridEnabled, isTrue);
      expect(next.appTheme, 'dark');
      expect(next.mapCompassRoseEnabled, isTrue);
    });
  });
}
