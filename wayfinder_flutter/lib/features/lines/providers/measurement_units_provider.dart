import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../data/measurement_units_storage.dart';
import '../models/measurement_units.dart';

final measurementUnitsProvider =
    StateNotifierProvider<MeasurementUnitsNotifier, MeasurementUnits>(
  (ref) => MeasurementUnitsNotifier(
    ref.watch(appSettingsRepositoryProvider),
    MeasurementUnitsStorage(),
  ),
);

class MeasurementUnitsNotifier extends StateNotifier<MeasurementUnits> {
  MeasurementUnitsNotifier(this._repository, this._storage)
      : super(MeasurementUnits.metric) {
    _load();
  }

  final AppSettingsRepository _repository;
  final MeasurementUnitsStorage _storage;
  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.measurementUnits;
      await _storage.save(state);
      return;
    } catch (error, _) {
      _log.warn(
        '📏 Failed to load measurement units from server',
        error: error,
      );
    }
    state = await _storage.load();
  }

  Future<void> setUnits(MeasurementUnits units) async {
    state = units;
    await _storage.save(units);
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(measurementUnits: units),
      );
    } catch (error, _) {
      _log.warn(
        '📏 Failed to save measurement units to server',
        error: error,
      );
    }
  }
}
