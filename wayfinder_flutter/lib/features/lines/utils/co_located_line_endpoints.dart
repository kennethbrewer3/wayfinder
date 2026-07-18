import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/line_geometry.dart';

/// An endpoint on another line that shares coordinates with a dragged vertex.
class CoLocatedLineEndpoint {
  const CoLocatedLineEndpoint({
    required this.zoneId,
    required this.controlPointIndex,
  });

  final UuidValue zoneId;
  final int controlPointIndex;
}

/// Finds line endpoints at [point] on other lines so they can move together.
///
/// Only endpoints are considered (not mid-points). The line identified by
/// [excludeZoneId] is skipped (typically the line being edited).
List<CoLocatedLineEndpoint> findCoLocatedLineEndpoints({
  required LatLng point,
  required UuidValue excludeZoneId,
  required List<MapZone> zones,
}) {
  final matches = <CoLocatedLineEndpoint>[];

  for (final zone in zones) {
    if (zone.id == excludeZoneId ||
        !zone.visible ||
        zone.type != lineZoneType) {
      continue;
    }

    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      continue;
    }

    final points = geometry.points;
    if (points.first == point) {
      matches.add(
        CoLocatedLineEndpoint(zoneId: zone.id, controlPointIndex: 0),
      );
    }

    final endIndex = points.length - 1;
    if (endIndex > 0 && points[endIndex] == point) {
      matches.add(
        CoLocatedLineEndpoint(
          zoneId: zone.id,
          controlPointIndex: endIndex,
        ),
      );
    }
  }

  return matches;
}
