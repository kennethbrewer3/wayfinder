import 'dart:async';
import 'dart:typed_data';

/// Opaque byte pipe for radio-sync frames (mesh, ham, loopback, …).
abstract class RadioTransport {
  /// Maximum application payload recommended for a single send (bytes).
  int get maxPayload;

  Stream<Uint8List> get incoming;

  Future<void> send(Uint8List frameBytes);

  Future<void> dispose();
}

/// Capabilities hint for scheduling / chunking.
class RadioTransportCapabilities {
  const RadioTransportCapabilities({
    required this.maxPayload,
    this.reliable = false,
    this.bidirectional = true,
  });

  final int maxPayload;
  final bool reliable;
  final bool bidirectional;
}
