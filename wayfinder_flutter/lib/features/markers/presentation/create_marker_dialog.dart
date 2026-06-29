import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../tracks/models/track_geometry.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../models/marker_color.dart';
import '../providers/markers_provider.dart';
import 'marker_form_dialog.dart';

Future<void> _syncTrackTransportationMode({
  required Client client,
  required MapMarker marker,
  required TrackTransportationMode mode,
}) async {
  await applyTrackTransportationMode(
    getZone: client.mapZone.getZone,
    updateZone: client.mapZone.updateZone,
    marker: marker,
    mode: mode,
  );
}

Future<bool> createMarkerAtPoint({
  required BuildContext context,
  required WidgetRef ref,
  required LatLng point,
  String? defaultName,
  String? dialogTitle,
  String? confirmLabel,
}) async {
  final formData = await showMarkerFormDialog(
    context: context,
    title: dialogTitle,
    confirmLabel: confirmLabel,
    defaultName: defaultName,
    initialLayerId: selectedLayerIdForCreate(ref),
    initialLatitude: point.latitude,
    initialLongitude: point.longitude,
    allowCoordinateEdit: true,
    allowTrackingToggle: true,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  AppLogger.logMarkers.info(
    '📍 Creating marker',
    data:
        'lat=${formData.latitude ?? point.latitude} lng=${formData.longitude ?? point.longitude}',
  );
  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  var created = await client.mapMarker.createMarker(
    MapMarker(
      name: formData.name,
      notes: formData.notes,
      latitude: formData.latitude ?? point.latitude,
      longitude: formData.longitude ?? point.longitude,
      elevation: formData.elevation,
      color: formatMarkerColorHex(formData.color),
      icon: formData.icon,
      visible: true,
      isTracking: formData.isTracking,
      layerId: formData.layerId ?? selectedLayerIdForCreate(ref),
      createdAt: now,
      updatedAt: now,
    ),
  );
  if (formData.isTracking) {
    if (created.trackZoneId == null) {
      created = await client.mapMarker.getMarker(created.id) ?? created;
    }
    await _syncTrackTransportationMode(
      client: client,
      marker: created,
      mode: formData.transportationMode,
    );
  }
  ref.invalidate(markersProvider);
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logMarkers.success('📍 Marker created');
  return true;
}

Future<bool> updateMarkerFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapMarker marker,
}) async {
  final client = ref.read(serverClientProvider);
  var initialTransportationMode = TrackTransportationMode.onFoot;
  if (marker.trackZoneId != null) {
    final zone = await client.mapZone.getZone(marker.trackZoneId!);
    final geometry = zone == null ? null : TrackGeometry.fromZone(zone);
    if (geometry != null) {
      initialTransportationMode = geometry.transportationMode;
    }
  }
  if (!context.mounted) {
    return false;
  }

  final formData = await showEditMarkerDialog(
    context: context,
    marker: marker,
    initialTransportationMode: initialTransportationMode,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  var updated = await client.mapMarker.updateMarker(
    marker.copyWith(
      name: formData.name,
      notes: formData.notes,
      latitude: formData.latitude ?? marker.latitude,
      longitude: formData.longitude ?? marker.longitude,
      color: formatMarkerColorHex(formData.color),
      icon: formData.icon,
      elevation: formData.elevation,
      isTracking: formData.isTracking,
      layerId: formData.layerId,
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  if (formData.isTracking) {
    if (updated.trackZoneId == null) {
      updated = await client.mapMarker.getMarker(updated.id) ?? updated;
    }
    await _syncTrackTransportationMode(
      client: client,
      marker: updated,
      mode: formData.transportationMode,
    );
  }
  ref.invalidate(markersProvider);
  ref.read(zonesProvider.notifier).reload();
  return true;
}
