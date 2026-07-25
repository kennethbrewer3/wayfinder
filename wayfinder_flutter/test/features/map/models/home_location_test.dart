import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/map/models/home_location.dart';

void main() {
  group('HomeLocation', () {
    test('JSON round-trip', () {
      const original = HomeLocation(
        latitude: 38.0,
        longitude: -78.5,
        zoom: 12,
      );
      final decoded = HomeLocation.fromJson(original.toJson());
      expect(decoded.latitude, 38.0);
      expect(decoded.longitude, -78.5);
      expect(decoded.zoom, 12);
    });

    test('tryParse accepts valid values', () {
      final parsed = HomeLocation.tryParse(
        latitudeText: '35.1',
        longitudeText: '-106.6',
        zoomText: '10',
      );
      expect(parsed, isNotNull);
      expect(parsed!.latitude, 35.1);
      expect(parsed.longitude, -106.6);
      expect(parsed.zoom, 10);
    });

    test('tryParse returns null for non-numeric input', () {
      expect(
        HomeLocation.tryParse(
          latitudeText: 'x',
          longitudeText: '-106',
          zoomText: '10',
        ),
        isNull,
      );
    });

    test('tryParse rejects out-of-range latitude', () {
      expect(
        () => HomeLocation.tryParse(
          latitudeText: '91',
          longitudeText: '0',
          zoomText: '5',
        ),
        throwsFormatException,
      );
    });

    test('tryParse rejects out-of-range longitude', () {
      expect(
        () => HomeLocation.tryParse(
          latitudeText: '0',
          longitudeText: '181',
          zoomText: '5',
        ),
        throwsFormatException,
      );
    });

    test('toViewport uses center and zoom', () {
      const home = HomeLocation(latitude: 1, longitude: 2, zoom: 8);
      final viewport = home.toViewport();
      expect(viewport.center.latitude, 1);
      expect(viewport.center.longitude, 2);
      expect(viewport.zoom, 8);
    });
  });
}
