import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

const _e1 = '11111111-1111-1111-1111-111111111111';
const _e2 = '22222222-2222-2222-2222-222222222222';
const _marker = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _route = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

void main() {
  group('RadioEventApplier', () {
    test('dedupes by eventId', () {
      final applier = RadioEventApplier();
      final event = RadioDomainEvent.markerUpsert(
        eventId: _e1,
        entityId: _marker,
        revisedAtSeconds: 10,
        name: 'A',
        latE7: 1,
        lonE7: 2,
        colorRgb: 0,
        iconId: 1,
      );
      expect(applier.apply(event).outcome, RadioApplyOutcome.applied);
      expect(applier.apply(event).outcome, RadioApplyOutcome.duplicateEvent);
    });

    test('LWW ignores stale upsert', () {
      final applier = RadioEventApplier();
      final newer = RadioDomainEvent.markerUpsert(
        eventId: _e1,
        entityId: _marker,
        revisedAtSeconds: 20,
        name: 'New',
        latE7: 1,
        lonE7: 2,
        colorRgb: 0,
        iconId: 1,
      );
      final older = RadioDomainEvent.markerUpsert(
        eventId: _e2,
        entityId: _marker,
        revisedAtSeconds: 10,
        name: 'Old',
        latE7: 9,
        lonE7: 9,
        colorRgb: 0,
        iconId: 1,
      );
      expect(applier.apply(newer).outcome, RadioApplyOutcome.applied);
      expect(applier.apply(older).outcome, RadioApplyOutcome.ignoredStale);
      final stored = applier.entities[_marker] as MarkerUpsertEvent;
      expect(stored.name, 'New');
    });

    test('logs are append-only', () {
      final applier = RadioEventApplier();
      final a = RadioDomainEvent.logAppend(
        eventId: _e1,
        entityId: _marker,
        revisedAtSeconds: 1,
        occurredAtSeconds: 1,
        severity: 0,
        text: 'one',
      );
      final b = RadioDomainEvent.logAppend(
        eventId: _e2,
        entityId: _marker,
        revisedAtSeconds: 2,
        occurredAtSeconds: 2,
        severity: 0,
        text: 'two',
      );
      applier.apply(a);
      applier.apply(b);
      expect(applier.logs.map((e) => e.text), ['one', 'two']);
    });

    test('evac route merge by routeId', () {
      final applier = RadioEventApplier();
      final kitId = _marker;
      applier.apply(
        RadioDomainEvent.evacKitMetaUpsert(
          eventId: _e1,
          entityId: kitId,
          revisedAtSeconds: 1,
          name: 'Kit',
          colorRgb: 1,
          borderColorRgb: 2,
          fillColorRgb: 3,
          primaryRouteId: _route,
          defaultMode: 0,
        ),
      );
      final route = RadioDomainEvent.evacRouteUpsert(
        eventId: _e2,
        entityId: kitId,
        revisedAtSeconds: 2,
        routeId: _route,
        name: 'Main',
        role: EvacRouteAirRole.primary,
        waypoints: const [
          EvacWaypointAir(kind: 1, latE7: 1, lonE7: 2),
          EvacWaypointAir(kind: 1, latE7: 3, lonE7: 4),
        ],
      );
      expect(applier.apply(route).outcome, RadioApplyOutcome.applied);
      expect(applier.routesForKit(kitId)[_route]?.name, 'Main');
    });
  });
}
