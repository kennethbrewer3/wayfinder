import 'dart:convert';
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../circles/models/circle_geometry.dart';
import '../../evac_kits/models/evac_kit_geometry.dart';
import '../../lines/models/line_geometry.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../codec/radio_event_codec.dart';
import '../models/evac_waypoint_air.dart';
import '../models/radio_domain_event.dart';
import 'radio_color_codec.dart';
import 'radio_icon_dictionary.dart';
import 'radio_uuid.dart';
import 'radio_zone_geometry_air.dart';

/// Maps between [RadioDomainEvent] and Serverpod / Flutter domain entities.
class RadioEntityMapper {
  const RadioEntityMapper();

  // --- Markers -------------------------------------------------------------

  RadioDomainEvent markerUpsertFrom(
    MapMarker marker, {
    String? eventId,
  }) {
    final notes = marker.notes;
    final truncated = notes != null && notes.length > RadioAirLimits.notes;
    return RadioDomainEvent.markerUpsert(
      eventId: eventId ?? const Uuid().v4(),
      entityId: marker.id.uuid,
      revisedAtSeconds: radioUtcToSeconds(marker.updatedAt),
      name: marker.name,
      latE7: _toE7(marker.latitude),
      lonE7: _toE7(marker.longitude),
      elevationMeters: marker.elevation.round(),
      colorRgb: radioColorRgbFromHex(marker.color),
      iconId: RadioIconDictionary.idForKey(marker.icon),
      visible: marker.visible,
      layerId: marker.layerId?.uuid,
      notes: notes,
      notesTruncated: truncated,
      isTracking: marker.isTracking,
    );
  }

  RadioDomainEvent markerDeleteFrom(
    UuidValue markerId, {
    required DateTime revisedAt,
    String? eventId,
  }) {
    return RadioDomainEvent.markerDelete(
      eventId: eventId ?? const Uuid().v4(),
      entityId: markerId.uuid,
      revisedAtSeconds: radioUtcToSeconds(revisedAt),
    );
  }

  /// Build a create payload, or merge radio fields onto [existing].
  MapMarker markerFromUpsert(
    MarkerUpsertEvent event, {
    MapMarker? existing,
  }) {
    final id = UuidValue.fromString(event.entityId);
    final revised = radioSecondsToUtc(event.revisedAtSeconds);
    if (existing == null) {
      return MapMarker(
        id: id,
        name: event.name,
        notes: event.notes,
        latitude: _fromE7(event.latE7),
        longitude: _fromE7(event.lonE7),
        elevation: event.elevationMeters.toDouble(),
        color: radioColorHexFromRgb(event.colorRgb),
        icon: RadioIconDictionary.keyForId(event.iconId),
        visible: event.visible,
        isTracking: event.isTracking,
        layerId: tryParseUuid(event.layerId),
        createdAt: revised,
        updatedAt: revised,
      );
    }
    return existing.copyWith(
      name: event.name,
      notes: event.notes,
      latitude: _fromE7(event.latE7),
      longitude: _fromE7(event.lonE7),
      elevation: event.elevationMeters.toDouble(),
      color: radioColorHexFromRgb(event.colorRgb),
      icon: RadioIconDictionary.keyForId(event.iconId),
      visible: event.visible,
      isTracking: event.isTracking,
      layerId: tryParseUuid(event.layerId),
      updatedAt: revised,
    );
  }

  // --- Watch log -----------------------------------------------------------

  RadioDomainEvent logAppendFrom(
    WatchLogEntry entry, {
    String? eventId,
  }) {
    final truncated = entry.text.length > RadioAirLimits.logText;
    return RadioDomainEvent.logAppend(
      eventId: eventId ?? const Uuid().v4(),
      entityId: entry.id.uuid,
      revisedAtSeconds: radioUtcToSeconds(entry.updatedAt),
      occurredAtSeconds: radioUtcToSeconds(entry.occurredAt),
      severity: _severityToAir(entry.severity),
      author: entry.author,
      text: entry.text,
      textTruncated: truncated,
      markerId: entry.markerId?.uuid,
      zoneId: entry.zoneId?.uuid,
    );
  }

