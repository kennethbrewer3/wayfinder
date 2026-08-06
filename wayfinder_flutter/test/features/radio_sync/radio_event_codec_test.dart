import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

const _eventId = '11111111-1111-1111-1111-111111111111';
const _entityId = '22222222-2222-2222-2222-222222222222';
const _layerId = '33333333-3333-3333-3333-333333333333';
const _routeId = '44444444-4444-4444-4444-444444444444';

void main() {
  const codec = RadioEventCodec();

  group('CRC / frame', () {
    test('CRC is deterministic', () {
      final data = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);
      expect(radioCrc32(data), radioCrc32(data));
      expect(radioCrc32(data), isNot(radioCrc32(Uint8List.fromList([0x00]))));
    });

    test('corrupt CRC rejects decode', () {
      final event = RadioDomainEvent.markerDelete(
        eventId: _eventId,
        entityId: _entityId,
        revisedAtSeconds: 100,
      );
      final bytes = codec.encode(event);
      bytes[bytes.length - 1] ^= 0xff;
      expect(codec.decode(bytes), isNull);
    });
  });

  group('round-trip', () {
    test('MarkerUpsert', () {
      final event = RadioDomainEvent.markerUpsert(
        eventId: _eventId,
        entityId: _entityId,
        revisedAtSeconds: 1_700_000_000,
        name: 'Ridge OP',
        latE7: 351234567,
        lonE7: -1061234567,
        elevationMeters: 2100,
        colorRgb: 0xff0000,
        iconId: 3,
        layerId: _layerId,
        notes: 'north ridge',
        isTracking: true,
      );
      final decoded = codec.decode(codec.encode(event));
      expect(decoded, event);
    });

    test('LogAppend', () {
      final event = RadioDomainEvent.logAppend(
        eventId: _eventId,
        entityId: _entityId,
        revisedAtSeconds: 50,
        occurredAtSeconds: 40,
        severity: RadioLogSeverity.warning,
        author: 'A1',
        text: 'smoke west',
        markerId: _layerId,
      );
      expect(codec.decode(codec.encode(event)), event);
    });

    test('EvacRouteUpsert with waypoints', () {
      final event = RadioDomainEvent.evacRouteUpsert(
        eventId: _eventId,
        entityId: _entityId,
        revisedAtSeconds: 9,
        routeId: _routeId,
        name: 'Primary',
        role: EvacRouteAirRole.primary,
        waypoints: [
          const EvacWaypointAir(
            kind: EvacWaypointAirKind.point,
            latE7: 1,
            lonE7: 2,
            label: 'A',
          ),
          const EvacWaypointAir(
            kind: EvacWaypointAirKind.control,
            latE7: 3,
            lonE7: 4,
          ),
        ],
      );
      expect(codec.decode(codec.encode(event)), event);
    });

    test('Hello', () {
      final event = RadioDomainEvent.hello(
        eventId: _eventId,
        entityId: _entityId,
        revisedAtSeconds: 1,
        senderUnitId: 'lookout-3',
        schemaVersion: 1,
      );
      expect(codec.decode(codec.encode(event)), event);
    });
  });

  group('chunking', () {
    test('reassembles logical frame', () {
      final event = RadioDomainEvent.zoneUpsertLight(
        eventId: _eventId,
        entityId: _entityId,
        revisedAtSeconds: 12,
        name: 'Circle',
        zoneType: 1,
        colorRgb: 1,
        borderColorRgb: 2,
        fillColorRgb: 3,
        geometryBytes: List<int>.generate(120, (i) => i & 0xff),
      );
      final logical = codec.encode(event);
      final chunks = chunkRadioFrame(
        logicalFrame: logical,
        maxFrameBytes: 80,
        transferId: _eventId,
      );
      expect(chunks.length, greaterThan(1));
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(80));
      }
      final reassembler = RadioChunkReassembler();
      Uint8List? rebuilt;
      for (final c in chunks) {
        final frame = decodeRadioFrame(c);
        expect(frame, isNotNull);
        rebuilt = reassembler.addChunkFrame(frame!) ?? rebuilt;
      }
      expect(rebuilt, logical);
      expect(codec.decode(rebuilt!), event);
    });
  });
}
