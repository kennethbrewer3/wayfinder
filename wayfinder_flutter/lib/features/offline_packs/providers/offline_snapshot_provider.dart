import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_pack_store.dart';
import '../models/offline_outbox.dart';
import '../models/offline_snapshot.dart';

final offlineSnapshotProvider = FutureProvider<OfflineSnapshot?>((ref) async {
  return ref.watch(offlinePackStoreProvider).loadSnapshot();
});

final offlineOutboxCountProvider = FutureProvider<int>((ref) async {
  final ops = await ref.watch(offlinePackStoreProvider).loadOutbox();
  return ops.length;
});

/// Marker UUID strings that exist only in the local outbox (not yet on server).
final offlinePendingCreateMarkerIdsProvider = FutureProvider<Set<String>>((
  ref,
) async {
  // Rebuild when outbox mutations invalidate the count provider.
  ref.watch(offlineOutboxCountProvider);
  final ops = await ref.watch(offlinePackStoreProvider).loadOutbox();
  return {
    for (final op in ops)
      if (op.type == OfflineOutboxOpType.createMarker)
        ?offlinePayloadEntityId(op.payload),
  };
});
