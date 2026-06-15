import 'package:latlong2/latlong.dart';

class MapViewport {
  const MapViewport({
    required this.center,
    required this.zoom,
  });

  final LatLng center;
  final double zoom;

  MapViewport copyWith({
    LatLng? center,
    double? zoom,
  }) {
    return MapViewport(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': center.latitude,
        'lng': center.longitude,
        'zoom': zoom,
      };

  factory MapViewport.fromJson(Map<String, dynamic> json) {
    return MapViewport(
      center: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      zoom: (json['zoom'] as num).toDouble(),
    );
  }
}
