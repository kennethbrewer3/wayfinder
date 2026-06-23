import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../data/line_arrow_density_storage.dart';
import '../models/line_arrow_density.dart';

final lineArrowDensityProvider =
    StateNotifierProvider<LineArrowDensityNotifier, LineArrowDensity>(
  (ref) => LineArrowDensityNotifier(
    ref.watch(appSettingsRepositoryProvider),
    LineArrowDensityStorage(),
  ),
);

class LineArrowDensityNotifier extends StateNotifier<LineArrowDensity> {
  LineArrowDensityNotifier(this._repository, this._storage)
      : super(const LineArrowDensity(LineArrowDensity.defaultLevel)) {
    _load();
  }

  final AppSettingsRepository _repository;
  final LineArrowDensityStorage _storage;
  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.lineArrowDensity;
      await _storage.save(state);
      return;
    } catch (error, _) {
      _log.warn(
        '➡️ Failed to load line arrow density from server',
        error: error,
      );
    }
    state = await _storage.load();
  }

  Future<void> setDensity(LineArrowDensity density) async {
    state = density;
    await _storage.save(density);
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(lineArrowDensity: density),
      );
    } catch (error, _) {
      _log.warn(
        '➡️ Failed to save line arrow density to server',
        error: error,
      );
    }
  }
}