  WatchLogEntry watchLogFromAppend(LogAppendEvent event) {
    final revised = radioSecondsToUtc(event.revisedAtSeconds);
    return WatchLogEntry(
      id: UuidValue.fromString(event.entityId),
      occurredAt: radioSecondsToUtc(event.occurredAtSeconds),
      author: event.author,
      severity: _severityFromAir(event.severity),
      text: event.text,
      markerId: tryParseUuid(event.markerId),
      zoneId: tryParseUuid(event.zoneId),
      createdAt: revised,
      updatedAt: revised,
    );
  }

  // --- Light zones (circle / line / polygon) -------------------------------

  RadioDomainEvent? zoneUpsertLightFromCircle(
    MapZone zone, {
    String? eventId,
  }) => zoneUpsertLightFrom(zone, eventId: eventId);

  /// Circle, line (≤16 pts), or polygon (≤16 pts). Returns `null` if unsupported.
  RadioDomainEvent? zoneUpsertLightFrom(
    MapZone zone, {
    String? eventId,
  }) {
    final Uint8List geometryBytes;
    final int zoneType;
    switch (zone.type) {
      case circleZoneType:
        final geometry = CircleGeometry.fromZone(zone);
        if (geometry == null || !geometry.isValid) {
          return null;
        }
        zoneType = RadioZoneTypeAir.circle;
        geometryBytes = encodeCircleGeometryAir(
          latE7: _toE7(geometry.center.latitude),
          lonE7: _toE7(geometry.center.longitude),
          radiusMeters: geometry.radiusMeters.round(),
        );
      case lineZoneType:
        final geometry = LineGeometry.fromZone(zone);
        if (geometry == null || !geometry.isValid) {
          return null;
        }
        zoneType = RadioZoneTypeAir.line;
        geometryBytes = encodePointsGeometryAir(
          kind: RadioZoneGeometryKind.polyline,
          points: latLngsToAirPoints(geometry.points),
        );
      case polygonZoneType:
        final geometry = PolygonGeometry.fromZone(zone);
        if (geometry == null || !geometry.isValid) {
          return null;
        }
        zoneType = RadioZoneTypeAir.polygon;
        geometryBytes = encodePointsGeometryAir(
          kind: RadioZoneGeometryKind.polygon,
          points: latLngsToAirPoints(geometry.points),
        );
      default:
        return null;
    }
    return RadioDomainEvent.zoneUpsertLight(
      eventId: eventId ?? const Uuid().v4(),
      entityId: zone.id.uuid,
      revisedAtSeconds: radioUtcToSeconds(zone.updatedAt),
      name: zone.name,
      zoneType: zoneType,
      colorRgb: radioColorRgbFromHex(zone.color),
      borderColorRgb: radioColorRgbFromHex(zone.borderColor),
      fillColorRgb: radioColorRgbFromHex(zone.fillColor),
      visible: zone.visible,
      layerId: zone.layerId?.uuid,
      geometryBytes: geometryBytes,
    );
  }

