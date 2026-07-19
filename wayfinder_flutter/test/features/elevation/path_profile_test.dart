import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/elevation/utils/path_profile.dart';

void main() {
  test('samplePointsAlongPath keeps vertices and adds intermediates', () {
    final points = [
      const LatLng(38.9, -77.1),
      const LatLng(38.91, -77.05),
      const LatLng(38.92, -77.0),
    ];
    final samples = samplePointsAlongPath(points, maxSamples: 80);
    expect(samples.length, greaterThanOrEqualTo(points.length));
    expect(samples.first.latitude, closeTo(38.9, 1e-9));
    expect(samples.last.latitude, closeTo(38.92, 1e-9));
  });

  test('buildPathProfileStats computes gain and loss', () {
    final points = [
      const LatLng(0, 0),
      const LatLng(0.01, 0),
      const LatLng(0.02, 0),
      const LatLng(0.03, 0),
    ];
    final stats = buildPathProfileStats(
      samplePoints: points,
      elevations: [100, 120, 110, 130],
    );
    expect(stats.gainMeters, closeTo(40, 1e-6)); // +20 +20
    expect(stats.lossMeters, closeTo(10, 1e-6)); // -10
    expect(stats.minElevationMeters, 100);
    expect(stats.maxElevationMeters, 130);
  });

  test('samplePointsAlongPath handles paths shorter than min spacing', () {
    // ~11 m apart — every vertex is kept.
    final points = [
      const LatLng(38.91025, -77.26323),
      const LatLng(38.91035, -77.26323),
    ];
    final samples = samplePointsAlongPath(points);
    expect(samples.length, greaterThanOrEqualTo(2));
    expect(samples.first, points.first);
    expect(samples.last, points.last);
  });

  test('buildPathProfileStats allows flat elevation', () {
    final points = [
      const LatLng(0, 0),
      const LatLng(0.001, 0),
      const LatLng(0.002, 0),
    ];
    final stats = buildPathProfileStats(
      samplePoints: points,
      elevations: [120, 120, 120],
    );
    expect(stats.isEmpty, isFalse);
    expect(stats.gainMeters, 0);
    expect(stats.lossMeters, 0);
    expect(stats.minElevationMeters, 120);
    expect(stats.maxElevationMeters, 120);
  });

  test('combinePathLegs keeps short legs and may reverse to connect', () {
    const a = PathProfileLeg(
      id: 'a',
      name: 'A',
      points: [
        LatLng(38.9100, -77.2630),
        LatLng(38.9101, -77.2630), // ~11 m
      ],
    );
    // Starts near A's end if reversed.
    const b = PathProfileLeg(
      id: 'b',
      name: 'B',
      points: [
        LatLng(38.9105, -77.2630),
        LatLng(38.9101, -77.2630),
      ],
    );
    final combined = combinePathLegs([a, b]);
    expect(combined.length, greaterThanOrEqualTo(3));
    expect(combined.first, a.points.first);
    // Short leg vertices are present.
    expect(
      combined.any(
        (p) =>
            (p.latitude - 38.9101).abs() < 1e-9 &&
            (p.longitude - -77.2630).abs() < 1e-9,
      ),
      isTrue,
    );
  });

  test('samplePointsAlongPath includes short-leg vertices in a long route', () {
    final points = <LatLng>[
      const LatLng(38.90, -77.26),
      const LatLng(38.905, -77.26), // long-ish
      const LatLng(38.9051, -77.26), // ~11 m short leg
      const LatLng(38.91, -77.26),
    ];
    final samples = samplePointsAlongPath(points, minSpacingMeters: 25);
    expect(
      samples.any(
        (p) =>
            (p.latitude - 38.9051).abs() < 1e-9 &&
            (p.longitude - -77.26).abs() < 1e-9,
      ),
      isTrue,
      reason: 'short-leg vertex must remain in the sample set',
    );
  });
}
