import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

void main() {
  test('MarkerUpsertEvent exposes design msgType and copyWith', () {
    final event = RadioDomainEvent.markerUpsert(
      eventId: '11111111-1111-1111-1111-111111111111',
      entityId: '22222222-2222-2222-2222-222222222222',
      revisedAtSeconds: 1_700_000_000,
      name: 'Ridge OP',
      latE7: 351234567,
      lonE7: -1061234567,
      colorRgb: 0xff0000,
      iconId: 1,
    );

    expect(event, isA<MarkerUpsertEvent>());
    expect(event.msgType, RadioSyncMsgType.markerUpsert);

    final updated = (event as MarkerUpsertEvent).copyWith(name: 'South OP');
    expect(updated.name, 'South OP');
    expect(updated.entityId, event.entityId);
  });

  test('EvacRouteUpsertEvent carries waypoints', () {
    final event = RadioDomainEvent.evacRouteUpsert(
      eventId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      entityId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      revisedAtSeconds: 1_700_000_001,
      routeId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      name: 'Primary egress',
      role: EvacRouteAirRole.primary,
      waypoints: const [
        EvacWaypointAir(
          kind: EvacWaypointAirKind.point,
          latE7: 351000000,
          lonE7: -1060000000,
        ),
        EvacWaypointAir(
          kind: EvacWaypointAirKind.marker,
          latE7: 351100000,
          lonE7: -1060100000,
          markerId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
          label: 'Gate',
        ),
      ],
    );

    expect(event.msgType, RadioSyncMsgType.evacRouteUpsert);
    expect((event as EvacRouteUpsertEvent).waypoints, hasLength(2));
  });

  group('msgType matrix', () {
    test('every variant maps to the design-doc constant', () {
      final cases = <RadioDomainEvent, int>{
        RadioDomainEvent.markerUpsert(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          name: 'n',
          latE7: 0,
          lonE7: 0,
          colorRgb: 0,
          iconId: 0,
        ): RadioSyncMsgType.markerUpsert,
        RadioDomainEvent.markerDelete(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
        ): RadioSyncMsgType.markerDelete,
        RadioDomainEvent.zoneUpsertLight(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          name: 'z',
          zoneType: 0,
          colorRgb: 0,
          borderColorRgb: 0,
          fillColorRgb: 0,
          geometryBytes: const [],
        ): RadioSyncMsgType.zoneUpsertLight,
        RadioDomainEvent.zoneDelete(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
        ): RadioSyncMsgType.zoneDelete,
        RadioDomainEvent.logAppend(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          occurredAtSeconds: 1,
          severity: RadioLogSeverity.info,
          text: 't',
        ): RadioSyncMsgType.logAppend,
        RadioDomainEvent.eventAck(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          ackedEventId: 'a',
          status: 0,
        ): RadioSyncMsgType.eventAck,
        RadioDomainEvent.evacKitMetaUpsert(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          name: 'kit',
          colorRgb: 0,
          borderColorRgb: 0,
          fillColorRgb: 0,
          primaryRouteId: 'r',
          defaultMode: 0,
        ): RadioSyncMsgType.evacKitMetaUpsert,
        RadioDomainEvent.evacRouteUpsert(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          routeId: 'r',
          name: 'route',
          role: EvacRouteAirRole.alternate,
          waypoints: const [],
        ): RadioSyncMsgType.evacRouteUpsert,
        RadioDomainEvent.evacRouteDelete(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          routeId: 'r',
        ): RadioSyncMsgType.evacRouteDelete,
        RadioDomainEvent.evacKitDelete(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
        ): RadioSyncMsgType.evacKitDelete,
        RadioDomainEvent.hello(
          eventId: 'e',
          entityId: 'x',
          revisedAtSeconds: 1,
          senderUnitId: 'unit-1',
          schemaVersion: 1,
        ): RadioSyncMsgType.hello,
      };

      for (final entry in cases.entries) {
        expect(
          entry.key.msgType,
          entry.value,
          reason: entry.key.runtimeType.toString(),
        );
      }
    });

    test('design constants match documented hex values', () {
      expect(RadioSyncMsgType.markerUpsert, 0x01);
      expect(RadioSyncMsgType.markerDelete, 0x02);
      expect(RadioSyncMsgType.zoneUpsertLight, 0x03);
      expect(RadioSyncMsgType.zoneDelete, 0x04);
      expect(RadioSyncMsgType.logAppend, 0x05);
      expect(RadioSyncMsgType.eventAck, 0x06);
      expect(RadioSyncMsgType.evacKitMetaUpsert, 0x10);
      expect(RadioSyncMsgType.evacRouteUpsert, 0x11);
      expect(RadioSyncMsgType.evacRouteDelete, 0x12);
      expect(RadioSyncMsgType.evacKitDelete, 0x13);
      expect(RadioSyncMsgType.chunk, 0x7e);
      expect(RadioSyncMsgType.hello, 0x7f);
    });
  });
}
