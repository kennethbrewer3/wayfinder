import 'package:test/test.dart';

import 'package:wayfinder_server/src/generated/protocol.dart';
import 'package:wayfinder_server/src/settings/app_settings_backup.dart';

void main() {
  group('exportAppSettingsBackup', () {
    test('includes user-facing settings without REST API key', () {
      final payload = exportAppSettingsBackup(
        AppSettings(
          homeLatitude: 38.9,
          homeLongitude: -77.2,
          homeZoom: 12,
          pmtilesStoragePath: '/data/pmtiles',
          measurementUnits: 'imperial',
          angleDisplayFormat: 'dms',
          circleSizeDisplay: 'diameter',
          appTheme: 'dark',
          appLocale: 'en',
          mapMarkerSizeScale: 1.25,
          mapViewportDebugBorder: true,
          mapTileBorderDebug: false,
          mapCompassRoseEnabled: true,
          mapMgrsGridEnabled: false,
          mapMinZoom: 2,
          mapMaxZoom: 18,
          restApiKeyHash: 'secret-hash',
          updatedAt: DateTime.utc(2026, 7, 5),
        ),
      );

      expect(payload, {
        'homeLatitude': 38.9,
        'homeLongitude': -77.2,
        'homeZoom': 12.0,
        'pmtilesStoragePath': '/data/pmtiles',
        'measurementUnits': 'imperial',
        'angleDisplayFormat': 'dms',
        'circleSizeDisplay': 'diameter',
        'appTheme': 'dark',
        'appLocale': 'en',
        'mapMarkerSizeScale': 1.25,
        'mapViewportDebugBorder': true,
        'mapTileBorderDebug': false,
        'mapCompassRoseEnabled': true,
        'mapMgrsGridEnabled': false,
        'mapMinZoom': 2.0,
        'mapMaxZoom': 18.0,
      });
      expect(payload.containsKey('restApiKeyHash'), isFalse);
    });
  });

  group('validateMapMarkerSizeScale', () {
    test('accepts values within range', () {
      expect(() => validateMapMarkerSizeScale(0.75), returnsNormally);
      expect(() => validateMapMarkerSizeScale(1.75), returnsNormally);
    });

    test('rejects out-of-range values', () {
      expect(
        () => validateMapMarkerSizeScale(0.5),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => validateMapMarkerSizeScale(2.0),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
