import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/map_marker_size.dart';

class MapMarkerSizeStorage {
  Future<double> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(AppConstants.mapMarkerSizeScaleStorageKey);
    if (stored == null) {
      return mapMarkerSizeScaleDefault;
    }
    return clampMapMarkerSizeScale(stored);
  }

  Future<void> save(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      AppConstants.mapMarkerSizeScaleStorageKey,
      clampMapMarkerSizeScale(scale),
    );
  }
}
