import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

const _eventId = '11111111-1111-1111-1111-111111111111';
const _entityId = '22222222-2222-2222-2222-222222222222';
const _routeId = '33333333-3333-3333-3333-333333333333';

void main() {
  test('loopback delivers MarkerUpsert peer-to-peer', () async {
    final aPipe = LoopbackRadioTransport(maxPayload: 512);
    final bPipe = LoopbackRadioTransport(maxPayload: 512);
    LoopbackRadioTransport.connect(aPipe, bPipe);

    final a = RadioSyncSession(transport: aPipe);
    final b = RadioSyncSession(transport: bPipe);

    final event = RadioDomainEvent.markerUpsert(
      eventId: _eventId,
      entityId: _entityId,
      revisedAtSeconds: 42,
      name: 'OP',
      latE7: 10,
      lonE7: -20,
      colorRgb: 0x00ff00,
      iconId: 2,
    );

    final applied = expectLater(
      b.applied,
      emits(
        isA<RadioApplyResult>().having(
          (r) => r.outcome,
          'outcome',
          RadioApplyOutcome.applied,
        ),
      ),
    );
    await a.publish(event);
    await applied;

    final stored = b.applier.entities[_entityId] as MarkerUpsertEvent;
    expect(stored.name, 'OP');
    expect(stored.latE7, 10);

    await a.dispose();
    await b.dispose();
    await aPipe.dispose();
    await bPipe.dispose();
  });

  test('loopback reassembles chunked EvacRouteUpsert', () async {
    // Small MTU forces chunking for a route with geometry-like payload.
    final aPipe = LoopbackRadioTransport(maxPayload: 90);
    final bPipe = LoopbackRadioTransport(maxPayload: 90);
    LoopbackRadioTransport.connect(aPipe, bPipe);

    final a = RadioSyncSession(transport: aPipe);
    final b = RadioSyncSession(transport: bPipe);

    final waypoints = List.generate(
      8,
      (i) => EvacWaypointAir(
        kind: EvacWaypointAirKind.point,
        latE7: 350000000 + i,
        lonE7: -1060000000 - i,
        label: 'P$i',
      ),
    );
    final event = RadioDomainEvent.evacRouteUpsert(
      eventId: _eventId,
      entityId: _entityId,
      revisedAtSeconds: 7,
      routeId: _routeId,
      name: 'Long route',
      role: EvacRouteAirRole.primary,
      waypoints: waypoints,
    );

    final applied = expectLater(
      b.applied,
      emits(
        isA<RadioApplyResult>().having(
          (r) => r.outcome,
          'outcome',
          RadioApplyOutcome.applied,
        ),
      ),
    );
    await a.publish(event);
    await applied;

    final route = b.applier.routesForKit(_entityId)[_routeId];
    expect(route, isNotNull);
    expect(route!.waypoints.length, 8);
    expect(route.name, 'Long route');

    await a.dispose();
    await b.dispose();
    await aPipe.dispose();
    await bPipe.dispose();
  });
}
