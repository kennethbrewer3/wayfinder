import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../lines/models/line_geometry.dart';
import '../../lines/utils/line_path.dart';
import '../../lines/utils/line_snap.dart';
import '../models/evac_kit_geometry.dart';

LineGeometry evacRouteAsLineGeometry(EvacRoute route) {
  return LineGeometry(
    points: route.pathPoints,
    showArrows: route.showArrows,
    pathMode: route.pathMode,
  );
}

List<LatLng> buildEvacRouteRenderPoints(EvacRoute route) {
  return buildLineRenderPoints(evacRouteAsLineGeometry(route));
}

int? hitTestEvacWaypointIndex({
  required List<EvacWaypoint> waypoints,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 18,
}) {
  final tapScreen = camera.latLngToScreenOffset(tap);
  int? closestIndex;
  var closestDistance = hitRadiusPx;

  for (var index = 0; index < waypoints.length; index++) {
    final pointScreen = camera.latLngToScreenOffset(waypoints[index].point);
    final distance = (tapScreen - pointScreen).distance;
    if (distance <= closestDistance) {
      closestDistance = distance;
      closestIndex = index;
    }
  }
  return closestIndex;
}

class EvacRouteSegmentHit {
  const EvacRouteSegmentHit({
    required this.segmentIndex,
    required this.distancePx,
    required this.projected,
  });

  /// Index of the segment start waypoint (insert at [segmentIndex] + 1).
  final int segmentIndex;
  final double distancePx;
  final LatLng projected;
}

EvacRouteSegmentHit? closestEvacRouteSegment({
  required EvacRoute route,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 22,
}) {
  final segment = closestLineRenderSegment(
    geometry: evacRouteAsLineGeometry(route),
    tap: tap,
    camera: camera,
    hitRadiusPx: hitRadiusPx,
  );
  if (segment == null) {
    return null;
  }
  final tapScreen = camera.latLngToScreenOffset(tap);
  final distance = distanceToSegmentPx(
    tapScreen,
    camera.latLngToScreenOffset(segment.start),
    camera.latLngToScreenOffset(segment.end),
  );
  return EvacRouteSegmentHit(
    segmentIndex: segment.controlSegmentIndex,
    distancePx: distance,
    projected: projectPointOnSegment(segment.start, segment.end, tap),
  );
}

/// Legacy chord hit-test when only waypoints are available (drawing drafts).
EvacRouteSegmentHit? closestEvacWaypointChordSegment({
  required List<EvacWaypoint> waypoints,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 22,
}) {
  if (waypoints.length < 2) {
    return null;
  }
  final tapScreen = camera.latLngToScreenOffset(tap);
  EvacRouteSegmentHit? closest;

  for (var i = 0; i < waypoints.length - 1; i++) {
    final start = waypoints[i].point;
    final end = waypoints[i + 1].point;
    final distance = distanceToSegmentPx(
      tapScreen,
      camera.latLngToScreenOffset(start),
      camera.latLngToScreenOffset(end),
    );
    if (distance > hitRadiusPx) {
      continue;
    }
    if (closest == null || distance < closest.distancePx) {
      closest = EvacRouteSegmentHit(
        segmentIndex: i,
        distancePx: distance,
        projected: projectPointOnSegment(start, end, tap),
      );
    }
  }
  return closest;
}

bool isNearEvacRouteSegment({
  required EvacRoute route,
  required LatLng tap,
  required MapCamera camera,
  double hitRadiusPx = 22,
}) {
  return closestEvacRouteSegment(
        route: route,
        tap: tap,
        camera: camera,
        hitRadiusPx: hitRadiusPx,
      ) !=
      null;
}

