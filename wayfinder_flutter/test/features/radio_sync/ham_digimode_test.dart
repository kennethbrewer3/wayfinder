import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

const _eventId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _entityId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

void main() {
  test('ham text framing round-trips', () {
    final bytes = Uint8List.fromList([0x57, 0x46, 1, 2, 3]);
    final line = encodeHamTextFrame(bytes);
    expect(line.startsWith(HamDigimodeLimits.textFramePrefix), isTrue);
    expect(decodeHamTextFrame(line), bytes);
    expect(decodeHamTextFrame('noise'), isNull);
  });

  test('FakeHamHub forces chunking for MarkerUpsert', () async {
    final hub = FakeHamHub(); // 80-byte MTU
    final a = RadioSyncSession(transport: hub.join(peerId: 'a'));
    final b = RadioSyncSession(transport: hub.join(peerId: 'b'));

    final event = RadioDomainEvent.markerUpsert(
      eventId: _eventId,
      entityId: _entityId,
      revisedAtSeconds: 99,
      name: 'Ham OP with a longer name for payload',
      latE7: 351234567,
      lonE7: -1061234567,
      elevationMeters: 1200,
      colorRgb: 0xff00aa,
      iconId: 4,
      notes: 'notes for digimode chunking test path',
      layerId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    );

    // Confirm the logical frame exceeds ham MTU so chunking is used.
    final logical = const RadioEventCodec().encode(event);
    expect(logical.length, greaterThan(HamDigimodeLimits.defaultMaxPayload));

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
    expect(
      (b.applier.entities[_entityId] as MarkerUpsertEvent).name,
      startsWith('Ham OP'),
    );

    await a.dispose();
    await b.dispose();
    await hub.dispose();
  });

  test('HamDigimodeChannelStub injectTextLine feeds session', () async {
    final stub = HamDigimodeChannelStub();
    final session = RadioSyncSession(transport: hamRadioTransport(stub));
    final event = RadioDomainEvent.logAppend(
      eventId: _eventId,
      entityId: _entityId,
      revisedAtSeconds: 1,
      occurredAtSeconds: 1,
      severity: RadioLogSeverity.info,
      text: 'via text modem',
    );
    final frame = const RadioEventCodec().encode(event);
    final applied = expectLater(
      session.applied,
      emits(
        isA<RadioApplyResult>().having(
          (r) => r.outcome,
          'outcome',
          RadioApplyOutcome.applied,
        ),
      ),
    );
    expect(stub.injectTextLine(encodeHamTextFrame(frame)), isTrue);
    await applied;
    expect(session.applier.logs.single.text, 'via text modem');
    await session.dispose();
    await stub.dispose();
  });
}
