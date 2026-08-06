import 'dart:typed_data';

import '../models/radio_sync_msg_type.dart';
import 'radio_binary_io.dart';
import 'radio_crc32.dart';
import 'radio_uuid_bytes.dart';

/// Frame header size before payload (see `radio-sync-events.md` §5).
const radioFrameHeaderLength = 43;

/// Magic bytes `WF`.
const radioFrameMagic0 = 0x57;
const radioFrameMagic1 = 0x46;

/// Current on-air schema version.
const radioFrameVersion = 1;

/// Frame flag bits.
abstract final class RadioFrameFlags {
  static const int chunked = 1 << 0;
  static const int ackRequest = 1 << 1;
}

/// Decoded radio-sync frame (validated CRC).
class RadioFrame {
  const RadioFrame({
    required this.version,
    required this.flags,
    required this.msgType,
    required this.eventId,
    required this.entityId,
    required this.revisedAtSeconds,
    required this.payload,
  });

  final int version;
  final int flags;
  final int msgType;
  final String eventId;
  final String entityId;
  final int revisedAtSeconds;
  final Uint8List payload;

  bool get isChunked => (flags & RadioFrameFlags.chunked) != 0;
  bool get wantsAck => (flags & RadioFrameFlags.ackRequest) != 0;
}

/// Encode a frame with CRC trailer.
Uint8List encodeRadioFrame({
  required int msgType,
  required String eventId,
  required String entityId,
  required int revisedAtSeconds,
  required Uint8List payload,
  int flags = 0,
  int version = radioFrameVersion,
}) {
  if (payload.length > 0xffff) {
    throw ArgumentError('Payload exceeds uint16 length');
  }
  final writer = RadioBinaryWriter(radioFrameHeaderLength + payload.length + 4);
  writer.u8(radioFrameMagic0);
  writer.u8(radioFrameMagic1);
  writer.u8(version);
  writer.u8(flags);
  writer.u8(msgType);
  writer.uuid(eventId);
  writer.uuid(entityId);
  writer.u32(revisedAtSeconds);
  writer.u16(payload.length);
  writer.bytes(payload);
  final withoutCrc = writer.toBytes();
  final crc = radioCrc32(withoutCrc);
  final out = Uint8List(withoutCrc.length + 4);
  out.setAll(0, withoutCrc);
  out[withoutCrc.length] = (crc >> 24) & 0xff;
  out[withoutCrc.length + 1] = (crc >> 16) & 0xff;
  out[withoutCrc.length + 2] = (crc >> 8) & 0xff;
  out[withoutCrc.length + 3] = crc & 0xff;
  return out;
}

/// Decode and CRC-check a frame. Returns `null` if corrupt or unknown magic.
RadioFrame? decodeRadioFrame(Uint8List bytes) {
  if (bytes.length < radioFrameHeaderLength + 4) {
    return null;
  }
  if (bytes[0] != radioFrameMagic0 || bytes[1] != radioFrameMagic1) {
    return null;
  }
  final bodyLen = bytes.length - 4;
  final expectedCrc =
      ((bytes[bodyLen] << 24) |
          (bytes[bodyLen + 1] << 16) |
          (bytes[bodyLen + 2] << 8) |
          bytes[bodyLen + 3]) &
      0xffffffff;
  final actualCrc = radioCrc32(bytes, 0, bodyLen);
  if (expectedCrc != actualCrc) {
    return null;
  }

  final version = bytes[2];
  final flags = bytes[3];
  final msgType = bytes[4];
  final eventId = uuidBytesToString(bytes, 5);
  final entityId = uuidBytesToString(bytes, 21);
  final revisedAt =
      ((bytes[37] << 24) | (bytes[38] << 16) | (bytes[39] << 8) | bytes[40]) &
      0xffffffff;
  final payloadLen = (bytes[41] << 8) | bytes[42];
  if (radioFrameHeaderLength + payloadLen + 4 != bytes.length) {
    return null;
  }
  final payload = Uint8List.sublistView(
    bytes,
    radioFrameHeaderLength,
    radioFrameHeaderLength + payloadLen,
  );

  // Unknown versions are ignored by callers; still return a frame if CRC ok.
  if (msgType == RadioSyncMsgType.chunk) {
    // Valid chunk envelope frame.
  }

  return RadioFrame(
    version: version,
    flags: flags,
    msgType: msgType,
    eventId: eventId,
    entityId: entityId,
    revisedAtSeconds: revisedAt,
    payload: Uint8List.fromList(payload),
  );
}
