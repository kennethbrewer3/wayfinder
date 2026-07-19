import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/elevation/utils/path_profile.dart';

void main() {
  test('samplePointsAlongPath returns endpoints and intermediates', () {
    final points = [
      const LatLng(38.9, -77.1),
      const LatLng(38.91, -77.05),
      const LatLng(38.92, -77.0),
    ];
    final samples = samplePointsAlongPath(points, maxSamples: 10);
    expect(samples.length, greaterThanOrEqualTo(2));
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
    // ~11 m apart — previously threw Invalid argument(s): 25 from clamp.
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
}
