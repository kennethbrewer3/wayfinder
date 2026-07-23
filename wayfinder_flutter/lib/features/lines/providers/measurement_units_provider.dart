import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';
import '../models/measurement_units.dart';

final measurementUnitsProvider =
    StateNotifierProvider<MeasurementUnitsNotifier, MeasurementUnits>(
      (ref) => MeasurementUnitsNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class MeasurementUnitsNotifier extends StateNotifier<MeasurementUnits> {
  MeasurementUnitsNotifier(this._repository) : super(MeasurementUnits.metric) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.measurementUnits;
    } catch (error, _) {
      _log.warn(
        '📏 Failed to load measurement units from device preferences',
        error: error,
      );
      state = MeasurementUnits.metric;
    }
  }

  Future<void> setUnits(MeasurementUnits units) async {
    state = units;
    try {
      await _repository.patch(
        (current) => current.copyWith(measurementUnits: units),
      );
    } catch (error, _) {
      _log.warn(
        '📏 Failed to save measurement units to device preferences',
        error: error,
      );
    }
  }
}
