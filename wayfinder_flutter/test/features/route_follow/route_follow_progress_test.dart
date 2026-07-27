import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/route_follow/utils/route_follow_progress.dart';

void main() {
  // ~111 m north per 0.001° latitude near the equator-ish mid-latitudes.
  const start = LatLng(38.0, -78.0);
  const mid = LatLng(38.001, -78.0);
  const end = LatLng(38.002, -78.0);
  const path = [start, mid, end];

  test('remaining distance shrinks as position advances along the path', () {
    final atStart = computeRouteFollowProgress(path: path, position: start)!;
    final atMid = computeRouteFollowProgress(path: path, position: mid)!;
    final atEnd = computeRouteFollowProgress(path: path, position: end)!;

    expect(atStart.remainingMeters, greaterThan(atMid.remainingMeters));
    expect(atMid.remainingMeters, greaterThan(atEnd.remainingMeters));
    expect(atEnd.completed, isTrue);
    expect(atStart.isOffRoute, isFalse);
  });

  test('flags off-route when far from the corridor', () {
    final progress = computeRouteFollowProgress(
      path: path,
      position: const LatLng(38.001, -78.01),
    )!;
    expect(
      progress.offRouteMeters,
      greaterThan(routeFollowOffRouteThresholdMeters),
    );
    expect(progress.isOffRoute, isTrue);
  });

  test('returns null for a degenerate path', () {
    expect(
      computeRouteFollowProgress(path: const [start], position: start),
      isNull,
    );
  });
}
