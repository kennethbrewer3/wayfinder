import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

const lineZoneType = 'line';

class LineGeometry {
  const LineGeometry({
    required this.points,
    required this.showArrows,
    this.notes,
    this.showDistanceLabel = true,
    this.showNameLabel = false,
  });

  final List<LatLng> points;
  final bool showArrows;
  final String? notes;
  final bool showDistanceLabel;
  final bool showNameLabel;

  bool get isValid => points.length >= 2;

  LatLng? get start => points.isEmpty ? null : points.first;

  LatLng? get end => points.length < 2 ? null : points.last;

  LineGeometry copyWith({
    List<LatLng>? points,
    bool? showArrows,
    String? notes,
    bool? showDistanceLabel,
    bool? showNameLabel,
    bool clearNotes = false,
  }) {
    return LineGeometry(
      points: points ?? this.points,
      showArrows: showArrows ?? this.showArrows,
      notes: clearNotes ? null : notes ?? this.notes,
      showDistanceLabel: showDistanceLabel ?? this.showDistanceLabel,
      showNameLabel: showNameLabel ?? this.showNameLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points
          .map(
            (point) => {
              'lat': point.latitude,
              'lng': point.longitude,
            },
          )
          .toList(),
      'showArrows': showArrows,
      'showDistanceLabel': showDistanceLabel,
      'showNameLabel': showNameLabel,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }

  String encode() => jsonEncode(toJson());

  static LineGeometry? fromZone(MapZone zone) {
    if (zone.type != lineZoneType) {
      return null;
    }
    return fromJsonString(zone.geometryJson);
  }

  static LineGeometry? fromJsonString(String raw) {
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

  static LineGeometry? fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    if (rawPoints is! List || rawPoints.length < 2) {
      return null;
    }

    final points = <LatLng>[];
    for (final entry in rawPoints) {
      if (entry is! Map) {
        return null;
      }
      final lat = entry['lat'];
      final lng = entry['lng'];
      if (lat is! num || lng is! num) {
        return null;
      }
      points.add(LatLng(lat.toDouble(), lng.toDouble()));
    }

    return LineGeometry(
      points: points,
      showArrows: json['showArrows'] == true,
      notes: json['notes'] as String?,
      showDistanceLabel: json['showDistanceLabel'] != false,
      showNameLabel: json['showNameLabel'] == true,
    );
  }
}

LatLng? lineZoneCenter(MapZone zone) {
  final geometry = LineGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return null;
  }
  final start = geometry.start!;
  final end = geometry.end!;
  return LatLng(
    (start.latitude + end.latitude) / 2,
    (start.longitude + end.longitude) / 2,
  );
}

MapZone updateZoneLineGeometry(MapZone zone, LineGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}
