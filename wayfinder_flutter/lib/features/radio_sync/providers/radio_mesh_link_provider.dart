import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';

/// How the app attaches a live radio transport (mesh or ham).
enum RadioMeshLinkMode {
  /// Outbox + HTTP flush only.
  off,

  /// In-process mesh hub (desk/CI).
  simulated,

  /// Meshtastic PRIVATE_APP channel (BLE bridge required to send).
  meshtastic,

  /// MeshCore companion channel datagrams (BLE/USB bridge required to send).
  meshcore,

  /// In-process ham hub with tiny MTU (forces chunking).
  simulatedHam,

  /// Ham digimode modem stub (text framing helpers available).
  hamDigimode,
}

const radioMeshLinkModePrefsKey = 'wayfinder.radio_sync.meshLinkMode';

final radioMeshLinkModeProvider =
    StateNotifierProvider<RadioMeshLinkModeNotifier, RadioMeshLinkMode>(
      (ref) => RadioMeshLinkModeNotifier(),
    );

class RadioMeshLinkModeNotifier extends StateNotifier<RadioMeshLinkMode> {
  RadioMeshLinkModeNotifier() : super(RadioMeshLinkMode.off) {
    _load();
  }

  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(radioMeshLinkModePrefsKey);
      state = RadioMeshLinkMode.values.firstWhere(
        (mode) => mode.name == raw,
        orElse: () => RadioMeshLinkMode.off,
      );
    } catch (error, _) {
      _log.warn('Failed to load radio mesh link mode', error: error);
      state = RadioMeshLinkMode.off;
    }
  }

  Future<void> setMode(RadioMeshLinkMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(radioMeshLinkModePrefsKey, mode.name);
    } catch (error, _) {
      _log.warn('Failed to save radio mesh link mode', error: error);
    }
  }
}
