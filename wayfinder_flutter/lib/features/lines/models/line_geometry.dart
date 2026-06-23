import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import 'line_arrow_density.dart';

const lineZoneType = 'line';

enum LinePathMode {
  straight,
  smooth,
}

LinePathMode linePathModeFromJson(String? value) {
  return value == 'straight' ? LinePathMode.straight : LinePathMode.smooth;
}

String linePathModeToJson(LinePathMode mode) => switch (mode) {
      LinePathMode.straight => 'straight',
      LinePathMode.smooth => 'smooth',
    };

class LineGeometry {
  const LineGeometry({
    required this.points,
    required this.showArrows,
    this.arrowDensity = const LineArrowDensity(LineArrowDensity.defaultLevel),
    this.pathMode = LinePathMode.straight,
    this.notes,
    this.showDistanceLabel = true,
    this.showNameLabel = false,
  });

  final List<LatLng> points;
  final bool showArrows;
  final LineArrowDensity arrowDensity;
  final LinePathMode pathMode;
  final String? notes;
  final bool showDistanceLabel;
  final bool showNameLabel;

  bool get isValid => points.length >= 2;

  bool get hasInteriorControlPoints => points.length > 2;

  LatLng? get start => points.isEmpty ? null : points.first;

  LatLng? get end => points.length < 2 ? null : points.last;

  LineGeometry copyWith({
    List<LatLng>? points,
    bool? showArrows,
    LineArrowDensity? arrowDensity,
    LinePathMode? pathMode,
    String? notes,
    bool? showDistanceLabel,
    bool? showNameLabel,
    bool clearNotes = false,
  }) {
    return LineGeometry(
      points: points ?? this.points,
      showArrows: showArrows ?? this.showArrows,
      arrowDensity: arrowDensity ?? this.arrowDensity,
      pathMode: pathMode ?? this.pathMode,
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
      if (showArrows) 'arrowDensity': lineArrowDensityToStorage(arrowDensity),
      'showDistanceLabel': showDistanceLabel,
      'showNameLabel': showNameLabel,
      if (pathMode != LinePathMode.straight)
        'pathMode': linePathModeToJson(pathMode),
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
      arrowDensity: lineArrowDensityFromStorage(json['arrowDensity'] as int?),
      pathMode: linePathModeFromJson(json['pathMode'] as String?),
      notes: json['notes'] as String?,
      showDistanceLabel: json['showDistanceLabel'] != false,
      showNameLabel: json['showNameLabel'] == true,
    );
  }
}

MapZone updateZoneLineGeometry(MapZone zone, LineGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}
