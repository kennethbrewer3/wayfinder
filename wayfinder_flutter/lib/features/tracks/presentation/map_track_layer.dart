import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/track_geometry.dart';

List<Polyline<UuidValue>> buildSavedTrackPolylines(
  List<MapZone> zones, {
  UuidValue? selectedTrackId,
}) {
  final polylines = <Polyline<UuidValue>>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != trackZoneType) {
      continue;
    }
    final geometry = TrackGeometry.fromZone(zone);
    if (geometry == null || !geometry.hasRenderablePath) {
      continue;
    }
    final isSelected = selectedTrackId == zone.id;
    polylines.add(
      Polyline(
        points: geometry.pathPoints,
        color: parseMarkerColor(zone.color),
        strokeWidth: isSelected ? 5 : 3,
        hitValue: zone.id,
      ),
    );
  }
  return polylines;
}

LatLng? trackZoneCenterPoint(MapZone zone) => trackZoneCenter(zone);
