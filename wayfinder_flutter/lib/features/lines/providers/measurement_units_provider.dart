import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/measurement_units_storage.dart';
import '../models/measurement_units.dart';

final measurementUnitsProvider =
    StateNotifierProvider<MeasurementUnitsNotifier, MeasurementUnits>(
  (ref) => MeasurementUnitsNotifier(MeasurementUnitsStorage()),
);

class MeasurementUnitsNotifier extends StateNotifier<MeasurementUnits> {
  MeasurementUnitsNotifier(this._storage) : super(MeasurementUnits.metric) {
    _load();
  }

  final MeasurementUnitsStorage _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setUnits(MeasurementUnits units) async {
    state = units;
    await _storage.save(units);
  }
}
