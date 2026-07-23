import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../data/offline_pack_store.dart';

/// Whether the Wayfinder appliance RPC is reachable.
final serverReachableProvider =
    StateNotifierProvider<ServerReachableNotifier, bool>(
      (ref) => ServerReachableNotifier(ref),
    );

class ServerReachableNotifier extends StateNotifier<bool> {
  ServerReachableNotifier(this._ref) : super(true) {
    unawaited(checkNow());
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      unawaited(checkNow());
    });
  }

  final Ref _ref;
  Timer? _timer;

  Future<void> checkNow() async {
    try {
      await _ref.read(serverClientProvider).appSettings.getSettings();
      if (!state) {
        AppLogger.logMap.info('Server reachable again');
      }
      state = true;
    } catch (_) {
      if (state) {
        AppLogger.logMap.warn('Server unreachable — entering offline mode');
      }
      state = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Loaded pack metadata (null if none prepared).
final offlinePackMetaProvider = FutureProvider((ref) async {
  return ref.watch(offlinePackStoreProvider).loadMeta();
});

/// True when the client should use the offline pack (server down + pack ready).
final offlineModeActiveProvider = Provider<bool>((ref) {
  final reachable = ref.watch(serverReachableProvider);
  final hasPack = ref.watch(offlinePackMetaProvider).valueOrNull != null;
  return !reachable && hasPack;
});
