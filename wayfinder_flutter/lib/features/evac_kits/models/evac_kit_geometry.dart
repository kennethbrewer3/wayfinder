import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/models/line_geometry.dart';
import '../../lines/utils/line_path.dart';
import '../../tracks/models/track_transportation_mode.dart';

const evacKitZoneType = 'evac_kit';

enum EvacRouteRole {
  primary,
  alternate;

  String toJson() => name;

  static EvacRouteRole fromJson(Object? raw) {
    return switch (raw) {
      'alternate' => EvacRouteRole.alternate,
      _ => EvacRouteRole.primary,
    };
  }
}

enum EvacWaypointKind {
  marker,
  point;

  String toJson() => name;

  static EvacWaypointKind fromJson(Object? raw) {
    return switch (raw) {
      'marker' => EvacWaypointKind.marker,
      _ => EvacWaypointKind.point,
    };
  }
}

class EvacWaypoint {
  const EvacWaypoint({
    required this.kind,
    required this.point,
    this.markerId,
    this.label,
  });

  final EvacWaypointKind kind;
  final LatLng point;
  final String? markerId;
  final String? label;

  EvacWaypoint copyWith({
    EvacWaypointKind? kind,
    LatLng? point,
    String? markerId,
    String? label,
    bool clearMarkerId = false,
    bool clearLabel = false,
  }) {
    return EvacWaypoint(
      kind: kind ?? this.kind,
      point: point ?? this.point,
      markerId: clearMarkerId ? null : markerId ?? this.markerId,
      label: clearLabel ? null : label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind.toJson(),
    'lat': point.latitude,
    'lng': point.longitude,
    if (markerId != null) 'markerId': markerId,
    if (label != null && label!.trim().isNotEmpty) 'label': label,
  };

  static EvacWaypoint? fromJson(Map<String, dynamic> json) {
    final lat = json['lat'];
    final lng = json['lng'];
    if (lat is! num || lng is! num) {
      return null;
    }
    final kind = EvacWaypointKind.fromJson(json['kind']);
    final markerId = json['markerId']?.toString();
    if (kind == EvacWaypointKind.marker &&
        (markerId == null || markerId.isEmpty)) {
      // Degrade to a free point if marker id is missing.
      return EvacWaypoint(
        kind: EvacWaypointKind.point,
        point: LatLng(lat.toDouble(), lng.toDouble()),
        label: json['label'] as String?,
      );
    }
    return EvacWaypoint(
      kind: kind,
      point: LatLng(lat.toDouble(), lng.toDouble()),
      markerId: markerId,
      label: json['label'] as String?,
    );
  }
}

class EvacRoute {
  const EvacRoute({
    required this.id,
    required this.name,
    required this.role,
    required this.waypoints,
    this.color,
    this.borderPattern = 'solid',
    this.showArrows = true,
    this.pathMode = LinePathMode.straight,
  });

  final String id;
  final String name;
  final EvacRouteRole role;
  final List<EvacWaypoint> waypoints;
  final String? color;
  final String borderPattern;
  final bool showArrows;
  final LinePathMode pathMode;

  bool get isValid => waypoints.length >= 2;

  List<LatLng> get pathPoints => [
    for (final waypoint in waypoints) waypoint.point,
  ];

  EvacRoute copyWith({
    String? id,
    String? name,
    EvacRouteRole? role,
    List<EvacWaypoint>? waypoints,
    String? color,
    String? borderPattern,
    bool? showArrows,
    LinePathMode? pathMode,
    bool clearColor = false,
  }) {
    return EvacRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      waypoints: waypoints ?? this.waypoints,
      color: clearColor ? null : color ?? this.color,
      borderPattern: borderPattern ?? this.borderPattern,
      showArrows: showArrows ?? this.showArrows,
      pathMode: pathMode ?? this.pathMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.toJson(),
    'waypoints': [
      for (final waypoint in waypoints) waypoint.toJson(),
    ],
    if (color != null) 'color': color,
    'borderPattern': borderPattern,
    'showArrows': showArrows,
    if (pathMode != LinePathMode.straight)
      'pathMode': linePathModeToJson(pathMode),
  };

