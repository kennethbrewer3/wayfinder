import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/measurement_units.dart';

class MeasurementUnitsStorage {
  Future<MeasurementUnits> load() async {
    final prefs = await SharedPreferences.getInstance();
    return measurementUnitsFromStorage(
      prefs.getString(AppConstants.measurementUnitsStorageKey),
    );
  }

  Future<void> save(MeasurementUnits units) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.measurementUnitsStorageKey,
      measurementUnitsToStorage(units),
    );
  }
}
