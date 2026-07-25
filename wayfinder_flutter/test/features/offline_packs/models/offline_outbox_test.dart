import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/offline_packs/models/offline_outbox.dart';

void main() {
  group('offlinePayloadEntityId', () {
    test('reads string ids', () {
      expect(
        offlinePayloadEntityId({'id': 'abc-123'}),
        'abc-123',
      );
    });

    test('stringifies nested values', () {
      expect(
        offlinePayloadEntityId({'id': 42}),
        '42',
      );
    });

    test('returns null when missing', () {
      expect(offlinePayloadEntityId({}), isNull);
      expect(offlinePayloadEntityId({'markerId': 'x'}, 'id'), isNull);
    });

    test('supports alternate keys', () {
      expect(
        offlinePayloadEntityId({'markerId': 'm-1'}, 'markerId'),
        'm-1',
      );
    });
  });

  group('offlineOpTargetsMarker', () {
    final markerId = UuidValue.fromString(
      '11111111-1111-4111-8111-111111111111',
    );

    test('matches create/update marker by payload id', () {
      final create = OfflineOutboxOp(
        id: 'op-1',
        type: OfflineOutboxOpType.createMarker,
        payload: {'id': markerId.uuid},
        createdAt: DateTime.utc(2024),
      );
      final update = OfflineOutboxOp(
        id: 'op-2',
        type: OfflineOutboxOpType.updateMarker,
        payload: {'id': markerId.uuid},
        createdAt: DateTime.utc(2024),
      );
      final other = OfflineOutboxOp(
        id: 'op-3',
        type: OfflineOutboxOpType.updateMarker,
        payload: {'id': '22222222-2222-4222-8222-222222222222'},
        createdAt: DateTime.utc(2024),
      );

      expect(offlineOpTargetsMarker(create, markerId), isTrue);
      expect(offlineOpTargetsMarker(update, markerId), isTrue);
      expect(offlineOpTargetsMarker(other, markerId), isFalse);
    });

    test('matches watch log by markerId', () {
      final op = OfflineOutboxOp(
        id: 'op-4',
        type: OfflineOutboxOpType.createWatchLogEntry,
        payload: {'markerId': markerId.uuid, 'text': 'sighted'},
        createdAt: DateTime.utc(2024),
      );
      expect(offlineOpTargetsMarker(op, markerId), isTrue);
    });

    test('never matches track zone upserts', () {
      final op = OfflineOutboxOp(
        id: 'op-5',
        type: OfflineOutboxOpType.upsertTrackZone,
        payload: {'id': markerId.uuid},
        createdAt: DateTime.utc(2024),
      );
      expect(offlineOpTargetsMarker(op, markerId), isFalse);
    });
  });

  group('OfflineOutboxOp JSON', () {
    test('round-trips', () {
      final original = OfflineOutboxOp(
        id: 'op-json',
        type: OfflineOutboxOpType.createWatchLogEntry,
        payload: {'text': 'hello', 'severity': 'info'},
        createdAt: DateTime.utc(2025, 1, 2, 3, 4, 5),
      );
      final decoded = OfflineOutboxOp.fromJson(original.toJson());
      expect(decoded.id, original.id);
      expect(decoded.type, original.type);
      expect(decoded.payload['text'], 'hello');
      expect(decoded.createdAt, original.createdAt);
    });
  });
}
