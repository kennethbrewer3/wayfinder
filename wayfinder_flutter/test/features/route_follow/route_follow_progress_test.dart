import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/route_follow/utils/route_follow_progress.dart';

void main() {
  // ~111 m north per 0.001° latitude near mid-latitudes.
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

  test('detects a right turn and distance to it', () {
    // North ~111 m, then east ~111 m.
    const corner = LatLng(38.001, -78.0);
    const after = LatLng(38.001, -77.999);
    final rightTurnPath = [start, corner, after];

    final progress = computeRouteFollowProgress(
      path: rightTurnPath,
      position: start,
    )!;

    expect(progress.nextManeuver, RouteFollowManeuverKind.turnRight);
    expect(progress.metersToNextManeuver, greaterThan(80));
    expect(progress.metersToNextManeuver, lessThan(130));
  });

  test('detects a left turn', () {
    // North ~111 m, then west ~111 m.
    const corner = LatLng(38.001, -78.0);
    const after = LatLng(38.001, -78.001);
    final leftTurnPath = [start, corner, after];

    final progress = computeRouteFollowProgress(
      path: leftTurnPath,
      position: start,
    )!;

    expect(progress.nextManeuver, RouteFollowManeuverKind.turnLeft);
  });

  test('continues straight on a single leg', () {
    final progress = computeRouteFollowProgress(path: path, position: start)!;
    expect(progress.nextManeuver, RouteFollowManeuverKind.continueStraight);
    expect(
      progress.metersToNextManeuver,
      closeTo(progress.remainingMeters, 1),
    );
  });

  test('signed bearing delta distinguishes left and right', () {
    expect(signedBearingDeltaDegrees(0, 90), closeTo(90, 0.01));
    expect(signedBearingDeltaDegrees(0, 270), closeTo(-90, 0.01));
  });
}
