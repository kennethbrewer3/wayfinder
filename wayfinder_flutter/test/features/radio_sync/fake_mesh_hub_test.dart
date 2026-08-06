import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

const _eventId = '11111111-1111-1111-1111-111111111111';
const _entityId = '22222222-2222-2222-2222-222222222222';
const _routeId = '33333333-3333-3333-3333-333333333333';

void main() {
  test('FakeMeshHub delivers MarkerUpsert peer-to-peer', () async {
    final hub = FakeMeshHub(maxPayload: 512);
    final a = RadioSyncSession(transport: hub.join(peerId: 'a'));
    final b = RadioSyncSession(transport: hub.join(peerId: 'b'));

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
    // Sender does not echo to itself.
    expect(a.applier.entities.containsKey(_entityId), isFalse);

    await a.dispose();
    await b.dispose();
    await hub.dispose();
  });

  test('FakeMeshHub chunked EvacRouteUpsert is bidirectional', () async {
    final hub = FakeMeshHub(maxPayload: 90);
    final a = RadioSyncSession(transport: hub.join(peerId: 'a'));
    final b = RadioSyncSession(transport: hub.join(peerId: 'b'));

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

    final bApplied = expectLater(
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
    await bApplied;
    expect(b.applier.routesForKit(_entityId)[_routeId]?.waypoints.length, 8);

    final reply = RadioDomainEvent.logAppend(
      eventId: '44444444-4444-4444-4444-444444444444',
      entityId: '55555555-5555-5555-5555-555555555555',
      revisedAtSeconds: 8,
      occurredAtSeconds: 8,
      severity: RadioLogSeverity.info,
      text: 'route copied',
    );
    final aApplied = expectLater(
      a.applied,
      emits(
        isA<RadioApplyResult>().having(
          (r) => r.outcome,
          'outcome',
          RadioApplyOutcome.applied,
        ),
      ),
    );
    await b.publish(reply);
    await aApplied;
    expect(a.applier.logs.single.text, 'route copied');

    await a.dispose();
    await b.dispose();
    await hub.dispose();
  });
}
