import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/rectangles/models/rectangle_geometry.dart';
import 'package:wayfinder_flutter/features/rectangles/utils/rectangle_bounds.dart';

void main() {
  group('RectangleBounds', () {
    test('isValid requires span and min size', () {
      expect(
        const RectangleBounds(
          north: 0,
          south: 0,
          east: 1,
          west: 0,
        ).isValid,
        isFalse,
      );
      expect(
        const RectangleBounds(
          north: 35.1,
          south: 35.0,
          east: -106.0,
          west: -106.1,
        ).isValid,
        isTrue,
      );
    });

    test('JSON round-trip', () {
      const bounds = RectangleBounds(
        north: 10,
        south: 8,
        east: 5,
        west: 3,
      );
      final decoded = RectangleBounds.fromJson(bounds.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.north, 10);
      expect(decoded.west, 3);
    });

    test('boundsFromCenterExtent and boundsFromCorners', () {
      final fromCenter = boundsFromCenterExtent(
        const LatLng(0, 0),
        const LatLng(1, 2),
      );
      expect(fromCenter.north, 1);
      expect(fromCenter.south, -1);
      expect(fromCenter.east, 2);
      expect(fromCenter.west, -2);

      final fromCorners = boundsFromCorners(
        const LatLng(1, -2),
        const LatLng(-1, 3),
      );
      expect(fromCorners.north, 1);
      expect(fromCorners.south, -1);
      expect(fromCorners.east, 3);
      expect(fromCorners.west, -2);
    });
  });

  group('RectangleGeometry', () {
    test('centerExtent factory and JSON round-trip', () {
      final geometry = RectangleGeometry.centerExtent(
        center: const LatLng(35.0, -106.0),
        extentPoint: const LatLng(35.05, -105.95),
        notes: 'LZ',
        showNameLabel: true,
      );
      expect(geometry.isValid, isTrue);
      expect(geometry.creationMode, RectangleCreationMode.centerExtent);

      final decoded = RectangleGeometry.fromJsonString(geometry.encode());
      expect(decoded, isNotNull);
      expect(decoded!.notes, 'LZ');
      expect(decoded.showNameLabel, isTrue);
      expect(decoded.center?.latitude, closeTo(35.0, 1e-9));
      expect(decoded.bounds.north, greaterThan(decoded.bounds.south));
    });

    test('corners factory stores corners', () {
      final geometry = RectangleGeometry.corners(
        cornerA: const LatLng(35.0, -106.1),
        cornerB: const LatLng(35.1, -106.0),
      );
      expect(geometry.creationMode, RectangleCreationMode.corners);
      expect(geometry.cornerA, isNotNull);
      expect(geometry.isValid, isTrue);
    });
  });
}
