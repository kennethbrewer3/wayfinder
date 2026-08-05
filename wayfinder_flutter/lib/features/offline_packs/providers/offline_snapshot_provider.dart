import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_pack_store.dart';
import '../models/offline_outbox.dart';
import '../models/offline_packed_route.dart';
import '../models/offline_snapshot.dart';

final offlineSnapshotProvider = FutureProvider<OfflineSnapshot?>((ref) async {
  return ref.watch(offlinePackStoreProvider).loadSnapshot();
});

/// Precomputed OSM routes in the active offline pack (empty when none).
final offlinePackedRoutesProvider = Provider<List<OfflinePackedRoute>>((ref) {
  return ref.watch(offlineSnapshotProvider).valueOrNull?.routes ?? const [];
});

/// Packed route for [markerId], if one was stored during pack prepare.
OfflinePackedRoute? packedRouteForMarker(
  List<OfflinePackedRoute> routes,
  String markerId,
) {
  for (final route in routes) {
    if (route.destinationMarkerId == markerId) {
      return route;
    }
  }
  return null;
}

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
