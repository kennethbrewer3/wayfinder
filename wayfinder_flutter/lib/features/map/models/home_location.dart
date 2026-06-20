import 'package:latlong2/latlong.dart';

import '../../../core/constants.dart';
import 'map_viewport.dart';

class HomeLocation {
  const HomeLocation({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  final double latitude;
  final double longitude;
  final double zoom;

  static const defaults = HomeLocation(
    latitude: AppConstants.defaultLatitude,
    longitude: AppConstants.defaultLongitude,
    zoom: AppConstants.defaultZoom,
  );

  LatLng get center => LatLng(latitude, longitude);

  MapViewport toViewport() => MapViewport(center: center, zoom: zoom);

  HomeLocation copyWith({
    double? latitude,
    double? longitude,
    double? zoom,
  }) {
    return HomeLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'zoom': zoom,
      };

  factory HomeLocation.fromJson(Map<String, dynamic> json) {
    return HomeLocation(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      zoom: (json['zoom'] as num).toDouble(),
    );
  }

  static HomeLocation? tryParse({
    required String latitudeText,
    required String longitudeText,
    required String zoomText,
  }) {
    final latitude = double.tryParse(latitudeText.trim());
    final longitude = double.tryParse(longitudeText.trim());
    final zoom = double.tryParse(zoomText.trim());
    if (latitude == null || longitude == null || zoom == null) {
      return null;
    }
    if (latitude < -90 || latitude > 90) {
      throw const FormatException('Latitude must be between -90 and 90.');
    }
    if (longitude < -180 || longitude > 180) {
      throw const FormatException('Longitude must be between -180 and 180.');
    }
    if (zoom < 0 || zoom > AppConstants.maxMapZoom) {
      throw FormatException(
        'Zoom must be between 0 and ${AppConstants.maxMapZoom}.',
      );
    }
    return HomeLocation(
      latitude: latitude,
      longitude: longitude,
      zoom: zoom,
    );
  }
}
