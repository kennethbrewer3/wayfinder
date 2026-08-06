import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../codec/radio_chunker.dart';
import 'fake_mesh_hub.dart';
import 'mesh_byte_channel.dart';
import 'mesh_radio_transport.dart';
import 'radio_transport.dart';

/// Ham digimode defaults — small MTU forces radio-sync chunking.
abstract final class HamDigimodeLimits {
  /// Conservative digimode MTU (bytes). Must be ≥ [radioMinChunkMaxFrameBytes]
  /// so chunk envelopes fit; still forces chunking for typical events.
  static const int defaultMaxPayload = 80;

  /// Prefix for optional text-channel framing (Base64URL of frame bytes).
  static const String textFramePrefix = 'WF1:';
}

/// Encode a binary radio frame for text-only digimode channels.
String encodeHamTextFrame(Uint8List frameBytes) =>
    '${HamDigimodeLimits.textFramePrefix}${base64UrlEncode(frameBytes)}';

/// Decode a text digimode line back to frame bytes. Returns `null` if not ours.
Uint8List? decodeHamTextFrame(String line) {
  final trimmed = line.trim();
  if (!trimmed.startsWith(HamDigimodeLimits.textFramePrefix)) {
    return null;
  }
  try {
    return Uint8List.fromList(
      base64Url.decode(
        trimmed.substring(HamDigimodeLimits.textFramePrefix.length),
      ),
    );
  } catch (_) {
    return null;
  }
}

/// In-process ham-style hub (same fan-out as mesh, tiny MTU).
class FakeHamHub {
  FakeHamHub({this.maxPayload = HamDigimodeLimits.defaultMaxPayload})
    : assert(maxPayload >= radioMinChunkMaxFrameBytes),
      _hub = FakeMeshHub(maxPayload: maxPayload);

  final int maxPayload;
  final FakeMeshHub _hub;

  MeshRadioTransport join({String? peerId}) =>
      _hub.join(peerId: peerId ?? 'ham-${_hub.peerCount}');

  int get peerCount => _hub.peerCount;

  Future<void> dispose() => _hub.dispose();
}

/// Placeholder channel for a real digimode modem (audio / serial TNC).
///
/// Sends throw until a modem bridge is plugged in. [injectIncoming] / text
/// helpers support desk tests of the text framing path.
class HamDigimodeChannelStub implements MeshByteChannel {
  HamDigimodeChannelStub({
    this.maxPayload = HamDigimodeLimits.defaultMaxPayload,
  }) : assert(maxPayload >= radioMinChunkMaxFrameBytes);

  @override
  final int maxPayload;

  final _controller = StreamController<Uint8List>.broadcast();
  var _disposed = false;

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  @override
  Future<void> send(Uint8List payload) async {
    if (_disposed) {
      throw StateError('HamDigimodeChannelStub disposed');
    }
    throw StateError(
      'Ham digimode modem not connected. '
      'Use simulated ham for desk tests, or plug a MeshByteChannel that '
      'forwards frames (optionally via encodeHamTextFrame).',
    );
  }

  void injectIncoming(Uint8List frame) {
    if (!_disposed && !_controller.isClosed) {
      _controller.add(Uint8List.fromList(frame));
    }
  }

  /// Inject a text digimode line (`WF1:…`).
  bool injectTextLine(String line) {
    final frame = decodeHamTextFrame(line);
    if (frame == null) {
      return false;
    }
    injectIncoming(frame);
    return true;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _controller.close();
  }
}

/// Convenience: wrap a ham [MeshByteChannel] as [RadioTransport].
RadioTransport hamRadioTransport(MeshByteChannel channel) =>
    MeshRadioTransport(channel);
