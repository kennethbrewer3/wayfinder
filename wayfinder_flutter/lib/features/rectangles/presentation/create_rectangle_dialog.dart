import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/models/marker_color.dart';
import '../models/rectangle_geometry.dart';
import 'rectangle_form_dialog.dart';

Future<bool> createCenterExtentRectangle({
  required BuildContext context,
  required WidgetRef ref,
  required LatLng center,
  required LatLng extentPoint,
}) {
  return _createRectangle(
    context: context,
    ref: ref,
    geometry: RectangleGeometry.centerExtent(
      center: center,
      extentPoint: extentPoint,
    ),
  );
}

Future<bool> createCornersRectangle({
  required BuildContext context,
  required WidgetRef ref,
  required LatLng cornerA,
  required LatLng cornerB,
}) {
  return _createRectangle(
    context: context,
    ref: ref,
    geometry: RectangleGeometry.corners(
      cornerA: cornerA,
      cornerB: cornerB,
    ),
  );
}

Future<bool> _createRectangle({
  required BuildContext context,
  required WidgetRef ref,
  required RectangleGeometry geometry,
}) async {
  if (!geometry.isValid) {
    return false;
  }

  final measurementUnits = ref.read(measurementUnitsProvider);
  final formData = await showRectangleFormDialog(
    context: context,
    creationMode: geometry.creationMode,
    bounds: geometry.bounds,
    measurementUnits: measurementUnits,
    initialLayerId: selectedLayerIdForCreate(ref),
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  AppLogger.logZones.info(
    '▭ Creating rectangle',
    data: 'mode=${geometry.creationMode.storageValue}',
  );

  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final savedGeometry = geometry.copyWith(
    notes: formData.notes,
    sizeDisplay: formData.sizeDisplay,
    showNameLabel: formData.showNameLabel,
  );

  await client.mapZone.createZone(
    MapZone(
      name: formData.name,
      type: rectangleZoneType,
      color: formatMarkerColorHex(formData.centerMarkerColor),
      borderColor: formatMarkerColorHex(formData.borderColor),
      borderPattern: 'solid',
      fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
      visible: true,
      geometryJson: savedGeometry.encode(),
      layerId: formData.layerId ?? selectedLayerIdForCreate(ref),
      createdAt: now,
      updatedAt: now,
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logZones.success('▭ Rectangle created');
  return true;
}

Future<bool> updateRectangleFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
}) async {
  final geometry = RectangleGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return false;
  }

  final measurementUnits = ref.read(measurementUnitsProvider);
  final formData = await showRectangleFormDialog(
    context: context,
    title: 'Edit rectangle',
    confirmLabel: 'Save',
    defaultName: zone.name,
    creationMode: geometry.creationMode,
    bounds: geometry.bounds,
    measurementUnits: measurementUnits,
    initialSizeDisplay: geometry.sizeDisplay,
    initialNotes: geometry.notes,
    initialCenterMarkerColor: parseMarkerColor(zone.color),
    initialBorderColor: parseMarkerColor(zone.borderColor),
    initialFillColor: parseMarkerColor(zone.fillColor),
    initialShowNameLabel: geometry.showNameLabel,
    initialLayerId: zone.layerId,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final client = ref.read(serverClientProvider);
  final updatedGeometry = geometry.copyWith(
    notes: formData.notes,
    sizeDisplay: formData.sizeDisplay,
    showNameLabel: formData.showNameLabel,
  );

  await client.mapZone.updateZone(
    zone.copyWith(
      name: formData.name,
      color: formatMarkerColorHex(formData.centerMarkerColor),
      borderColor: formatMarkerColorHex(formData.borderColor),
      fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
      geometryJson: updatedGeometry.encode(),
      layerId: formData.layerId,
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  return true;
}

Future<void> toggleRectangleSizeLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).toggleRectangleSizeLabel(zoneId);
}

Future<void> toggleRectangleNameLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).toggleRectangleNameLabel(zoneId);
}
