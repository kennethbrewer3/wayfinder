import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/polygons/utils/polygon_angle_snap.dart';

void main() {
  test('perpendicular through pivot projects to a square corner line', () {
    // Incoming edge from (0,0) → (10,0); square corner line is vertical at x=10.
    final projected = projectOntoPerpendicularThroughPivot(
      pivot: const Offset(10, 0),
      from: Offset.zero,
      proposed: const Offset(12, 8),
    );
    expect(projected.dx, closeTo(10, 1e-9));
    expect(projected.dy, closeTo(8, 1e-9));
  });

  test('90° inscribed locus projects onto Thales circle', () {
    final a = Offset.zero;
    final b = const Offset(100, 0);
    final proposed = const Offset(50, 40);
    final candidates = inscribedAngleSnapCandidates(
      a: a,
      b: b,
      proposed: proposed,
      angleDegrees: 90,
    );
    expect(candidates, isNotEmpty);
    // Diameter AB ⇒ circle center (50,0), radius 50. Point at 90° above mid is (50,50).
    final best = candidates.reduce(
      (left, right) => (left - proposed).distance <= (right - proposed).distance
          ? left
          : right,
    );
    expect(best.dx, closeTo(50, 1e-6));
    expect(best.dy, closeTo(50, 1e-6));
  });
}
