import 'dart:typed_data';

import '../models/radio_sync_msg_type.dart';
import 'radio_binary_io.dart';
import 'radio_frame.dart';

/// On-wire overhead for a chunk envelope: header (43) + CRC (4).
const radioChunkFrameOverhead = radioFrameHeaderLength + 4;

/// Split a complete logical frame into MTU-sized chunk envelopes.
///
/// [maxFrameBytes] is the largest complete on-wire frame the transport accepts
/// (including header and CRC).
List<Uint8List> chunkRadioFrame({
  required Uint8List logicalFrame,
  required int maxFrameBytes,
  required String transferId,
  int revisedAtSeconds = 0,
}) {
  final maxChunkPayload = maxFrameBytes - radioChunkFrameOverhead;
  // transferId[16] + seq[2] + total[2] + at least 1 data byte
  if (maxChunkPayload < 21) {
    throw ArgumentError(
      'maxFrameBytes ($maxFrameBytes) too small for chunk envelopes',
    );
  }
  final dataPerChunk = maxChunkPayload - 20;
  final total = (logicalFrame.length + dataPerChunk - 1) ~/ dataPerChunk;
  final frames = <Uint8List>[];
  for (var seq = 0; seq < total; seq++) {
    final start = seq * dataPerChunk;
    final end = (start + dataPerChunk).clamp(0, logicalFrame.length);
    final chunkData = Uint8List.sublistView(logicalFrame, start, end);
    final writer = RadioBinaryWriter(20 + chunkData.length)
      ..uuid(transferId)
      ..u16(seq)
      ..u16(total)
      ..bytes(Uint8List.fromList(chunkData));
    frames.add(
      encodeRadioFrame(
        msgType: RadioSyncMsgType.chunk,
        eventId: transferId,
        entityId: transferId,
        revisedAtSeconds: revisedAtSeconds,
        payload: writer.toBytes(),
        flags: RadioFrameFlags.chunked,
      ),
    );
  }
  return frames;
}

/// Reassembles chunk envelopes into a complete logical frame.
class RadioChunkReassembler {
  final Map<String, _Transfer> _transfers = {};

  /// Feed a decoded chunk frame. Returns the reassembled logical frame bytes
  /// when complete, otherwise `null`.
  Uint8List? addChunkFrame(RadioFrame frame) {
    if (frame.msgType != RadioSyncMsgType.chunk) {
      return null;
    }
    final r = RadioBinaryReader(frame.payload);
    final transferId = r.uuid();
    final seq = r.u16();
    final total = r.u16();
    if (total == 0 || seq >= total) {
      return null;
    }
    final chunkData = r.bytes(r.remaining);
    final transfer = _transfers.putIfAbsent(
      transferId,
      () => _Transfer(total: total),
    );
    if (transfer.total != total) {
      _transfers.remove(transferId);
      return null;
    }
    transfer.parts[seq] = chunkData;
    if (transfer.parts.length != total) {
      return null;
    }
    final builder = BytesBuilder(copy: false);
    for (var i = 0; i < total; i++) {
      final part = transfer.parts[i];
      if (part == null) {
        return null;
      }
      builder.add(part);
    }
    _transfers.remove(transferId);
    return builder.toBytes();
  }

  void clear() => _transfers.clear();
}

class _Transfer {
  _Transfer({required this.total});

  final int total;
  final Map<int, Uint8List> parts = {};
}
