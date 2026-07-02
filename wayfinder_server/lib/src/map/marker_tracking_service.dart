import 'dart:convert';
import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

const trackZoneType = 'track';
const defaultFootstepDensity = 3;
const defaultTransportationMode = 'onFoot';
const minTrackMoveMeters = 5.0;

abstract final class MarkerTrackingService {
  static Future<MapMarker> processMarkerUpdate({
    required Session session,
    required MapMarker? before,
    required MapMarker after,
  }) async {
    final wasTracking = before?.isTracking ?? false;
    final wantsTracking = after.isTracking;

    if (!wasTracking && wantsTracking) {
      return _enableTracking(session, after);
    }

    if (wasTracking && !wantsTracking) {
      return after.copyWith(isTracking: false);
    }

    if (wantsTracking && before != null) {
      await _appendTrackPointIfMoved(
        session: session,
        before: before,
        after: after,
      );
    } else if (wantsTracking && before == null) {
      await _appendTrackPointIfMoved(
        session: session,
        before: after,
        after: after,
        force: true,
      );
    }

    return after;
  }

  static Future<void> processMarkerDelete({
    required Session session,
    required MapMarker marker,
  }) async {
    final trackZoneId = marker.trackZoneId;
    if (trackZoneId == null) {
      return;
    }
    await MapZone.db.deleteWhere(
      session,
      where: (t) => t.id.equals(trackZoneId),
    );
  }

  static Future<MapMarker> _enableTracking(
    Session session,
    MapMarker marker,
  ) async {
    final now = DateTime.now().toUtc();
    if (marker.trackZoneId case final trackZoneId?) {
      final existing = await MapZone.db.findById(session, trackZoneId);
      if (existing != null && existing.type == trackZoneType) {
        await _appendTrackPointIfMoved(
          session: session,
          before: marker.copyWith(
            latitude: marker.latitude,
            longitude: marker.longitude,
            isTracking: false,
          ),
          after: marker,
          force: true,
        );
        return marker.copyWith(isTracking: true, trackZoneId: trackZoneId);
      }
    }

    final geometryJson = _encodeGeometry(
      markerId: marker.id,
      points: [
        _TrackPoint(
          latitude: marker.latitude,
          longitude: marker.longitude,
          recordedAt: now,
        ),
      ],
    );
    final zone = await MapZone.db.insertRow(
      session,
      MapZone(
        name: '${marker.name} track',
        type: trackZoneType,
        color: marker.color,
        borderColor: marker.color,
        borderPattern: 'solid',
        fillColor: marker.color,
        visible: true,
        geometryJson: geometryJson,
        layerId: marker.layerId,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return marker.copyWith(
      isTracking: true,
      trackZoneId: zone.id,
    );
  }

  static Future<void> _appendTrackPointIfMoved({
    required Session session,
    required MapMarker before,
    required MapMarker after,
    bool force = false,
  }) async {
    final trackZoneId = after.trackZoneId;
    if (!after.isTracking || trackZoneId == null) {
      return;
    }

    final movedMeters = _distanceMeters(
      before.latitude,
      before.longitude,
      after.latitude,
      after.longitude,
    );
    if (!force && movedMeters < minTrackMoveMeters) {
      return;
    }

    final zone = await MapZone.db.findById(session, trackZoneId);
    if (zone == null || zone.type != trackZoneType) {
      return;
    }

    final points = _decodePoints(zone.geometryJson);
    if (points.isNotEmpty) {
      final last = points.last;
      final deltaFromLast = _distanceMeters(
        last.latitude,
        last.longitude,
        after.latitude,
        after.longitude,
      );
      if (!force && deltaFromLast < minTrackMoveMeters) {
        return;
      }
    }

    points.add(
      _TrackPoint(
        latitude: after.latitude,
        longitude: after.longitude,
        recordedAt: DateTime.now().toUtc(),
      ),
    );

    await MapZone.db.updateRow(
      session,
      zone.copyWith(
        geometryJson: _encodeGeometry(
          markerId: after.id,
          points: points,
          showFootsteps: _decodeShowFootsteps(zone.geometryJson),
          footstepDensity: _decodeFootstepDensity(zone.geometryJson),
          transportationMode: _decodeTransportationMode(zone.geometryJson),
        ),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static String _encodeGeometry({
    required UuidValue markerId,
    required List<_TrackPoint> points,
    bool showFootsteps = true,
    int footstepDensity = defaultFootstepDensity,
    String transportationMode = defaultTransportationMode,
  }) {
    return jsonEncode({
      'markerId': markerId.toString(),
      'points': [
        for (final point in points)
          {
            'lat': point.latitude,
            'lng': point.longitude,
            'recordedAt': point.recordedAt.toIso8601String(),
          },
      ],
      'showFootsteps': showFootsteps,
      'footstepDensity': footstepDensity,
      'transportationMode': transportationMode,
    });
  }

  static List<_TrackPoint> _decodePoints(String geometryJson) {
    try {
      final json = jsonDecode(geometryJson);
      if (json is! Map<String, dynamic>) {
        return [];
      }
      final rawPoints = json['points'];
      if (rawPoints is! List) {
        return [];
      }
      final points = <_TrackPoint>[];
      for (final entry in rawPoints) {
        if (entry is! Map) {
          continue;
        }
        final lat = entry['lat'];
        final lng = entry['lng'];
        if (lat is! num || lng is! num) {
          continue;
        }
        final recordedAtRaw = entry['recordedAt'];
        final recordedAt = recordedAtRaw is String
            ? DateTime.tryParse(recordedAtRaw) ?? DateTime.now().toUtc()
            : DateTime.now().toUtc();
        points.add(
          _TrackPoint(
            latitude: lat.toDouble(),
            longitude: lng.toDouble(),
            recordedAt: recordedAt,
          ),
        );
      }
      return points;
    } catch (_) {
      return [];
    }
  }

  static bool _decodeShowFootsteps(String geometryJson) {
    try {
      final json = jsonDecode(geometryJson);
      if (json is Map<String, dynamic>) {
        return json['showFootsteps'] != false;
      }
    } catch (_) {}
    return true;
  }

  static int _decodeFootstepDensity(String geometryJson) {
    try {
      final json = jsonDecode(geometryJson);
      if (json is Map<String, dynamic>) {
        final density = json['footstepDensity'];
        if (density is int && density >= 1 && density <= 5) {
          return density;
        }
      }
    } catch (_) {}
    return defaultFootstepDensity;
  }

  static String _decodeTransportationMode(String geometryJson) {
    const allowed = {
      'onFoot',
      'horse',
      'bike',
      'motorcycle',
      'atv',
      'landVehicle',
      'truck',
      'bus',
      'rv',
      'train',
      'ambulance',
      'fireTruck',
      'farmVehicle',
      'canoe',
      'watercraft',
      'sailboat',
      'aircraft',
      'helicopter',
      'glider',
      'balloon',
    };
    try {
      final json = jsonDecode(geometryJson);
      if (json is Map<String, dynamic>) {
        final mode = json['transportationMode'];
        if (mode is String && allowed.contains(mode)) {
          return mode;
        }
      }
    } catch (_) {}
    return defaultTransportationMode;
  }

  static double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusMeters = 6371000.0;
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final deltaLon = (lon2 - lon1) * math.pi / 180;
    final centralAngle =
        math.sin(phi1) * math.sin(phi2) +
        math.cos(phi1) * math.cos(phi2) * math.cos(deltaLon);
    return earthRadiusMeters * math.acos(centralAngle.clamp(-1.0, 1.0));
  }
}

class _TrackPoint {
  const _TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;
}
