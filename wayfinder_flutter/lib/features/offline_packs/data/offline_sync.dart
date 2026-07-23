import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../models/offline_outbox.dart';
import 'offline_pack_store.dart';

/// Flushes queued offline mutations to the server.
///
/// Track zones are applied before markers so createMarker can reference an
/// existing [trackZoneId] when [isTracking] is true.
Future<int> flushOfflineOutbox({
  required Client client,
  required OfflinePackStore store,
}) async {
  final ops = await store.loadOutbox();
  if (ops.isEmpty) {
    return 0;
  }

  final ordered = [
    for (final op in ops)
      if (op.type == OfflineOutboxOpType.upsertTrackZone) op,
    for (final op in ops)
      if (op.type != OfflineOutboxOpType.upsertTrackZone) op,
  ];

  final remaining = <OfflineOutboxOp>[];
  var flushed = 0;
  for (final op in ordered) {
    try {
      switch (op.type) {
        case OfflineOutboxOpType.createMarker:
          final marker = MapMarker.fromJson(op.payload);
          try {
            await client.mapMarker.createMarker(marker);
          } catch (_) {
            await client.mapMarker.updateMarker(marker);
          }
        case OfflineOutboxOpType.updateMarker:
          final marker = MapMarker.fromJson(op.payload);
          try {
            await client.mapMarker.updateMarker(marker);
          } catch (_) {
            await client.mapMarker.createMarker(marker);
          }
        case OfflineOutboxOpType.createWatchLogEntry:
          final entry = WatchLogEntry.fromJson(op.payload);
          await client.watchLog.createEntry(entry);
        case OfflineOutboxOpType.upsertTrackZone:
          final zone = MapZone.fromJson(op.payload);
          try {
            await client.mapZone.updateZone(zone);
          } catch (_) {
            await client.mapZone.createZone(zone);
          }
      }
      flushed += 1;
    } catch (error, stackTrace) {
      AppLogger.logMap.error(
        'Offline outbox op failed',
        error: error,
        stackTrace: stackTrace,
        data: op.type.name,
      );
      remaining.add(op);
    }
  }
  await store.saveOutbox(remaining);
  if (flushed > 0) {
    AppLogger.logMap.success(
      'Offline outbox flushed',
      data: 'flushed=$flushed remaining=${remaining.length}',
    );
  }
  return flushed;
}
