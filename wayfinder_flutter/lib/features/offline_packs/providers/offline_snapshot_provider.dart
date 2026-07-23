import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_pack_store.dart';
import '../models/offline_snapshot.dart';

final offlineSnapshotProvider = FutureProvider<OfflineSnapshot?>((ref) async {
  return ref.watch(offlinePackStoreProvider).loadSnapshot();
});

final offlineOutboxCountProvider = FutureProvider<int>((ref) async {
  final ops = await ref.watch(offlinePackStoreProvider).loadOutbox();
  return ops.length;
});
