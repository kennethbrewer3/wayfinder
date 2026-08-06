import 'dart:async';
import 'dart:typed_data';

import 'radio_transport.dart';

/// In-process transport for tests and desk development (no radio hardware).
///
/// Pair two instances with [connect] so each `send` appears on the peer's
/// [incoming] stream.
class LoopbackRadioTransport implements RadioTransport {
  LoopbackRadioTransport({this.maxPayload = 200});

  @override
  final int maxPayload;

  final _controller = StreamController<Uint8List>.broadcast();
  LoopbackRadioTransport? _peer;
  var _disposed = false;

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  /// Wire [a] ↔ [b] as peers.
  static void connect(LoopbackRadioTransport a, LoopbackRadioTransport b) {
    a._peer = b;
    b._peer = a;
  }

  @override
  Future<void> send(Uint8List frameBytes) async {
    if (_disposed) {
      throw StateError('LoopbackRadioTransport disposed');
    }
    final peer = _peer;
    if (peer == null || peer._disposed) {
      return;
    }
    peer._controller.add(Uint8List.fromList(frameBytes));
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _peer = null;
    await _controller.close();
  }
}
