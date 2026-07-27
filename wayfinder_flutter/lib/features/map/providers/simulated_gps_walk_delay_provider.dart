import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';

const simulatedGpsWalkDelayMsPrefsKey = 'wayfinder.simulatedGpsWalkDelayMs';

/// Fastest step interval for desk GPS simulation (milliseconds).
const simulatedGpsWalkDelayMsMin = 500;

/// Slowest step interval for desk GPS simulation (milliseconds).
const simulatedGpsWalkDelayMsMax = 5000;

/// Default step interval (~readable HUD updates).
const simulatedGpsWalkDelayMsDefault = 2000;

/// Slider snap size.
const simulatedGpsWalkDelayMsStep = 500;

int clampSimulatedGpsWalkDelayMs(int milliseconds) {
  final stepped =
      ((milliseconds / simulatedGpsWalkDelayMsStep).round() *
              simulatedGpsWalkDelayMsStep)
          .clamp(simulatedGpsWalkDelayMsMin, simulatedGpsWalkDelayMsMax);
  return stepped;
}

/// Device-local delay between fake GPS steps during route-follow simulation.
final simulatedGpsWalkDelayMsProvider =
    StateNotifierProvider<SimulatedGpsWalkDelayNotifier, int>(
      (ref) => SimulatedGpsWalkDelayNotifier(),
    );

class SimulatedGpsWalkDelayNotifier extends StateNotifier<int> {
  SimulatedGpsWalkDelayNotifier() : super(simulatedGpsWalkDelayMsDefault) {
    _load();
  }

  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw =
          prefs.getInt(simulatedGpsWalkDelayMsPrefsKey) ??
          simulatedGpsWalkDelayMsDefault;
      state = clampSimulatedGpsWalkDelayMs(raw);
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load simulated GPS walk delay preference',
        error: error,
      );
      state = simulatedGpsWalkDelayMsDefault;
    }
  }

  Future<void> setDelayMs(int milliseconds) async {
    final next = clampSimulatedGpsWalkDelayMs(milliseconds);
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(simulatedGpsWalkDelayMsPrefsKey, next);
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save simulated GPS walk delay preference',
        error: error,
      );
    }
  }
}
