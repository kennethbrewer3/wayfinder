import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/circle_size_display.dart';

const circleZoneType = 'circle';
const defaultCircleRadiusLineBearing = 90.0;

class CircleGeometry {
  const CircleGeometry({
    required this.center,
    required this.radiusMeters,
    this.radiusLineBearing = defaultCircleRadiusLineBearing,
    this.notes,
    this.sizeDisplay = CircleSizeDisplay.radius,
    this.showNameLabel = false,
  });

  final LatLng center;
  final double radiusMeters;
  final double radiusLineBearing;
  final String? notes;
  final CircleSizeDisplay sizeDisplay;
  final bool showNameLabel;

  bool get isValid => radiusMeters >= 1;

  CircleGeometry copyWith({
    LatLng? center,
    double? radiusMeters,
    double? radiusLineBearing,
    String? notes,
    CircleSizeDisplay? sizeDisplay,
    bool? showNameLabel,
    bool clearNotes = false,
  }) {
    return CircleGeometry(
      center: center ?? this.center,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      radiusLineBearing: radiusLineBearing ?? this.radiusLineBearing,
      notes: clearNotes ? null : notes ?? this.notes,
      sizeDisplay: sizeDisplay ?? this.sizeDisplay,
      showNameLabel: showNameLabel ?? this.showNameLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center': {
        'lat': center.latitude,
        'lng': center.longitude,
      },
      'radiusMeters': radiusMeters,
      'radiusLineBearing': radiusLineBearing,
      'sizeDisplay': circleSizeDisplayToStorage(sizeDisplay),
      'showNameLabel': showNameLabel,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }

  String encode() => jsonEncode(toJson());

  static CircleGeometry? fromZone(MapZone zone) {
    if (zone.type != circleZoneType) {
      return null;
    }
    return fromJsonString(zone.geometryJson);
  }

  static CircleGeometry? fromJsonString(String raw) {
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

  static CircleGeometry? fromJson(Map<String, dynamic> json) {
    final center = _parseLatLng(json['center']);
    if (center == null) {
      return null;
    }

    final radius = json['radiusMeters'] ?? json['radius'];
    if (radius is! num || radius <= 0) {
      return null;
    }

    final bearing = json['radiusLineBearing'];
    return CircleGeometry(
      center: center,
      radiusMeters: radius.toDouble(),
      radiusLineBearing:
          bearing is num ? bearing.toDouble() : defaultCircleRadiusLineBearing,
      notes: json['notes'] as String?,
      sizeDisplay: _parseSizeDisplay(json),
      showNameLabel: json['showNameLabel'] == true,
    );
  }

  static CircleSizeDisplay _parseSizeDisplay(Map<String, dynamic> json) {
    final raw = json['sizeDisplay'];
    if (raw is String) {
      return circleSizeDisplayFromJson(raw);
    }
    if (json['showSizeLabel'] == false) {
      return CircleSizeDisplay.none;
    }
    return CircleSizeDisplay.radius;
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

LatLng? circleZoneCenter(MapZone zone) {
  return CircleGeometry.fromZone(zone)?.center;
}

MapZone updateZoneCircleGeometry(MapZone zone, CircleGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}
