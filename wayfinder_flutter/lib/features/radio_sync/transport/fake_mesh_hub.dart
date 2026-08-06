import 'dart:async';
import 'dart:typed_data';

import 'mesh_byte_channel.dart';
import 'mesh_radio_transport.dart';

/// In-process multi-peer mesh for tests and desk simulation (no radio hardware).
///
/// Each [join] returns a [MeshRadioTransport]. `send` delivers a copy to every
/// other joined peer (not the sender).
class FakeMeshHub {
  FakeMeshHub({this.maxPayload = MeshtasticPortNums.defaultMaxPayload});

  final int maxPayload;
  final List<_FakeMeshEndpoint> _peers = [];

  /// Join the hub as a new peer.
  MeshRadioTransport join({String? peerId}) {
    final endpoint = _FakeMeshEndpoint(
      hub: this,
      peerId: peerId ?? 'peer-${_peers.length}',
      maxPayload: maxPayload,
    );
    _peers.add(endpoint);
    return MeshRadioTransport(endpoint);
  }

  void _broadcast(_FakeMeshEndpoint from, Uint8List frame) {
    for (final peer in _peers) {
      if (identical(peer, from) || peer._disposed) {
        continue;
      }
      peer._controller.add(Uint8List.fromList(frame));
    }
  }

  void _remove(_FakeMeshEndpoint endpoint) {
    _peers.remove(endpoint);
  }

  int get peerCount => _peers.length;

  Future<void> dispose() async {
    final copy = List<_FakeMeshEndpoint>.from(_peers);
    for (final peer in copy) {
      await peer.dispose();
    }
  }
}

class _FakeMeshEndpoint implements MeshByteChannel {
  _FakeMeshEndpoint({
    required FakeMeshHub hub,
    required this.peerId,
    required this.maxPayload,
  }) : _hub = hub;

  final FakeMeshHub _hub;
  final String peerId;

  @override
  final int maxPayload;

  final _controller = StreamController<Uint8List>.broadcast();
  var _disposed = false;

  @override
  Stream<Uint8List> get incoming => _controller.stream;

  @override
  Future<void> send(Uint8List payload) async {
    if (_disposed) {
      throw StateError('Fake mesh peer disposed ($peerId)');
    }
    _hub._broadcast(this, payload);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _hub._remove(this);
    await _controller.close();
  }
}
