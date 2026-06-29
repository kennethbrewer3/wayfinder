import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/models/line_arrow_density.dart';
import 'track_transportation_mode.dart';

const trackZoneType = 'track';

class TrackPoint {
  const TrackPoint({
    required this.point,
    required this.recordedAt,
  });

  final LatLng point;
  final DateTime recordedAt;
}

class TrackGeometry {
  const TrackGeometry({
    required this.markerId,
    required this.points,
    this.showFootsteps = true,
    this.footstepDensity = const LineArrowDensity(LineArrowDensity.defaultLevel),
    this.transportationMode = TrackTransportationMode.onFoot,
  });

  final UuidValue markerId;
  final List<TrackPoint> points;
  final bool showFootsteps;
  final LineArrowDensity footstepDensity;
  final TrackTransportationMode transportationMode;

  bool get isValid => points.isNotEmpty;

  bool get hasRenderablePath => points.length >= 2;

  List<LatLng> get pathPoints => points.map((entry) => entry.point).toList();

  TrackGeometry copyWith({
    UuidValue? markerId,
    List<TrackPoint>? points,
    bool? showFootsteps,
    LineArrowDensity? footstepDensity,
    TrackTransportationMode? transportationMode,
  }) {
    return TrackGeometry(
      markerId: markerId ?? this.markerId,
      points: points ?? this.points,
      showFootsteps: showFootsteps ?? this.showFootsteps,
      footstepDensity: footstepDensity ?? this.footstepDensity,
      transportationMode: transportationMode ?? this.transportationMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'markerId': markerId.toString(),
      'points': [
        for (final entry in points)
          {
            'lat': entry.point.latitude,
            'lng': entry.point.longitude,
            'recordedAt': entry.recordedAt.toIso8601String(),
          },
      ],
      'showFootsteps': showFootsteps,
      if (showFootsteps)
        'footstepDensity': lineArrowDensityToStorage(footstepDensity),
      'transportationMode': transportationMode.toJson(),
    };
  }

  String encode() => jsonEncode(toJson());

  static TrackGeometry? fromZone(MapZone zone) {
    if (zone.type != trackZoneType) {
      return null;
    }
    return fromJsonString(zone.geometryJson);
  }

  static TrackGeometry? fromJsonString(String raw) {
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

  static TrackGeometry? fromJson(Map<String, dynamic> json) {
    final markerIdRaw = json['markerId'];
    if (markerIdRaw is! String) {
      return null;
    }
    final markerId = UuidValue.fromString(markerIdRaw);
    final rawPoints = json['points'];
    if (rawPoints is! List || rawPoints.isEmpty) {
      return null;
    }

    final points = <TrackPoint>[];
    for (final entry in rawPoints) {
      if (entry is! Map) {
        return null;
      }
      final lat = entry['lat'];
      final lng = entry['lng'];
      if (lat is! num || lng is! num) {
        return null;
      }
      final recordedAtRaw = entry['recordedAt'];
      final recordedAt = recordedAtRaw is String
          ? DateTime.tryParse(recordedAtRaw) ?? DateTime.now().toUtc()
          : DateTime.now().toUtc();
      points.add(
        TrackPoint(
          point: LatLng(lat.toDouble(), lng.toDouble()),
          recordedAt: recordedAt,
        ),
      );
    }

    return TrackGeometry(
      markerId: markerId,
      points: points,
      showFootsteps: json['showFootsteps'] != false,
      footstepDensity: lineArrowDensityFromStorage(
        json['footstepDensity'] as int?,
      ),
      transportationMode: TrackTransportationMode.fromJson(
        json['transportationMode'],
      ),
    );
  }
}

Future<void> applyTrackTransportationMode({
  required Future<MapZone?> Function(UuidValue id) getZone,
  required Future<MapZone> Function(MapZone zone) updateZone,
  required MapMarker marker,
  required TrackTransportationMode mode,
}) async {
  if (!marker.isTracking || marker.trackZoneId == null) {
    return;
  }

  final zone = await getZone(marker.trackZoneId!);
  if (zone == null) {
    return;
  }

  final geometry = TrackGeometry.fromZone(zone);
  if (geometry == null || geometry.transportationMode == mode) {
    return;
  }

  await updateZone(
    updateZoneTrackGeometry(
      zone,
      geometry.copyWith(transportationMode: mode),
    ).copyWith(updatedAt: DateTime.now().toUtc()),
  );
}

IconData trackIconForZone(MapZone zone) {
  if (zone.type != trackZoneType) {
    return Icons.layers;
  }
  final geometry = TrackGeometry.fromZone(zone);
  return trackTransportationIcon(
    geometry?.transportationMode ?? TrackTransportationMode.onFoot,
  );
}

MapZone updateZoneTrackGeometry(MapZone zone, TrackGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}

LatLng? trackZoneCenter(MapZone zone) {
  final geometry = TrackGeometry.fromZone(zone);
  if (geometry == null || geometry.points.isEmpty) {
    return null;
  }
  return geometry.points.last.point;
}
