import 'package:wayfinder_client/wayfinder_client.dart';

import '../../tracks/models/track_geometry.dart';
import '../models/marker_icon_registry.dart';

/// Map pin icon for a tracking marker, preferring the track transportation mode.
String effectiveMarkerIconName({
  required MapMarker marker,
  required Map<UuidValue, MapZone> trackZonesById,
}) {
  if (!marker.isTracking || marker.trackZoneId == null) {
    return normalizeMarkerIcon(marker.icon);
  }

  final trackZone = trackZonesById[marker.trackZoneId!];
  if (trackZone == null) {
    return normalizeMarkerIcon(marker.icon);
  }

  final geometry = TrackGeometry.fromZone(trackZone);
  if (geometry == null) {
    return normalizeMarkerIcon(marker.icon);
  }

  return geometry.transportationMode.trackingMarkerIconKey ??
      normalizeMarkerIcon(marker.icon);
}

Map<UuidValue, MapZone> trackZonesById(Iterable<MapZone> zones) {
  return {
    for (final zone in zones)
      if (zone.type == trackZoneType) zone.id: zone,
  };
}
