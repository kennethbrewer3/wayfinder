import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../models/measurement_units.dart';

final measurementUnitsProvider =
    StateNotifierProvider<MeasurementUnitsNotifier, MeasurementUnits>(
      (ref) => MeasurementUnitsNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class MeasurementUnitsNotifier extends StateNotifier<MeasurementUnits> {
  MeasurementUnitsNotifier(this._repository)
    : super(MeasurementUnits.metric) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.measurementUnits;
    } catch (error, _) {
      _log.warn(
        '📏 Failed to load measurement units from server',
        error: error,
      );
      state = MeasurementUnits.metric;
    }
  }

  Future<void> setUnits(MeasurementUnits units) async {
    state = units;
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
