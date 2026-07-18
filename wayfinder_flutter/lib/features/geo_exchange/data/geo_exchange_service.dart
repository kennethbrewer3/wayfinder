import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/models/line_geometry.dart';
import '../../markers/models/marker_icon_registry.dart';
import '../../tracks/models/track_geometry.dart';
import '../models/geo_exchange_models.dart';
import '../utils/geo_exchange_codec.dart';

const _importedColor = '#1E88E5';

/// Builds an exchange bundle from current map markers and path zones.
GeoExchangeBundle bundleFromMapObjects({
  required List<MapMarker> markers,
  required List<MapZone> zones,
}) {
  final waypoints = [
    for (final marker in markers)
      GeoWaypoint(
        name: marker.name.trim().isEmpty ? 'Marker' : marker.name.trim(),
        point: LatLng(marker.latitude, marker.longitude),
        elevation: marker.elevation == 0 ? null : marker.elevation,
        description: marker.notes,
      ),
  ];

  final tracks = <GeoTrack>[];
  for (final zone in zones) {
    if (zone.type == lineZoneType) {
      final geometry = LineGeometry.fromZone(zone);
      if (geometry != null && geometry.isValid) {
        tracks.add(
          GeoTrack(
            name: zone.name.trim().isEmpty ? 'Line' : zone.name.trim(),
            points: geometry.points,
            description: geometry.notes,
          ),
        );
      }
      continue;
    }
    if (zone.type == trackZoneType) {
      final geometry = TrackGeometry.fromZone(zone);
      if (geometry != null && geometry.hasRenderablePath) {
        tracks.add(
          GeoTrack(
            name: zone.name.trim().isEmpty ? 'Track' : zone.name.trim(),
            points: geometry.pathPoints,
          ),
        );
      }
    }
  }

  return GeoExchangeBundle(waypoints: waypoints, tracks: tracks);
}

/// Imports waypoints as markers and tracks/routes as line zones (additive).
Future<GeoImportResult> importGeoExchangeBundle({
  required Client client,
  required GeoExchangeBundle bundle,
  UuidValue? layerId,
}) async {
  final now = DateTime.now().toUtc();
  var markersCreated = 0;
  var linesCreated = 0;

  for (final waypoint in bundle.waypoints) {
    await client.mapMarker.createMarker(
      MapMarker(
        name: waypoint.name,
        notes: waypoint.description,
        latitude: waypoint.point.latitude,
        longitude: waypoint.point.longitude,
        elevation: waypoint.elevation ?? 0,
        color: _importedColor,
        icon: defaultMarkerIconKey,
        visible: true,
        layerId: layerId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    markersCreated++;
  }

  for (final track in bundle.tracks.where((t) => t.isValid)) {
    final geometry = LineGeometry(
      points: track.points,
      showArrows: false,
      notes: track.description,
    );
    await client.mapZone.createZone(
      MapZone(
        name: track.name,
        type: lineZoneType,
        color: _importedColor,
        borderColor: _importedColor,
        borderPattern: 'solid',
        fillColor: _importedColor,
        visible: true,
        geometryJson: geometry.encode(),
        layerId: layerId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    linesCreated++;
  }

  return GeoImportResult(
    markersCreated: markersCreated,
    linesCreated: linesCreated,
  );
}

String exportGeoExchangeText({
  required List<MapMarker> markers,
  required List<MapZone> zones,
  required GeoExchangeFormat format,
}) {
  final bundle = bundleFromMapObjects(markers: markers, zones: zones);
  return encodeGeoExchange(bundle, format: format);
}
