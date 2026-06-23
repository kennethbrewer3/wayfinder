import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/line_arrow_density.dart';

class LineArrowDensityStorage {
  Future<LineArrowDensity> load() async {
    final prefs = await SharedPreferences.getInstance();
    return lineArrowDensityFromStorage(
      prefs.getInt(AppConstants.lineArrowDensityStorageKey),
    );
  }

  Future<void> save(LineArrowDensity density) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      AppConstants.lineArrowDensityStorageKey,
      lineArrowDensityToStorage(density),
    );
  }
}
