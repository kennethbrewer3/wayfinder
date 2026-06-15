import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../models/map_viewport.dart';

class MapViewportStorage {
  Future<MapViewport> loadViewport() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.viewportStorageKey);
    if (raw == null) {
      return const MapViewport(
        center: LatLng(
          AppConstants.defaultLatitude,
          AppConstants.defaultLongitude,
        ),
        zoom: AppConstants.defaultZoom,
      );
    }

    return MapViewport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveViewport(MapViewport viewport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.viewportStorageKey,
      jsonEncode(viewport.toJson()),
    );
  }
}
