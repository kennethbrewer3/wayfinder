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

  group('buildMgrsGrid', () {
    test('returns lines for a small viewport', () {
      final geometry = buildMgrsGrid(
        bounds: const MgrsLatLngBounds(
          south: 38.85,
          west: -77.1,
          north: 38.95,
          east: -77.0,
        ),
        zoom: 11,
      );

      expect(geometry.lines, isNotEmpty);
      expect(geometry.accuracy, 2);
      expect(geometry.labels, isNotEmpty);
    });
  });
}
