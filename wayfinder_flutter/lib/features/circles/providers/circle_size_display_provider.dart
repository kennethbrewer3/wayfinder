import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../data/circle_size_display_storage.dart';
import '../models/circle_size_display.dart';

final circleSizeDisplayProvider =
    StateNotifierProvider<CircleSizeDisplayNotifier, CircleSizeDisplay>(
  (ref) => CircleSizeDisplayNotifier(
    ref.watch(appSettingsRepositoryProvider),
    CircleSizeDisplayStorage(),
  ),
);

class CircleSizeDisplayNotifier extends StateNotifier<CircleSizeDisplay> {
  CircleSizeDisplayNotifier(this._repository, this._storage)
      : super(CircleSizeDisplay.radius) {
    _load();
  }

  final AppSettingsRepository _repository;
  final CircleSizeDisplayStorage _storage;
  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.circleSizeDisplay;
      await _storage.save(state);
      return;
    } catch (error, _) {
      _log.warn(
        '⭕ Failed to load circle size display from server',
        error: error,
      );
    }
    state = await _storage.load();
  }

  Future<void> setDisplay(CircleSizeDisplay display) async {
    state = display;
    await _storage.save(display);
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
