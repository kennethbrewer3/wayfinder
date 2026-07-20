import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/evac_kits/models/evac_kit_geometry.dart';
import 'package:wayfinder_flutter/features/evac_kits/utils/evac_kit_eta.dart';
import 'package:wayfinder_flutter/features/lines/models/line_geometry.dart';
import 'package:wayfinder_flutter/features/tracks/models/track_transportation_mode.dart';

void main() {
  test('round-trips through JSON', () {
    final routeId = 'route_primary';
    final geometry = EvacKitGeometry(
      primaryRouteId: routeId,
      defaultMode: TrackTransportationMode.onFoot,
      notes: 'bug-out',
      showNameLabel: true,
      routes: [
        EvacRoute(
          id: routeId,
          name: 'Primary',
          role: EvacRouteRole.primary,
          waypoints: const [
            EvacWaypoint(
              kind: EvacWaypointKind.point,
              point: LatLng(38.1, -78.5),
            ),
            EvacWaypoint(
              kind: EvacWaypointKind.control,
              point: LatLng(38.15, -78.45),
            ),
            EvacWaypoint(
              kind: EvacWaypointKind.marker,
              point: LatLng(38.2, -78.4),
              markerId: 'marker-1',
              label: 'Rally',
            ),
          ],
        ),
      ],
    );

    final decoded = EvacKitGeometry.fromJsonString(geometry.encode());
    expect(decoded, isNotNull);
    expect(decoded!.primaryRouteId, routeId);
    expect(decoded.defaultMode, TrackTransportationMode.onFoot);
    expect(decoded.notes, 'bug-out');
    expect(decoded.showNameLabel, isTrue);
    expect(decoded.routes.length, 1);
    expect(decoded.primaryRoute!.waypoints.length, 3);
    expect(decoded.primaryRoute!.waypoints[1].kind, EvacWaypointKind.control);
    expect(decoded.primaryRoute!.waypoints[2].markerId, 'marker-1');
  });

  test('route length is geodesic path length', () {
    final route = EvacRoute(
      id: 'r1',
      name: 'Primary',
      role: EvacRouteRole.primary,
      waypoints: const [
        EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
        EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0.1)),
      ],
    );
    expect(evacRouteLengthMeters(route), greaterThan(10000));
    expect(evacRouteLengthMeters(route), lessThan(12000));
  });

  test('onFoot ETA for 10000 m at 5 km/h is 2h', () {
    final duration = evacRouteDuration(
      lengthMeters: 10000,
      mode: TrackTransportationMode.onFoot,
    );
    expect(duration, const Duration(hours: 2));
    expect(formatEvacDuration(duration), '2h');
  });

  test('pathMode round-trips through JSON', () {
    final geometry = EvacKitGeometry(
      primaryRouteId: 'r1',
      routes: [
        EvacRoute(
          id: 'r1',
          name: 'Primary',
          role: EvacRouteRole.primary,
          pathMode: LinePathMode.smooth,
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0.5)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 1)),
          ],
        ),
      ],
    );

    final decoded = EvacKitGeometry.fromJsonString(geometry.encode());
    expect(decoded, isNotNull);
    expect(decoded!.primaryRoute!.pathMode, LinePathMode.smooth);
  });

  test('primaryOriginWaypoint is the first primary waypoint', () {
    final routeId = 'route_primary';
    final origin = EvacWaypoint(
      kind: EvacWaypointKind.marker,
      point: const LatLng(38.1, -78.5),
      markerId: 'home',
      label: 'Home',
    );
    final geometry = EvacKitGeometry(
      primaryRouteId: routeId,
      routes: [
        EvacRoute(
          id: routeId,
          name: 'Primary',
          role: EvacRouteRole.primary,
          waypoints: [
            origin,
            const EvacWaypoint(
              kind: EvacWaypointKind.point,
              point: LatLng(38.2, -78.4),
            ),
          ],
        ),
      ],
    );

    expect(geometry.primaryOriginWaypoint?.markerId, 'home');
    expect(geometry.primaryOriginWaypoint?.label, 'Home');
  });

  test('withPrimaryRoute promotes an alternate', () {
    final geometry = EvacKitGeometry(
      primaryRouteId: 'primary',
      routes: [
        EvacRoute(
          id: 'primary',
          name: 'Primary',
          role: EvacRouteRole.primary,
          borderPattern: 'solid',
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 1)),
          ],
        ),
        EvacRoute(
          id: 'alt',
          name: 'Alt',
          role: EvacRouteRole.alternate,
          borderPattern: 'dashed',
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(1, 0)),
          ],
        ),
      ],
    );

    final promoted = geometry.withPrimaryRoute('alt');
    expect(promoted.primaryRouteId, 'alt');
    expect(promoted.primaryRoute!.role, EvacRouteRole.primary);
    expect(promoted.primaryRoute!.borderPattern, 'solid');
    final former = promoted.routes.firstWhere((r) => r.id == 'primary');
    expect(former.role, EvacRouteRole.alternate);
    expect(former.borderPattern, 'dashed');
  });

  test('withoutRoute removes an alternate and keeps primary', () {
    final geometry = EvacKitGeometry(
      primaryRouteId: 'primary',
      routes: [
        EvacRoute(
          id: 'primary',
          name: 'Primary',
          role: EvacRouteRole.primary,
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 1)),
          ],
        ),
        EvacRoute(
          id: 'alt',
          name: 'Alt',
          role: EvacRouteRole.alternate,
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(1, 0)),
          ],
        ),
      ],
    );

    final next = geometry.withoutRoute('alt');
    expect(next, isNotNull);
    expect(next!.routes.length, 1);
    expect(next.primaryRouteId, 'primary');
  });

  test('withoutRoute on primary promotes chosen alternate', () {
    final geometry = EvacKitGeometry(
      primaryRouteId: 'primary',
      routes: [
        EvacRoute(
          id: 'primary',
          name: 'Primary',
          role: EvacRouteRole.primary,
          borderPattern: 'solid',
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 1)),
          ],
        ),
        EvacRoute(
          id: 'alt-a',
          name: 'Alt A',
          role: EvacRouteRole.alternate,
          borderPattern: 'dashed',
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(1, 0)),
          ],
        ),
        EvacRoute(
          id: 'alt-b',
          name: 'Alt B',
          role: EvacRouteRole.alternate,
          borderPattern: 'dashed',
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, -1)),
          ],
        ),
      ],
    );

    final next = geometry.withoutRoute(
      'primary',
      newPrimaryRouteId: 'alt-b',
    );
    expect(next, isNotNull);
    expect(next!.routes.length, 2);
    expect(next.primaryRouteId, 'alt-b');
    expect(next.primaryRoute!.name, 'Alt B');
    expect(next.primaryRoute!.role, EvacRouteRole.primary);
    expect(next.primaryRoute!.borderPattern, 'solid');
  });

  test('withoutRoute refuses to remove the last route', () {
    final geometry = EvacKitGeometry(
      primaryRouteId: 'primary',
      routes: [
        EvacRoute(
          id: 'primary',
          name: 'Primary',
          role: EvacRouteRole.primary,
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 0)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(0, 1)),
          ],
        ),
      ],
    );

    expect(geometry.withoutRoute('primary'), isNull);
  });
}
