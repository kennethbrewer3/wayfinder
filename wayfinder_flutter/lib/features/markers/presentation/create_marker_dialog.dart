import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../models/marker_color.dart';
import '../providers/markers_provider.dart';
import 'marker_form_dialog.dart';

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
  await client.mapMarker.createMarker(
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
  final formData = await showEditMarkerDialog(
    context: context,
    marker: marker,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final client = ref.read(serverClientProvider);
  await client.mapMarker.updateMarker(
    marker.copyWith(
      name: formData.name,
      notes: formData.notes,
      latitude: formData.latitude ?? marker.latitude,
      longitude: formData.longitude ?? marker.longitude,
      color: formatMarkerColorHex(formData.color),
      icon: formData.icon,
      elevation: formData.elevation,
      isTracking: formData.isTracking,
      trackZoneId: marker.trackZoneId,
      layerId: formData.layerId,
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.invalidate(markersProvider);
  ref.read(zonesProvider.notifier).reload();
  return true;
}
