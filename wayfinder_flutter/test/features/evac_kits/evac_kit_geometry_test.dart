import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/evac_kits/models/evac_kit_geometry.dart';
import 'package:wayfinder_flutter/features/evac_kits/utils/evac_kit_eta.dart';
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
    expect(decoded.primaryRoute!.waypoints.length, 2);
    expect(decoded.primaryRoute!.waypoints[1].markerId, 'marker-1');
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
}
