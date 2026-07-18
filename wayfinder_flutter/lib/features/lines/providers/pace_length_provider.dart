import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dead_reckoning_provider.dart';

const _paceLengthStorageKey = 'wayfinder.paceLengthMeters';

/// Preferred pace length in meters (device-local, offline).
final paceLengthProvider =
    StateNotifierProvider<PaceLengthNotifier, double>(
      (ref) => PaceLengthNotifier()..load(),
    );

class PaceLengthNotifier extends StateNotifier<double> {
  PaceLengthNotifier() : super(defaultPaceLengthMeters);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_paceLengthStorageKey);
    if (stored != null && stored > 0) {
      state = stored;
    }
  }

  Future<void> setPaceLengthMeters(double meters) async {
    if (meters <= 0) {
      return;
    }
    state = meters;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_paceLengthStorageKey, meters);
  }
}