  static EvacRoute? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final name = json['name']?.toString();
    final waypointsRaw = json['waypoints'];
    if (id == null ||
        id.isEmpty ||
        name == null ||
        name.isEmpty ||
        waypointsRaw is! List) {
      return null;
    }
    final waypoints = <EvacWaypoint>[];
    for (final entry in waypointsRaw) {
      if (entry is Map<String, dynamic>) {
        final waypoint = EvacWaypoint.fromJson(entry);
        if (waypoint != null) {
          waypoints.add(waypoint);
        }
      } else if (entry is Map) {
        final waypoint = EvacWaypoint.fromJson(
          Map<String, dynamic>.from(entry),
        );
        if (waypoint != null) {
          waypoints.add(waypoint);
        }
      }
    }
    if (waypoints.length < 2) {
      return null;
    }
    final pathModeRaw = json['pathMode']?.toString();
    return EvacRoute(
      id: id,
      name: name,
      role: EvacRouteRole.fromJson(json['role']),
      waypoints: waypoints,
      color: json['color'] as String?,
      borderPattern: json['borderPattern'] is String
          ? json['borderPattern'] as String
          : 'solid',
      showArrows: json['showArrows'] != false,
      pathMode: pathModeRaw == 'smooth'
          ? LinePathMode.smooth
          : LinePathMode.straight,
    );
  }
}

class EvacKitGeometry {
  const EvacKitGeometry({
    required this.routes,
    required this.primaryRouteId,
    this.defaultMode = TrackTransportationMode.onFoot,
    this.notes,
    this.showNameLabel = true,
  });

  final List<EvacRoute> routes;
  final String primaryRouteId;
  final TrackTransportationMode defaultMode;
  final String? notes;
  final bool showNameLabel;

  bool get isValid =>
      routes.isNotEmpty &&
      routes.any((route) => route.id == primaryRouteId && route.isValid);

  EvacRoute? get primaryRoute {
    for (final route in routes) {
      if (route.id == primaryRouteId) {
        return route;
      }
    }
    return routes.isEmpty ? null : routes.first;
  }

  /// First waypoint of the primary route — shared origin for alternates.
  EvacWaypoint? get primaryOriginWaypoint {
    final primary = primaryRoute;
    if (primary == null || primary.waypoints.isEmpty) {
      return null;
    }
    return primary.waypoints.first;
  }

  List<EvacRoute> get alternateRoutes => [
    for (final route in routes)
      if (route.id != primaryRouteId) route,
  ];

  /// Midpoint of the primary route for zoom / labels.
  LatLng? get labelPoint {
    final primary = primaryRoute;
    if (primary == null || !primary.isValid) {
      return null;
    }
    return linePathMidpoint(
      LineGeometry(
        points: primary.pathPoints,
        showArrows: false,
        pathMode: primary.pathMode,
      ),
    );
  }

  EvacKitGeometry copyWith({
    List<EvacRoute>? routes,
    String? primaryRouteId,
    TrackTransportationMode? defaultMode,
    String? notes,
    bool? showNameLabel,
    bool clearNotes = false,
  }) {
    return EvacKitGeometry(
      routes: routes ?? this.routes,
      primaryRouteId: primaryRouteId ?? this.primaryRouteId,
      defaultMode: defaultMode ?? this.defaultMode,
      notes: clearNotes ? null : notes ?? this.notes,
      showNameLabel: showNameLabel ?? this.showNameLabel,
    );
  }

  EvacKitGeometry withRoute(EvacRoute route) {
    final next = [...routes];
    final index = next.indexWhere((entry) => entry.id == route.id);
    if (index >= 0) {
      next[index] = route;
    } else {
      next.add(route);
    }
    return copyWith(routes: next);
  }

