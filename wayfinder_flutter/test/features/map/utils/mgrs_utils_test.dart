import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/map/utils/mgrs_utils.dart';

void main() {
  group('parseMgrsLocation', () {
    test('parses compact and spaced MGRS strings', () {
      final compact = parseMgrsLocation('18SUJ23480647');
      final spaced = parseMgrsLocation('18S UJ 23480 647');

      expect(compact, isNotNull);
      expect(spaced, isNotNull);
      expect(compact!.point.latitude, closeTo(spaced!.point.latitude, 1e-8));
      expect(compact.point.longitude, closeTo(spaced.point.longitude, 1e-8));
      expect(compact.formatted, '18S UJ 2348 0647');
      expect(compact.accuracy, 4);
    });

    test('rejects non-MGRS input', () {
      expect(parseMgrsLocation('38.9, -77.2'), isNull);
      expect(parseMgrsLocation('not a grid'), isNull);
      expect(parseMgrsLocation(''), isNull);
    });
  });

  group('latLngToMgrs / round trip', () {
    test('converts known point near Washington DC area', () {
      final point = LatLng(38.8895, -77.0353);
      final mgrs = latLngToMgrs(point, accuracy: 5);
      final parsed = parseMgrsLocation(mgrs);

      expect(parsed, isNotNull);
      expect(parsed!.point.latitude, closeTo(point.latitude, 1e-4));
      expect(parsed.point.longitude, closeTo(point.longitude, 1e-4));
    });
  });

  group('chooseMgrsIntervalMeters', () {
    test('picks coarser intervals for wider spans', () {
      expect(chooseMgrsIntervalMeters(500000), 100000);
      expect(chooseMgrsIntervalMeters(80000), 10000);
      expect(chooseMgrsIntervalMeters(8000), 1000);
      expect(chooseMgrsIntervalMeters(800), 100);
      expect(chooseMgrsIntervalMeters(80), 10);
    });
  });

  group('buildMgrsGrid', () {
    test('keeps a readable line count for a city-scale viewport', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 38.85,
          west: -77.1,
          north: 38.95,
          east: -77.0,
        ),
        zoom: 11,
      );

      expect(geometry.accuracy, 2);
      expect(geometry.lines.length, inInclusiveRange(8, 40));
      expect(geometry.lines.every((line) => line.length >= 2), isTrue);
      expect(geometry.labels, isNotEmpty);
      expect(geometry.labels.length, lessThanOrEqualTo(16));
    });

    test('uses a clipped multi-zone grid around zoom 8', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 30.0,
          west: -100.0,
          north: 45.0,
          east: -70.0,
        ),
        zoom: 8,
      );

      expect(geometry.accuracy, lessThanOrEqualTo(1));
      expect(geometry.lines, isNotEmpty);
      expect(geometry.labels.length, inInclusiveRange(4, 18));

      var roughlyHorizontal = 0;
      var roughlyVertical = 0;
      for (final line in geometry.lines) {
        final dLat = (line.first.latitude - line.last.latitude).abs();
        final dLon = (line.first.longitude - line.last.longitude).abs();
        if (dLat >= dLon) {
          roughlyVertical++;
        } else {
          roughlyHorizontal++;
        }
      }
      // Must not be vertical-only.
      expect(roughlyHorizontal, greaterThan(0));
      expect(roughlyVertical, greaterThan(0));
    });

    test('draws balanced GZD lines for a world viewport', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: -60,
          west: -180,
          north: 70,
          east: 180,
        ),
        zoom: 3,
      );

      expect(geometry.accuracy, 0);
      expect(geometry.labels.length, inInclusiveRange(4, 20));

      var vertical = 0;
      var horizontal = 0;
      for (final line in geometry.lines) {
        final dLat = (line.first.latitude - line.last.latitude).abs();
        final dLon = (line.first.longitude - line.last.longitude).abs();
        if (dLon < 1e-6) {
          vertical++;
        } else if (dLat < 1e-6) {
          horizontal++;
        }
      }
      expect(vertical, greaterThan(10));
      expect(horizontal, greaterThan(8));
    });
  });
}
