import 'dart:async';
import 'dart:typed_data';

/// Opaque bidirectional byte pipe for mesh firmwares (Meshtastic PRIVATE_APP,
/// MeshCore companion channel datagrams, …). Transports wrap this; BLE/USB
/// live behind implementations.
abstract class MeshByteChannel {
  /// Recommended max application payload (bytes) for a single send.
  int get maxPayload;

  Stream<Uint8List> get incoming;

  Future<void> send(Uint8List payload);

  Future<void> dispose();
}

/// Meshtastic port numbers we care about for Wayfinder radio-sync.
///
/// Frames are sent as opaque app payloads (`PRIVATE_APP` / port 256).
abstract final class MeshtasticPortNums {
  /// Private application data (Meshtastic `PortNum.PRIVATE_APP`).
  static const int privateApp = 256;

  /// Default max payload we target for mesh frames (after mesh headers).
  static const int defaultMaxPayload = 200;
}
