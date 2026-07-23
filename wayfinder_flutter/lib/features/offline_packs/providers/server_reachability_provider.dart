import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../data/offline_pack_store.dart';

/// Whether the Wayfinder appliance RPC is reachable.
final serverReachableProvider =
    StateNotifierProvider<ServerReachableNotifier, bool>(
      (ref) => ServerReachableNotifier(ref),
    );

class ServerReachableNotifier extends StateNotifier<bool> {
  ServerReachableNotifier(this._ref) : super(true) {
    unawaited(checkNow());
    // Tick often; skip probes while kiosk to keep a quieter battery profile.
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      final minInterval = _ref.read(kioskModeActiveProvider)
          ? const Duration(seconds: 60)
          : const Duration(seconds: 12);
      final last = _lastCheckAt;
      if (last != null && DateTime.now().difference(last) < minInterval) {
        return;
      }
      unawaited(checkNow());
    });
  }

  final Ref _ref;
  Timer? _timer;
  DateTime? _lastCheckAt;

  Future<void> checkNow() async {
    _lastCheckAt = DateTime.now();
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
