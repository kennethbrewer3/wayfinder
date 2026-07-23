import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';
import '../models/circle_size_display.dart';

final circleSizeDisplayProvider =
    StateNotifierProvider<CircleSizeDisplayNotifier, CircleSizeDisplay>(
      (ref) => CircleSizeDisplayNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class CircleSizeDisplayNotifier extends StateNotifier<CircleSizeDisplay> {
  CircleSizeDisplayNotifier(this._repository)
    : super(CircleSizeDisplay.radius) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.circleSizeDisplay;
    } catch (error, _) {
      _log.warn(
        '⭕ Failed to load circle size display from device preferences',
        error: error,
      );
      state = CircleSizeDisplay.radius;
    }
  }

  Future<void> setDisplay(CircleSizeDisplay display) async {
    state = display;
    try {
      await _repository.patch(
        (current) => current.copyWith(circleSizeDisplay: display),
      );
    } catch (error, _) {
      _log.warn(
        '⭕ Failed to save circle size display to device preferences',
        error: error,
      );
    }
  }
}
