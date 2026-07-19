import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/slope/utils/slope_compute.dart';

void main() {
  test('flat neighborhood has near-zero slope', () {
    final slope = slopeDegreesFromNeighborhood(
      z1: 100,
      z2: 100,
      z3: 100,
      z4: 100,
      z5: 100,
      z6: 100,
      z7: 100,
      z8: 100,
      z9: 100,
      cellSizeMeters: 30,
    );
    expect(slope, isNotNull);
    expect(slope!, closeTo(0, 1e-9));
  });

  test('eastward rise produces positive slope', () {
    // Horn-weighted east rise: expect tens of degrees, not flat.
    final slope = slopeDegreesFromNeighborhood(
      z1: 0,
      z2: 0,
      z3: 30,
      z4: 0,
      z5: 15,
      z6: 30,
      z7: 0,
      z8: 0,
      z9: 30,
      cellSizeMeters: 30,
    );
    expect(slope, isNotNull);
    expect(slope!, greaterThan(20));
    expect(slope, lessThan(60));
  });

  test('crossCountryCost increases with slope', () {
    expect(crossCountryCostFromSlopeDegrees(2), lessThan(0.2));
    expect(
      crossCountryCostFromSlopeDegrees(12),
      greaterThan(crossCountryCostFromSlopeDegrees(5)),
    );
    expect(crossCountryCostFromSlopeDegrees(40), 1.0);
  });

  test('slopeDegreesGrid matches neighborhood size', () {
    final elevations = List<double?>.filled(9, 100.0);
    elevations[5] = 130; // east of center
    elevations[2] = 130;
    elevations[8] = 130;
    final slopes = slopeDegreesGrid(
      elevations: elevations,
      size: 3,
      cellSizeMeters: 30,
    );
    expect(slopes.length, 9);
    expect(slopes[4], isNotNull);
    expect(slopes[4]!, greaterThan(0));
  });
}