/// Inserts a curve [EvacWaypointKind.control] on the closest render segment.
EvacRoute? insertEvacControlPoint({
  required EvacRoute route,
  required LatLng tap,
  required MapCamera camera,
}) {
  final hit = closestEvacRouteSegment(
    route: route,
    tap: tap,
    camera: camera,
  );
  if (hit == null) {
    return null;
  }
  final updated = [...route.waypoints]
    ..insert(
      hit.segmentIndex + 1,
      EvacWaypoint(
        kind: EvacWaypointKind.control,
        point: hit.projected,
      ),
    );
  return route.copyWith(
    waypoints: updated,
    pathMode: LinePathMode.smooth,
  );
}

EvacRoute? moveEvacWaypoint({
  required EvacRoute route,
  required int waypointIndex,
  required LatLng point,
}) {
  if (waypointIndex < 0 || waypointIndex >= route.waypoints.length) {
    return null;
  }
  final existing = route.waypoints[waypointIndex];
  final updated = [...route.waypoints];
  if (existing.kind.isControlPoint) {
    updated[waypointIndex] = existing.copyWith(point: point);
  } else {
    // Dragging a marker-linked waypoint converts it to a free waypoint.
    updated[waypointIndex] = EvacWaypoint(
      kind: EvacWaypointKind.point,
      point: point,
      label: existing.label,
    );
  }
  return route.copyWith(waypoints: updated);
}

bool canRemoveEvacPoint(EvacRoute route, int waypointIndex) {
  if (waypointIndex <= 0 ||
      waypointIndex >= route.waypoints.length - 1 ||
      route.waypoints.length <= 2) {
    return false;
  }
  return true;
}

bool canToggleEvacPointKind(EvacRoute route, int waypointIndex) {
  if (waypointIndex <= 0 || waypointIndex >= route.waypoints.length - 1) {
    return false;
  }
  return true;
}

/// Toggles a mid-point between route waypoint ([EvacWaypointKind.point]) and
/// curve control ([EvacWaypointKind.control]). Endpoints stay waypoints.
EvacRoute? toggleEvacPointKind({
  required EvacRoute route,
  required int waypointIndex,
}) {
  if (!canToggleEvacPointKind(route, waypointIndex)) {
    return null;
  }
  final existing = route.waypoints[waypointIndex];
  final nextKind = existing.kind.isControlPoint
      ? EvacWaypointKind.point
      : EvacWaypointKind.control;
  final updated = [...route.waypoints];
  updated[waypointIndex] = EvacWaypoint(
    kind: nextKind,
    point: existing.point,
    label: nextKind.isRouteWaypoint ? existing.label : null,
  );
  return route.copyWith(
    waypoints: updated,
    pathMode: nextKind.isControlPoint ? LinePathMode.smooth : route.pathMode,
  );
}

EvacRoute? removeEvacWaypoint({
  required EvacRoute route,
  required int waypointIndex,
}) {
  if (!canRemoveEvacPoint(route, waypointIndex)) {
    return null;
  }
  final updated = [...route.waypoints]..removeAt(waypointIndex);
  return route.copyWith(
    waypoints: updated,
    pathMode: updated.length > 2 ? route.pathMode : LinePathMode.straight,
  );
}

/// 1-based route waypoint number for display, or null for control points.
int? evacRouteWaypointNumber(EvacRoute route, int index) {
  if (index < 0 || index >= route.waypoints.length) {
    return null;
  }
  if (!route.waypoints[index].kind.isRouteWaypoint) {
    return null;
  }
  var number = 0;
  for (var i = 0; i <= index; i++) {
    if (route.waypoints[i].kind.isRouteWaypoint) {
      number++;
    }
  }
  return number;
}

EvacRoute? appendEvacWaypoint({
  required EvacRoute route,
  required EvacWaypoint waypoint,
}) {
  final waypoints = route.waypoints;
  if (waypoints.isNotEmpty &&
      areLinePointsTooClose(
        waypoints.last.point,
        waypoint.point,
        minMeters: 1,
      )) {
    return null;
  }
  if (waypoints.isNotEmpty &&
      waypoint.markerId != null &&
      waypoints.last.markerId == waypoint.markerId) {
    return null;
  }
  return route.copyWith(waypoints: [...waypoints, waypoint]);
}
