import 'dart:async';
import 'dart:typed_data';

import 'mesh_byte_channel.dart';
import 'radio_transport.dart';

/// [RadioTransport] adapter over a [MeshByteChannel] (Meshtastic-first).
class MeshRadioTransport implements RadioTransport {
  MeshRadioTransport(this._channel);

  final MeshByteChannel _channel;

  @override
  int get maxPayload => _channel.maxPayload;

  @override
  Stream<Uint8List> get incoming => _channel.incoming;

  @override
  Future<void> send(Uint8List frameBytes) => _channel.send(frameBytes);

  @override
  Future<void> dispose() => _channel.dispose();

  RadioTransportCapabilities get capabilities => RadioTransportCapabilities(
    maxPayload: maxPayload,
    reliable: false,
    bidirectional: true,
  );
}