  MapZone? zoneFromUpsertLight(
    ZoneUpsertLightEvent event, {
    MapZone? existing,
  }) {
    final decoded = decodeZoneGeometryAir(event.geometryBytes);
    if (decoded == null) {
      return null;
    }
    final String geometryJson;
    final String type;
    switch (decoded) {
      case DecodedCircleGeometryAir(
        :final latE7,
        :final lonE7,
        :final radiusMeters,
      ):
        type = circleZoneType;
        geometryJson = CircleGeometry(
          center: LatLng(_fromE7(latE7), _fromE7(lonE7)),
          radiusMeters: radiusMeters.toDouble(),
        ).encode();
      case DecodedPointsGeometryAir(:final kind, :final points):
        final latLngs = airPointsToLatLngs(points);
        if (kind == RadioZoneGeometryKind.polygon) {
          if (latLngs.length < 3) {
            return null;
          }
          type = polygonZoneType;
          geometryJson = PolygonGeometry(points: latLngs).encode();
        } else {
          if (latLngs.length < 2) {
            return null;
          }
          type = lineZoneType;
          geometryJson = LineGeometry(
            points: latLngs,
            showArrows: true,
          ).encode();
        }
      default:
        return null;
    }
    final revised = radioSecondsToUtc(event.revisedAtSeconds);
    if (existing == null) {
      return MapZone(
        id: UuidValue.fromString(event.entityId),
        name: event.name,
        type: type,
        color: radioColorHexFromRgb(event.colorRgb),
        borderColor: radioColorHexFromRgb(event.borderColorRgb),
        borderPattern: 'solid',
        fillColor: radioColorHexFromRgb(event.fillColorRgb),
        visible: event.visible,
        geometryJson: geometryJson,
        layerId: tryParseUuid(event.layerId),
        createdAt: revised,
        updatedAt: revised,
      );
    }
    return existing.copyWith(
      name: event.name,
      type: type,
      color: radioColorHexFromRgb(event.colorRgb),
      borderColor: radioColorHexFromRgb(event.borderColorRgb),
      fillColor: radioColorHexFromRgb(event.fillColorRgb),
      visible: event.visible,
      geometryJson: geometryJson,
      layerId: tryParseUuid(event.layerId),
      updatedAt: revised,
    );
  }

  // --- Evac kits -----------------------------------------------------------

  RadioDomainEvent evacKitMetaFrom(
    MapZone zone,
    EvacKitGeometry geometry, {
    String? eventId,
  }) {
    final notes = geometry.notes;
    final truncated = notes != null && notes.length > RadioAirLimits.notes;
    // Air format requires a 16-byte UUID; legacy `route_*` ids are hashed.
    final primaryId = isUuidString(geometry.primaryRouteId)
        ? geometry.primaryRouteId
        : _stableUuidFor(
            'wayfinder.evac.primary/${zone.id.uuid}/${geometry.primaryRouteId}',
          );
    return RadioDomainEvent.evacKitMetaUpsert(
      eventId: eventId ?? const Uuid().v4(),
      entityId: zone.id.uuid,
      revisedAtSeconds: radioUtcToSeconds(zone.updatedAt),
      name: zone.name,
      colorRgb: radioColorRgbFromHex(zone.color),
      borderColorRgb: radioColorRgbFromHex(zone.borderColor),
      fillColorRgb: radioColorRgbFromHex(zone.fillColor),
      visible: zone.visible,
      layerId: zone.layerId?.uuid,
      primaryRouteId: primaryId,
      defaultMode: geometry.defaultMode.index.clamp(0, 255),
      showNameLabel: geometry.showNameLabel,
      notes: notes,
      notesTruncated: truncated,
    );
  }

  /// Returns `null` when [route.id] is not a UUID (cannot go on air as-is).
  RadioDomainEvent? evacRouteUpsertFrom({
    required MapZone kitZone,
    required EvacRoute route,
    String? eventId,
  }) {
    if (!isUuidString(route.id)) {
      return null;
    }
    final waypoints = <EvacWaypointAir>[
      for (final wp in route.waypoints.take(RadioAirLimits.maxWaypoints))
        EvacWaypointAir(
          kind: switch (wp.kind) {
            EvacWaypointKind.marker => EvacWaypointAirKind.marker,
            EvacWaypointKind.control => EvacWaypointAirKind.control,
            EvacWaypointKind.point => EvacWaypointAirKind.point,
          },
          latE7: _toE7(wp.point.latitude),
          lonE7: _toE7(wp.point.longitude),
          markerId: isUuidString(wp.markerId) ? wp.markerId : null,
          label: wp.label,
        ),
    ];
    if (waypoints.length < 2) {
      return null;
    }
    return RadioDomainEvent.evacRouteUpsert(
      eventId: eventId ?? const Uuid().v4(),
      entityId: kitZone.id.uuid,
      revisedAtSeconds: radioUtcToSeconds(kitZone.updatedAt),
      routeId: route.id,
      name: route.name,
      role: route.role == EvacRouteRole.alternate
          ? EvacRouteAirRole.alternate
          : EvacRouteAirRole.primary,
      colorRgb: route.color == null ? null : radioColorRgbFromHex(route.color!),
      borderPattern: route.borderPattern == 'dashed' ? 1 : 0,
      showArrows: route.showArrows,
      pathMode: route.pathMode == LinePathMode.smooth ? 1 : 0,
      waypoints: waypoints,
    );
  }

