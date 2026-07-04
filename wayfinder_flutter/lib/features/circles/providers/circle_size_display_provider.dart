import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../models/circle_size_display.dart';

final circleSizeDisplayProvider =
    StateNotifierProvider<CircleSizeDisplayNotifier, CircleSizeDisplay>(
      (ref) => CircleSizeDisplayNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class CircleSizeDisplayNotifier extends StateNotifier<CircleSizeDisplay> {
  CircleSizeDisplayNotifier(this._repository)
    : super(CircleSizeDisplay.radius) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.circleSizeDisplay;
    } catch (error, _) {
      _log.warn(
        '⭕ Failed to load circle size display from server',
        error: error,
      );
      state = CircleSizeDisplay.radius;
    }
  }

  Future<void> setDisplay(CircleSizeDisplay display) async {
    state = display;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(circleSizeDisplay: display),
      );
    } catch (error, _) {
      _log.warn(
        '⭕ Failed to save circle size display to server',
        error: error,
      );
    }
  }
}
