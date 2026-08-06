import 'dart:async';
import 'dart:typed_data';

import 'mesh_byte_channel.dart';

/// MeshCore companion-radio constants for Wayfinder radio-sync.
///
/// Channel datagrams use `CMD_SEND_CHANNEL_DATA` / `PACKET_CHANNEL_DATA_RECV`
/// with an opaque [dataTypeWayfinderRadioSync] payload (our binary frames).
/// See https://docs.meshcore.io/companion_protocol/
abstract final class MeshCoreAppData {
  /// Companion command: send channel data datagram.
  static const int cmdSendChannelData = 0x3e;

  /// Companion response / push: inbound channel data datagram.
  static const int respChannelDataRecv = 0x1b;

  /// Flood path length on send (`0xFF` = flood).
  static const int pathLenFlood = 0xff;

  /// Default channel slot until Settings exposes channel selection.
  static const int defaultChannelIndex = 0;

  /// Wayfinder radio-sync app id (dev/test range `0xFF00`–`0xFFFE`).
  ///
  /// Register a permanent value in MeshCore `number_allocations.md` before
  /// wide deployment; until then peers must agree on this type.
  static const int dataTypeWayfinderRadioSync = 0xff01;

  /// Firmware max binary payload for channel data (`MAX_CHANNEL_DATA_LENGTH`).
  static const int maxChannelDataLength = 163;

  /// Default [MeshByteChannel.maxPayload] for MeshCore.
  static const int defaultMaxPayload = maxChannelDataLength;
}

/// Build a companion `CMD_SEND_CHANNEL_DATA` frame (flood) for [payload].
Uint8List encodeMeshCoreSendChannelData(
  Uint8List payload, {
  int channelIndex = MeshCoreAppData.defaultChannelIndex,
  int dataType = MeshCoreAppData.dataTypeWayfinderRadioSync,
}) {
  if (payload.length > MeshCoreAppData.maxChannelDataLength) {
    throw ArgumentError(
      'MeshCore payload ${payload.length} exceeds '
      '${MeshCoreAppData.maxChannelDataLength}',
    );
  }
  final out = Uint8List(1 + 1 + 1 + 2 + payload.length);
  out[0] = MeshCoreAppData.cmdSendChannelData;
  out[1] = channelIndex & 0xff;
  out[2] = MeshCoreAppData.pathLenFlood;
  out[3] = dataType & 0xff;
  out[4] = (dataType >> 8) & 0xff;
  out.setRange(5, 5 + payload.length, payload);
  return out;
}

/// Extract Wayfinder payload from `PACKET_CHANNEL_DATA_RECV` (0x1B).
///
/// Returns `null` if the frame is not ours or is malformed.
Uint8List? decodeMeshCoreChannelDataRecv(
  Uint8List frame, {
  int expectedDataType = MeshCoreAppData.dataTypeWayfinderRadioSync,
}) {
  if (frame.length < 9) {
    return null;
  }
  if (frame[0] != MeshCoreAppData.respChannelDataRecv) {
    return null;
  }
  final dataType = frame[6] | (frame[7] << 8);
  if (dataType != expectedDataType) {
    return null;
  }
  final dataLen = frame[8];
  if (9 + dataLen > frame.length) {
    return null;
  }
  return Uint8List.sublistView(frame, 9, 9 + dataLen);
}

/// Placeholder [MeshByteChannel] for a future MeshCore BLE/USB companion bridge.
///
/// Phase wiring matches Meshtastic: opaque radio-sync frames on the channel
/// datagram path. Real device I/O replaces this stub and uses
/// [encodeMeshCoreSendChannelData] / [decodeMeshCoreChannelDataRecv].
class MeshCoreChannelStub implements MeshByteChannel {
  MeshCoreChannelStub({
    this.maxPayload = MeshCoreAppData.defaultMaxPayload,
    this.channelIndex = MeshCoreAppData.defaultChannelIndex,
  });

  @override
  final int maxPayload;

  /// MeshCore channel slot (0–7) for outbound datagrams.
  final int channelIndex;

  final _controller = StreamController<Uint8List>.broadcast();
  var _disposed = false;

  bool get isLinked => false;

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  @override
  Future<void> send(Uint8List payload) async {
    if (_disposed) {
      throw StateError('MeshCoreChannelStub disposed');
    }
    throw StateError(
      'MeshCore companion bridge not connected. '
      'Use simulated mesh for desk tests, or plug a MeshByteChannel that '
      'sends CMD_SEND_CHANNEL_DATA (0x3E) with data_type '
      '0x${MeshCoreAppData.dataTypeWayfinderRadioSync.toRadixString(16)}.',
    );
  }

  /// Inject a decoded radio-sync frame (as if extracted from CHANNEL_DATA_RECV).
  void injectIncoming(Uint8List frame) {
    if (!_disposed && !_controller.isClosed) {
      _controller.add(Uint8List.fromList(frame));
    }
  }

  /// Inject a raw companion `PACKET_CHANNEL_DATA_RECV` frame.
  bool injectCompanionFrame(Uint8List companionFrame) {
    final payload = decodeMeshCoreChannelDataRecv(companionFrame);
    if (payload == null) {
      return false;
    }
    injectIncoming(payload);
    return true;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _controller.close();
  }
}
