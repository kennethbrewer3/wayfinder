import 'dart:math' as math;

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
      expect(geometry.labels.length, lessThanOrEqualTo(64));
    });

    test('uses GZD at continental zoom ~5.4 (no bent multi-zone UTM)', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 25.0,
          west: -100.0,
          north: 50.0,
          east: -70.0,
        ),
        zoom: 5.38,
      );

      expect(geometry.accuracy, 0);
      expect(geometry.labels, isNotEmpty);
      // GZD lines are meridians/parallels — each is exactly two endpoints.
      expect(
        geometry.lines.every((line) => line.length == 2),
        isTrue,
      );

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
      expect(vertical, greaterThan(2));
      expect(horizontal, greaterThan(1));
    });

    test('keeps a stable UTM grid around zoom 8.16', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 36.0,
          west: -82.0,
          north: 41.0,
          east: -74.0,
          longitudeCenter: -78.0,
          longitudeWidth: 8.0,
        ),
        zoom: 8.16,
      );

      // Must stay on UTM squares (not flip to GZD while zoomed in).
      expect(geometry.accuracy, lessThanOrEqualTo(1));
      expect(geometry.lines, isNotEmpty);
      expect(geometry.labels, isNotEmpty);

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
      expect(roughlyHorizontal, greaterThan(0));
      expect(roughlyVertical, greaterThan(0));
    });

    test('places MGRS labels at grid-square centers', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 38.8,
          west: -77.2,
          north: 39.0,
          east: -76.9,
        ),
        zoom: 10,
      );

      expect(geometry.labels, isNotEmpty);
      // Labels should stay put when the same cells remain visible.
      final again = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 38.81,
          west: -77.19,
          north: 38.99,
          east: -76.91,
        ),
        zoom: 10,
      );
      final firstTexts = geometry.labels.map((l) => l.text).toSet();
      final shared = again.labels.where((l) => firstTexts.contains(l.text));
      expect(shared, isNotEmpty);
      for (final label in shared) {
        final match = geometry.labels.firstWhere((l) => l.text == label.text);
        expect(label.point.latitude, closeTo(match.point.latitude, 1e-8));
        expect(label.point.longitude, closeTo(match.point.longitude, 1e-8));
      }
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
      expect(geometry.labels, isNotEmpty);

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

    test(
      'keeps a full GZD mesh when flutter_map clamps west/east at zoom ~3.6',
      () {
        // LatLngBounds.worldSafe clamps west/east to ±180 while longitudeWidth
        // still describes the real viewport (often wraps past the antimeridian).
        const center = -95.0;
        const width = 220.0;
        final geometry = buildMgrsGrid(
          bounds: const MgrsLatLngBounds(
            south: -45,
            west: -180, // clamped
            north: 70,
            east: 15, // clamped: center + width/2
            longitudeCenter: center,
            longitudeWidth: width,
          ),
          zoom: 3.64,
        );

        expect(geometry.accuracy, 0);
        final unwrappedWest = center - width / 2; // -205
        final unwrappedEast = center + width / 2; // 15

        var vertical = 0;
        var horizontal = 0;
        var spansFullWidth = false;
        var hasWrappedMeridian = false;
        for (final line in geometry.lines) {
          final dLat = (line.first.latitude - line.last.latitude).abs();
          final dLon = (line.first.longitude - line.last.longitude).abs();
          if (dLon < 1e-6) {
            vertical++;
            if (line.first.longitude < -180) {
              hasWrappedMeridian = true;
            }
          } else if (dLat < 1e-6) {
            horizontal++;
            final lo = math.min(line.first.longitude, line.last.longitude);
            final hi = math.max(line.first.longitude, line.last.longitude);
            if (lo <= unwrappedWest + 1 && hi >= unwrappedEast - 1) {
              spansFullWidth = true;
            }
          }
        }

        expect(vertical, greaterThan(20));
        expect(horizontal, greaterThan(5));
        expect(hasWrappedMeridian, isTrue);
        expect(spansFullWidth, isTrue);
      },
    );
  });
}
