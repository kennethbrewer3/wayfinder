import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/marker_color.dart';

class MarkerIconBackgroundColorStorage {
  static const defaultHex = '#FFFFFF';

  Future<Color> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.markerIconBackgroundColorStorageKey);
    if (stored == null || stored.isEmpty) {
      return parseMarkerColor(defaultHex);
    }
    return parseMarkerColor(stored);
  }

  Future<void> save(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.markerIconBackgroundColorStorageKey,
      formatMarkerColorHexWithAlpha(color),
    );
  }
}
