import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../data/kiosk_mode_storage.dart';

/// Whether this client has opted into local kiosk (viewer) mode.
final localKioskModeProvider =
    StateNotifierProvider<LocalKioskModeNotifier, bool>(
      (ref) => LocalKioskModeNotifier(),
    );

class LocalKioskModeNotifier extends StateNotifier<bool> {
  LocalKioskModeNotifier() : super(false) {
    unawaited(_load());
  }

  Future<void> _load() async {
    state = await KioskModeStorage.isEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await KioskModeStorage.setEnabled(enabled);
    state = enabled;
    AppLogger.logSettings.info(
      enabled ? '🖥️ Kiosk mode enabled' : '🖥️ Kiosk mode disabled',
    );
  }
}

/// Server-reported appliance read-only flag (`WAYFINDER_READ_ONLY`).
final serverReadOnlyProvider =
    StateNotifierProvider<ServerReadOnlyNotifier, bool>(
      (ref) => ServerReadOnlyNotifier(),
    );

class ServerReadOnlyNotifier extends StateNotifier<bool> {
  ServerReadOnlyNotifier() : super(false) {
    unawaited(checkNow());
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(checkNow());
    });
  }

  Timer? _timer;

  Future<void> checkNow() async {
    try {
      final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
      final uri = Uri.parse('$base/api/status');
      // Public endpoint — no auth headers. Custom headers force a CORS
      // preflight; Relic MethodMiss on OPTIONS historically returned 405
      // without Access-Control-* and blocked the poll from Flutter web.
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return;
      }
      final decoded = jsonDecode(response.body);
      final readOnly = decoded is Map<String, dynamic>
          ? decoded['readOnly'] == true
          : false;
      if (readOnly != state) {
        AppLogger.logMap.info(
          readOnly
              ? '🖥️ Server entered read-only mode'
              : '🖥️ Server left read-only mode',
        );
        state = readOnly;
      }
    } on Object {
      // Keep last known value when unreachable; offline pack handles that path.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// True when this client should behave as a TOC / spare-laptop viewer.
///
/// Active when the user enables local kiosk mode, or when the connected
/// appliance is running with `WAYFINDER_READ_ONLY`.
final kioskModeActiveProvider = Provider<bool>((ref) {
  final local = ref.watch(localKioskModeProvider);
  final server = ref.watch(serverReadOnlyProvider);
  return local || server;
});

/// True when kiosk cannot be exited from the UI (server enforces read-only).
final kioskModeServerEnforcedProvider = Provider<bool>((ref) {
  return ref.watch(serverReadOnlyProvider);
});
