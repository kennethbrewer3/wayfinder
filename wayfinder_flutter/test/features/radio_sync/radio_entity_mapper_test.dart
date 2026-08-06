import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/circles/models/circle_geometry.dart';
import 'package:wayfinder_flutter/features/evac_kits/models/evac_kit_geometry.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const mapper = RadioEntityMapper();
  const codec = RadioEventCodec();

  test('marker upsert round-trips through codec', () {
    final now = DateTime.utc(2026, 8, 6, 12);
    final marker = MapMarker(
      id: const Uuid().v4obj(),
      name: 'Ridge',
      notes: 'north',
      latitude: 35.1,
      longitude: -106.2,
      elevation: 2100,
      color: '#FF0000',
      icon: 'home',
      visible: true,
      createdAt: now,
      updatedAt: now,
    );
    final event = mapper.markerUpsertFrom(marker) as MarkerUpsertEvent;
    final decoded = codec.decode(codec.encode(event)) as MarkerUpsertEvent;
    final rebuilt = mapper.markerFromUpsert(decoded);
    expect(rebuilt.id, marker.id);
    expect(rebuilt.name, 'Ridge');
    expect(rebuilt.latitude, closeTo(35.1, 1e-6));
    expect(rebuilt.icon, 'home');
    expect(rebuilt.color, '#FF0000');
  });

  test('watch log append maps severity', () {
    final now = DateTime.utc(2026, 8, 6);
    final entry = WatchLogEntry(
      id: const Uuid().v4obj(),
      occurredAt: now,
      author: 'A1',
      severity: 'warning',
      text: 'smoke',
      createdAt: now,
      updatedAt: now,
    );
    final event = mapper.logAppendFrom(entry) as LogAppendEvent;
    expect(event.severity, RadioLogSeverity.warning);
    final rebuilt = mapper.watchLogFromAppend(event);
    expect(rebuilt.severity, 'warning');
    expect(rebuilt.text, 'smoke');
  });

  test('circle zone light geometry encodes', () {
    final now = DateTime.utc(2026, 8, 6);
    final geometry = CircleGeometry(
      center: const LatLng(35.0, -106.0),
      radiusMeters: 250,
    );
    final zone = MapZone(
      id: const Uuid().v4obj(),
      name: 'Ring',
      type: circleZoneType,
      color: '#112233',
      borderColor: '#445566',
      borderPattern: 'solid',
      fillColor: '#778899',
      visible: true,
      geometryJson: geometry.encode(),
      createdAt: now,
      updatedAt: now,
    );
    final event =
        mapper.zoneUpsertLightFromCircle(zone)! as ZoneUpsertLightEvent;
    final rebuilt = mapper.zoneFromUpsertLight(event)!;
    final circle = CircleGeometry.fromZone(rebuilt)!;
    expect(circle.radiusMeters, 250);
    expect(circle.center.latitude, closeTo(35.0, 1e-6));
  });

  test('evac kit meta + route with UUID route id', () {
    final now = DateTime.utc(2026, 8, 6);
    final routeId = const Uuid().v4();
    final geometry = EvacKitGeometry(
      primaryRouteId: routeId,
      routes: [
        EvacRoute(
          id: routeId,
          name: 'Primary',
          role: EvacRouteRole.primary,
          waypoints: const [
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(1, 2)),
            EvacWaypoint(kind: EvacWaypointKind.point, point: LatLng(3, 4)),
          ],
        ),
      ],
    );
    final zone = MapZone(
      id: const Uuid().v4obj(),
      name: 'Kit',
      type: evacKitZoneType,
      color: '#010203',
      borderColor: '#040506',
      borderPattern: 'solid',
      fillColor: '#070809',
      visible: true,
      geometryJson: geometry.encode(),
      createdAt: now,
      updatedAt: now,
    );
    final meta =
        mapper.evacKitMetaFrom(zone, geometry) as EvacKitMetaUpsertEvent;
    expect(meta.primaryRouteId, routeId);
    final routeEvent =
        mapper.evacRouteUpsertFrom(kitZone: zone, route: geometry.routes.first)
            as EvacRouteUpsertEvent?;
    expect(routeEvent, isNotNull);
    expect(routeEvent!.waypoints.length, 2);
  });
}
