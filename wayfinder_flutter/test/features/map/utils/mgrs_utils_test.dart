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

      // ~11 km span should land on 1 km grid with a modest line count.
      expect(geometry.accuracy, 2);
      expect(geometry.lines.length, inInclusiveRange(8, 40));
      expect(geometry.lines.every((line) => line.length >= 2), isTrue);
      expect(geometry.labels, isNotEmpty);
    });

    test('uses a coarser multi-zone grid for a regional viewport', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 36.0,
          west: -80.0,
          north: 41.0,
          east: -74.0,
        ),
        zoom: 7,
      );

      expect(geometry.accuracy, lessThanOrEqualTo(1));
      expect(geometry.lines, isNotEmpty);
      // Must not explode into a dense hairline mess.
      expect(geometry.lines.length, lessThanOrEqualTo(80));
    });

    test('draws GZD lines across a world viewport at low zoom', () {
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
      expect(geometry.lines.length, greaterThan(30));
      expect(geometry.labels, isNotEmpty);
    });
  });
}