  RadioDomainEvent? evacRouteDeleteFrom({
    required MapZone kitZone,
    required String routeId,
    String? eventId,
  }) {
    if (!isUuidString(routeId)) {
      return null;
    }
    return RadioDomainEvent.evacRouteDelete(
      eventId: eventId ?? const Uuid().v4(),
      entityId: kitZone.id.uuid,
      revisedAtSeconds: radioUtcToSeconds(kitZone.updatedAt),
      routeId: routeId,
    );
  }

  RadioDomainEvent evacKitDeleteFrom(
    UuidValue kitId, {
    required DateTime revisedAt,
    String? eventId,
  }) {
    return RadioDomainEvent.evacKitDelete(
      eventId: eventId ?? const Uuid().v4(),
      entityId: kitId.uuid,
      revisedAtSeconds: radioUtcToSeconds(revisedAt),
    );
  }

  /// Apply meta onto an existing kit zone, or create a shell kit.
  MapZone applyEvacKitMeta(
    EvacKitMetaUpsertEvent event, {
    MapZone? existing,
  }) {
    final revised = radioSecondsToUtc(event.revisedAtSeconds);
    final modes = TrackTransportationMode.values;
    final mode = event.defaultMode >= 0 && event.defaultMode < modes.length
        ? modes[event.defaultMode]
        : TrackTransportationMode.onFoot;

    EvacKitGeometry geometry;
    if (existing != null) {
      final current =
          EvacKitGeometry.fromZone(existing) ??
          EvacKitGeometry(
            routes: const [],
            primaryRouteId: event.primaryRouteId,
          );
      geometry = current.copyWith(
        primaryRouteId: event.primaryRouteId,
        defaultMode: mode,
        notes: event.notes,
        showNameLabel: event.showNameLabel,
        clearNotes: event.notes == null || event.notes!.isEmpty,
      );
    } else {
      geometry = EvacKitGeometry(
        routes: const [],
        primaryRouteId: event.primaryRouteId,
        defaultMode: mode,
        notes: event.notes,
        showNameLabel: event.showNameLabel,
      );
    }

    final geometryJson = jsonEncode({
      'primaryRouteId': geometry.primaryRouteId,
      'defaultMode': geometry.defaultMode.toJson(),
      'showNameLabel': geometry.showNameLabel,
      'routes': [for (final route in geometry.routes) route.toJson()],
      if (geometry.notes != null && geometry.notes!.trim().isNotEmpty)
        'notes': geometry.notes,
    });

    if (existing == null) {
      return MapZone(
        id: UuidValue.fromString(event.entityId),
        name: event.name,
        type: evacKitZoneType,
        color: radioColorHexFromRgb(event.colorRgb),
        borderColor: radioColorHexFromRgb(event.borderColorRgb),
        borderPattern: 'solid',
        fillColor: radioColorHexFromRgb(event.fillColorRgb),
        visible: event.visible,
        geometryJson: geometryJson,
        layerId: tryParseUuid(event.layerId),
        createdAt: revised,
        updatedAt: revised,
      );
    }
    return existing.copyWith(
      name: event.name,
      color: radioColorHexFromRgb(event.colorRgb),
      borderColor: radioColorHexFromRgb(event.borderColorRgb),
      fillColor: radioColorHexFromRgb(event.fillColorRgb),
      visible: event.visible,
      geometryJson: geometryJson,
      layerId: tryParseUuid(event.layerId),
      updatedAt: revised,
    );
  }

