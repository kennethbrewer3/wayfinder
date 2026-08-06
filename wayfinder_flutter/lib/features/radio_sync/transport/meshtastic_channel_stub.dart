import 'dart:async';
import 'dart:typed_data';

import 'mesh_byte_channel.dart';

/// Placeholder [MeshByteChannel] for a future Meshtastic BLE/serial bridge.
///
/// Phase D ships the adapter contract (`MeshRadioTransport` + PRIVATE_APP
/// port). Real device I/O plugs in by replacing this with a BLE-backed
/// channel that forwards opaque payloads on [MeshtasticPortNums.privateApp].
class MeshtasticChannelStub implements MeshByteChannel {
  MeshtasticChannelStub({
    this.maxPayload = MeshtasticPortNums.defaultMaxPayload,
  });

  @override
  final int maxPayload;

  final _controller = StreamController<Uint8List>.broadcast();
  var _disposed = false;

  /// Whether a real radio link is open (always false for the stub).
  bool get isLinked => false;

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  @override
  Future<void> send(Uint8List payload) async {
    if (_disposed) {
      throw StateError('MeshtasticChannelStub disposed');
    }
    throw StateError(
      'Meshtastic BLE bridge not connected. '
      'Use simulated mesh for desk tests, or plug a MeshByteChannel '
      'implementation that talks PRIVATE_APP (${MeshtasticPortNums.privateApp}).',
    );
  }

  /// Inject a frame as if received from the radio (manual / future BLE glue).
  void injectIncoming(Uint8List frame) {
    if (!_disposed && !_controller.isClosed) {
      _controller.add(Uint8List.fromList(frame));
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _controller.close();
  }
}
