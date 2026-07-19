import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/models/line_geometry.dart';
import '../../tracks/models/track_geometry.dart';
import 'path_profile.dart';

/// Returns a profile leg when [zone] is a line or track with a usable path.
PathProfileLeg? pathProfileLegFromZone(MapZone zone) {
  if (zone.type == lineZoneType) {
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid || geometry.points.length < 2) {
      return null;
    }
    return PathProfileLeg(
      id: zone.id.uuid,
      name: zone.name,
      points: List<LatLng>.from(geometry.points),
    );
  }
  if (zone.type == trackZoneType) {
    final geometry = TrackGeometry.fromZone(zone);
    if (geometry == null ||
        !geometry.isValid ||
        !geometry.hasRenderablePath ||
        geometry.pathPoints.length < 2) {
      return null;
    }
    return PathProfileLeg(
      id: zone.id.uuid,
      name: zone.name,
      points: List<LatLng>.from(geometry.pathPoints),
    );
  }
  return null;
}

bool zoneSupportsPathProfile(MapZone zone) =>
    pathProfileLegFromZone(zone) != null;