  MapZone? applyEvacRouteUpsert(
    EvacRouteUpsertEvent event, {
    required MapZone kitZone,
  }) {
    final current =
        EvacKitGeometry.fromZone(kitZone) ??
        EvacKitGeometry(routes: const [], primaryRouteId: event.routeId);
    final route = EvacRoute(
      id: event.routeId,
      name: event.name,
      role: event.role == EvacRouteAirRole.alternate
          ? EvacRouteRole.alternate
          : EvacRouteRole.primary,
      waypoints: [
        for (final wp in event.waypoints)
          EvacWaypoint(
            kind: switch (wp.kind) {
              EvacWaypointAirKind.marker =>
                isUuidString(wp.markerId)
                    ? EvacWaypointKind.marker
                    : EvacWaypointKind.point,
              EvacWaypointAirKind.control => EvacWaypointKind.control,
              _ => EvacWaypointKind.point,
            },
            point: LatLng(_fromE7(wp.latE7), _fromE7(wp.lonE7)),
            markerId: wp.markerId,
            label: wp.label,
          ),
      ],
      color: event.colorRgb == null
          ? null
          : radioColorHexFromRgb(event.colorRgb!),
      borderPattern: event.borderPattern == 1 ? 'dashed' : 'solid',
      showArrows: event.showArrows,
      pathMode: event.pathMode == 1
          ? LinePathMode.smooth
          : LinePathMode.straight,
    );
    if (!route.isValid) {
      return null;
    }
    final next = current.withRoute(route);
    return updateZoneEvacKitGeometry(kitZone, next).copyWith(
      updatedAt: radioSecondsToUtc(event.revisedAtSeconds),
    );
  }

  MapZone? applyEvacRouteDelete(
    EvacRouteDeleteEvent event, {
    required MapZone kitZone,
  }) {
    final current = EvacKitGeometry.fromZone(kitZone);
    if (current == null) {
      return null;
    }
    final next = current.withoutRoute(event.routeId);
    if (next == null) {
      return null;
    }
    return updateZoneEvacKitGeometry(kitZone, next).copyWith(
      updatedAt: radioSecondsToUtc(event.revisedAtSeconds),
    );
  }

  // --- Helpers -------------------------------------------------------------

  static int _toE7(double degrees) => (degrees * 1e7).round();

  static double _fromE7(int e7) => e7 / 1e7;

  static int _severityToAir(String severity) => switch (severity) {
    'notice' => RadioLogSeverity.notice,
    'warning' => RadioLogSeverity.warning,
    'critical' => RadioLogSeverity.critical,
    _ => RadioLogSeverity.info,
  };

  static String _severityFromAir(int severity) => switch (severity) {
    RadioLogSeverity.notice => 'notice',
    RadioLogSeverity.warning => 'warning',
    RadioLogSeverity.critical => 'critical',
    _ => 'info',
  };

  /// Deterministic UUID-shaped id for legacy non-UUID route ids.
  static String _stableUuidFor(String name) {
    final input = utf8.encode(name);
    final bytes = Uint8List(16);
    var state = 2166136261;
    for (var i = 0; i < input.length; i++) {
      state ^= input[i];
      state = (state * 16777619) & 0xffffffff;
      bytes[i % 16] ^= (state >> ((i % 4) * 8)) & 0xff;
    }
    // Version 5 / RFC variant bits.
    bytes[6] = (bytes[6] & 0x0f) | 0x50;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = [
      for (final b in bytes) b.toRadixString(16).padLeft(2, '0'),
    ].join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
