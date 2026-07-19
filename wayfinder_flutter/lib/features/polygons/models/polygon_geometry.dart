import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

const polygonZoneType = 'polygon';

class PolygonGeometry {
  const PolygonGeometry({
    required this.points,
    this.notes,
    this.showNameLabel = false,
  });

  final List<LatLng> points;
  final String? notes;
  final bool showNameLabel;

  bool get isValid => points.length >= 3;

  /// Approximate label / zoom anchor (vertex average).
  LatLng get labelPoint {
    var lat = 0.0;
    var lng = 0.0;
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    final n = points.length;
    return LatLng(lat / n, lng / n);
  }

  PolygonGeometry copyWith({
    List<LatLng>? points,
    String? notes,
    bool? showNameLabel,
    bool clearNotes = false,
  }) {
    return PolygonGeometry(
      points: points ?? this.points,
      notes: clearNotes ? null : notes ?? this.notes,
      showNameLabel: showNameLabel ?? this.showNameLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': [
        for (final point in points)
          {
            'lat': point.latitude,
            'lng': point.longitude,
          },
      ],
      'showNameLabel': showNameLabel,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }

  String encode() => jsonEncode(toJson());

  static PolygonGeometry? fromZone(MapZone zone) {
    if (zone.type != polygonZoneType) {
      return null;
    }
    return fromJsonString(zone.geometryJson);
  }

  static PolygonGeometry? fromJsonString(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return null;
      }
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static PolygonGeometry? fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    if (rawPoints is! List) {
      return null;
    }
    final points = <LatLng>[];
    for (final entry in rawPoints) {
      final point = _parseLatLng(entry);
      if (point == null) {
        return null;
      }
      points.add(point);
    }
    if (points.length < 3) {
      return null;
    }
    return PolygonGeometry(
      points: points,
      notes: json['notes'] as String?,
      showNameLabel: json['showNameLabel'] == true,
    );
  }

  static LatLng? _parseLatLng(Object? value) {
    if (value is! Map) {
      return null;
    }
    final lat = value['lat'];
    final lng = value['lng'];
    if (lat is! num || lng is! num) {
      return null;
    }
    return LatLng(lat.toDouble(), lng.toDouble());
  }
}

LatLng? polygonZoneCenter(MapZone zone) {
  return PolygonGeometry.fromZone(zone)?.labelPoint;
}

MapZone updateZonePolygonGeometry(MapZone zone, PolygonGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}
