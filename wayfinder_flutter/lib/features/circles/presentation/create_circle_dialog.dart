import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/models/marker_color.dart';
import '../models/circle_size_display.dart';
import '../models/circle_geometry.dart';
import '../providers/circle_size_display_provider.dart';
import 'circle_form_dialog.dart';

Future<bool> createCircleAtCenter({
  required BuildContext context,
  required WidgetRef ref,
  required LatLng center,
  required double radiusMeters,
}) async {
  final measurementUnits = ref.read(measurementUnitsProvider);
  final defaultSizeDisplay = ref.read(circleSizeDisplayProvider);
  final formData = await showCircleFormDialog(
    context: context,
    center: center,
    radiusMeters: radiusMeters,
    measurementUnits: measurementUnits,
    initialSizeDisplay: defaultSizeDisplay == CircleSizeDisplay.none
        ? CircleSizeDisplay.radius
        : defaultSizeDisplay,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  AppLogger.logZones.info(
    '⭕ Creating circle',
    data:
        'center=${center.latitude},${center.longitude} radius=${radiusMeters}m',
  );

  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final geometry = CircleGeometry(
    center: center,
    radiusMeters: radiusMeters,
    notes: formData.notes,
    sizeDisplay: formData.sizeDisplay,
    showNameLabel: formData.showNameLabel,
  );

  await client.mapZone.createZone(
    MapZone(
      name: formData.name,
      type: circleZoneType,
      color: formatMarkerColorHex(formData.centerMarkerColor),
      borderColor: formatMarkerColorHex(formData.borderColor),
      borderPattern: 'solid',
      fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
      visible: true,
      geometryJson: geometry.encode(),
      createdAt: now,
      updatedAt: now,
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logZones.success('⭕ Circle created');
  return true;
}

Future<bool> updateCircleFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
}) async {
  final geometry = CircleGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return false;
  }

  final measurementUnits = ref.read(measurementUnitsProvider);
  final formData = await showCircleFormDialog(
    context: context,
    title: 'Edit circle',
    confirmLabel: 'Save',
    defaultName: zone.name,
    center: geometry.center,
    radiusMeters: geometry.radiusMeters,
    measurementUnits: measurementUnits,
    initialSizeDisplay: geometry.sizeDisplay,
    initialNotes: geometry.notes,
    initialCenterMarkerColor: parseMarkerColor(zone.color),
    initialBorderColor: parseMarkerColor(zone.borderColor),
    initialFillColor: parseMarkerColor(zone.fillColor),
    initialShowNameLabel: geometry.showNameLabel,
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
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  return true;
}

Future<void> toggleCircleSizeLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).toggleCircleSizeLabel(zoneId);
}

Future<void> toggleCircleNameLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).toggleCircleNameLabel(zoneId);
}
