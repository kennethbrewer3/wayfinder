import 'dart:async';
import 'dart:typed_data';

import '../apply/radio_event_applier.dart';
import '../codec/radio_chunker.dart';
import '../codec/radio_event_codec.dart';
import '../codec/radio_frame.dart';
import '../models/radio_domain_event.dart';
import '../models/radio_sync_msg_type.dart';
import '../transport/radio_transport.dart';

/// Publishes domain events and applies inbound frames from a [RadioTransport].
///
/// Phase B: codec + optional chunking + loopback. Does not touch Serverpod.
class RadioSyncSession {
  RadioSyncSession({
    required RadioTransport transport,
    RadioEventCodec codec = const RadioEventCodec(),
    RadioEventApplier? applier,
  }) : _transport = transport,
       _codec = codec,
       applier = applier ?? RadioEventApplier() {
    _subscription = _transport.incoming.listen(_onBytes);
  }

  final RadioTransport _transport;
  final RadioEventCodec _codec;
  final RadioEventApplier applier;
  final RadioChunkReassembler _reassembler = RadioChunkReassembler();
  final _appliedController = StreamController<RadioApplyResult>.broadcast();

  StreamSubscription<Uint8List>? _subscription;

  /// Outcomes for successfully decoded inbound events (after apply).
  Stream<RadioApplyResult> get applied => _appliedController.stream;

  /// Encode [event], chunk if needed, and send on the transport.
  Future<void> publish(RadioDomainEvent event) async {
    final logical = _codec.encode(event);
    if (logical.length <= _transport.maxPayload) {
      await _transport.send(logical);
      return;
    }
    final chunks = chunkRadioFrame(
      logicalFrame: logical,
      maxFrameBytes: _transport.maxPayload,
      transferId: event.eventId,
      revisedAtSeconds: event.revisedAtSeconds,
    );
    for (final chunk in chunks) {
      await _transport.send(chunk);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _reassembler.clear();
    await _appliedController.close();
  }

  void _onBytes(Uint8List bytes) {
    final frame = decodeRadioFrame(bytes);
    if (frame == null) {
      return;
    }
    if (frame.msgType == RadioSyncMsgType.chunk) {
      final logical = _reassembler.addChunkFrame(frame);
      if (logical == null) {
        return;
      }
      _applyDecoded(_codec.decode(logical));
      return;
    }
    try {
      _applyDecoded(
        _codec.decodePayload(
          msgType: frame.msgType,
          eventId: frame.eventId,
          entityId: frame.entityId,
          revisedAtSeconds: frame.revisedAtSeconds,
          payload: frame.payload,
        ),
      );
    } on FormatException {
      // Corrupt / unknown payload — drop.
    }
  }

  void _applyDecoded(RadioDomainEvent? event) {
    if (event == null) {
      return;
    }
    final result = applier.apply(event);
    if (!_appliedController.isClosed) {
      _appliedController.add(result);
    }
  }
}
