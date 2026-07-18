import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/lines/utils/dead_reckoning_math.dart';

void main() {
  group('distanceMetersFromPaces', () {
    test('multiplies pace count by pace length', () {
      expect(
        distanceMetersFromPaces(paceCount: 100, paceLengthMeters: 0.75),
        75,
      );
      expect(
        distanceMetersFromPaces(paceCount: 60, paceLengthMeters: 1.5),
        90,
      );
    });

    test('returns zero for invalid inputs', () {
      expect(
        distanceMetersFromPaces(paceCount: -1, paceLengthMeters: 0.75),
        0,
      );
      expect(
        distanceMetersFromPaces(paceCount: 10, paceLengthMeters: 0),
        0,
      );
      expect(
        distanceMetersFromPaces(paceCount: double.nan, paceLengthMeters: 1),
        0,
      );
    });
  });
}