  /// Promotes [routeId] to primary; former primary becomes an alternate.
  EvacKitGeometry withPrimaryRoute(String routeId) {
    if (!routes.any((route) => route.id == routeId)) {
      return this;
    }
    if (routeId == primaryRouteId) {
      return this;
    }
    final updatedRoutes = [
      for (final route in routes)
        if (route.id == routeId)
          route.copyWith(
            role: EvacRouteRole.primary,
            borderPattern: 'solid',
          )
        else if (route.id == primaryRouteId)
          route.copyWith(
            role: EvacRouteRole.alternate,
            borderPattern: 'dashed',
          )
        else
          route,
    ];
    return copyWith(routes: updatedRoutes, primaryRouteId: routeId);
  }

  /// Removes [routeId]. For the primary, pass [newPrimaryRouteId] (or the
  /// first remaining alternate is promoted). Cannot remove the last route.
  EvacKitGeometry? withoutRoute(
    String routeId, {
    String? newPrimaryRouteId,
  }) {
    if (routes.length <= 1) {
      return null;
    }
    if (!routes.any((route) => route.id == routeId)) {
      return null;
    }

    final remaining = [
      for (final route in routes)
        if (route.id != routeId) route,
    ];
    if (remaining.isEmpty) {
      return null;
    }

    if (routeId != primaryRouteId) {
      return copyWith(routes: remaining);
    }

    final promoteId = newPrimaryRouteId != null &&
            remaining.any((route) => route.id == newPrimaryRouteId)
        ? newPrimaryRouteId
        : remaining.first.id;
    final updated = [
      for (final route in remaining)
        if (route.id == promoteId)
          route.copyWith(
            role: EvacRouteRole.primary,
            borderPattern: 'solid',
          )
        else if (route.role == EvacRouteRole.primary)
          route.copyWith(
            role: EvacRouteRole.alternate,
            borderPattern: 'dashed',
          )
        else
          route,
    ];
    return copyWith(routes: updated, primaryRouteId: promoteId);
  }

  Map<String, dynamic> toJson() => {
    'primaryRouteId': primaryRouteId,
    'defaultMode': defaultMode.toJson(),
    'showNameLabel': showNameLabel,
    'routes': [for (final route in routes) route.toJson()],
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
  };

  String encode() => jsonEncode(toJson());

  static EvacKitGeometry? fromZone(MapZone zone) {
    if (zone.type != evacKitZoneType) {
      return null;
    }
    return fromJsonString(zone.geometryJson);
  }

  static EvacKitGeometry? fromJsonString(String raw) {
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

  static EvacKitGeometry? fromJson(Map<String, dynamic> json) {
    final routesRaw = json['routes'];
    if (routesRaw is! List) {
      return null;
    }
    final routes = <EvacRoute>[];
    for (final entry in routesRaw) {
      if (entry is Map<String, dynamic>) {
        final route = EvacRoute.fromJson(entry);
        if (route != null) {
          routes.add(route);
        }
      } else if (entry is Map) {
        final route = EvacRoute.fromJson(Map<String, dynamic>.from(entry));
        if (route != null) {
          routes.add(route);
        }
      }
    }
    if (routes.isEmpty) {
      return null;
    }
    final primaryRouteId = json['primaryRouteId']?.toString();
    final resolvedPrimary = primaryRouteId != null &&
            routes.any((route) => route.id == primaryRouteId)
        ? primaryRouteId
        : routes.first.id;
    return EvacKitGeometry(
      routes: routes,
      primaryRouteId: resolvedPrimary,
      defaultMode: TrackTransportationMode.fromJson(json['defaultMode']),
      notes: json['notes'] as String?,
      showNameLabel: json['showNameLabel'] != false,
    );
  }
}

String newEvacRouteId() => 'route_${DateTime.now().toUtc().microsecondsSinceEpoch}';

LatLng? evacKitZoneCenter(MapZone zone) {
  return EvacKitGeometry.fromZone(zone)?.labelPoint;
}

MapZone updateZoneEvacKitGeometry(MapZone zone, EvacKitGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}
