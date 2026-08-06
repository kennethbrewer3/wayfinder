import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

const _eventId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _entityId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

void main() {
  test('MeshCore send/recv framing round-trips payload', () {
    final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
    final send = encodeMeshCoreSendChannelData(payload);
    expect(send[0], MeshCoreAppData.cmdSendChannelData);
    expect(send[2], MeshCoreAppData.pathLenFlood);
    expect(
      send[3] | (send[4] << 8),
      MeshCoreAppData.dataTypeWayfinderRadioSync,
    );
    expect(send.sublist(5), payload);

    // Build a synthetic CHANNEL_DATA_RECV for the same payload.
    final recv = Uint8List(9 + payload.length);
    recv[0] = MeshCoreAppData.respChannelDataRecv;
    recv[4] = 0; // channel
    recv[5] = 0xff; // path meta
    recv[6] = MeshCoreAppData.dataTypeWayfinderRadioSync & 0xff;
    recv[7] = (MeshCoreAppData.dataTypeWayfinderRadioSync >> 8) & 0xff;
    recv[8] = payload.length;
    recv.setRange(9, 9 + payload.length, payload);

    expect(decodeMeshCoreChannelDataRecv(recv), payload);
    expect(
      decodeMeshCoreChannelDataRecv(recv, expectedDataType: 0x1234),
      isNull,
    );
  });

  test('MeshCoreChannelStub injectCompanionFrame feeds session', () async {
    final stub = MeshCoreChannelStub();
    final session = RadioSyncSession(transport: MeshRadioTransport(stub));
    final event = RadioDomainEvent.logAppend(
      eventId: _eventId,
      entityId: _entityId,
      revisedAtSeconds: 1,
      occurredAtSeconds: 1,
      severity: RadioLogSeverity.info,
      text: 'via meshcore',
    );
    final frame = const RadioEventCodec().encode(event);
    final companion = Uint8List(9 + frame.length)
      ..[0] = MeshCoreAppData.respChannelDataRecv
      ..[4] = 0
      ..[5] = 0xff
      ..[6] = MeshCoreAppData.dataTypeWayfinderRadioSync & 0xff
      ..[7] = (MeshCoreAppData.dataTypeWayfinderRadioSync >> 8) & 0xff
      ..[8] = frame.length
      ..setRange(9, 9 + frame.length, frame);

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
    expect(stub.injectCompanionFrame(companion), isTrue);
    await applied;
    expect(session.applier.logs.single.text, 'via meshcore');
    await session.dispose();
    await stub.dispose();
  });
}
