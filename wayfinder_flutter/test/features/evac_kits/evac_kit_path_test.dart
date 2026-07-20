import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/evac_kits/models/evac_kit_geometry.dart';
import 'package:wayfinder_flutter/features/evac_kits/utils/evac_kit_path.dart';

void main() {
  EvacRoute routeWith(List<LatLng> points) {
    return EvacRoute(
      id: 'r1',
      name: 'Primary',
      role: EvacRouteRole.primary,
      waypoints: [
        for (final point in points)
          EvacWaypoint(kind: EvacWaypointKind.point, point: point),
      ],
    );
  }

  test('moveEvacWaypoint relocates a point', () {
    final route = routeWith(const [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1)]);
    final updated = moveEvacWaypoint(
      route: route,
      waypointIndex: 1,
      point: const LatLng(0.5, 0.5),
    );
    expect(updated, isNotNull);
    expect(updated!.waypoints[1].point.latitude, 0.5);
    expect(updated.waypoints[1].point.longitude, 0.5);
  });

  test('removeEvacWaypoint keeps at least two points', () {
    final short = routeWith(const [LatLng(0, 0), LatLng(0, 1)]);
    expect(
      removeEvacWaypoint(route: short, waypointIndex: 0),
      isNull,
    );

    final longer = routeWith(const [
      LatLng(0, 0),
      LatLng(0, 1),
      LatLng(1, 1),
    ]);
    final updated = removeEvacWaypoint(route: longer, waypointIndex: 1);
    expect(updated, isNotNull);
    expect(updated!.waypoints.length, 2);
  });

  test('appendEvacWaypoint adds after the end', () {
    final route = routeWith(const [LatLng(0, 0), LatLng(0, 1)]);
    final updated = appendEvacWaypoint(
      route: route,
      waypoint: const EvacWaypoint(
        kind: EvacWaypointKind.point,
        point: LatLng(1, 1),
      ),
    );
    expect(updated, isNotNull);
    expect(updated!.waypoints.length, 3);
    expect(updated.waypoints.last.point.latitude, 1);
  });
}
