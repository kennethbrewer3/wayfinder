import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../markers/models/marker_color.dart';
import '../providers/zones_provider.dart';
import '../models/line_geometry.dart';
import '../providers/measurement_units_provider.dart';
import 'line_form_dialog.dart';

Future<bool> createLineBetweenPoints({
  required BuildContext context,
  required WidgetRef ref,
  required LatLng start,
  required LatLng end,
}) async {
  final measurementUnits = ref.read(measurementUnitsProvider);
  final formData = await showLineFormDialog(
    context: context,
    start: start,
    end: end,
    measurementUnits: measurementUnits,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  AppLogger.logZones.info(
    '📏 Creating line',
    data:
        'start=${start.latitude},${start.longitude} end=${end.latitude},${end.longitude}',
  );

  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final colorHex = formatMarkerColorHex(formData.color);
  final geometry = LineGeometry(
    points: [start, end],
    showArrows: formData.showArrows,
    notes: formData.notes,
  );

  await client.mapZone.createZone(
    MapZone(
      name: formData.name,
      type: lineZoneType,
      color: colorHex,
      borderColor: colorHex,
      borderPattern: formData.borderPattern.storageValue,
      fillColor: colorHex,
      visible: true,
      geometryJson: geometry.encode(),
      createdAt: now,
      updatedAt: now,
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logZones.success('📏 Line created');
  return true;
}

Future<bool> updateLineFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
}) async {
  final geometry = LineGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return false;
  }

  final measurementUnits = ref.read(measurementUnitsProvider);
  final formData = await showLineFormDialog(
    context: context,
    title: 'Edit line',
    confirmLabel: 'Save',
    defaultName: zone.name,
    start: geometry.start!,
    end: geometry.end!,
    measurementUnits: measurementUnits,
    initialNotes: geometry.notes,
    initialColor: parseMarkerColor(zone.color),
    initialBorderPattern: lineBorderPatternFromStorage(zone.borderPattern),
    initialShowArrows: geometry.showArrows,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final client = ref.read(serverClientProvider);
  final colorHex = formatMarkerColorHex(formData.color);
  final updatedGeometry = geometry.copyWith(
    showArrows: formData.showArrows,
    notes: formData.notes,
    showDistanceLabel: geometry.showDistanceLabel,
    showNameLabel: geometry.showNameLabel,
  );

  await client.mapZone.updateZone(
    zone.copyWith(
      name: formData.name,
      color: colorHex,
      borderColor: colorHex,
      borderPattern: formData.borderPattern.storageValue,
      fillColor: colorHex,
      geometryJson: updatedGeometry.encode(),
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  return true;
}

Future<void> toggleLineDistanceLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).toggleLineDistanceLabel(zoneId);
}

Future<void> toggleLineNameLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).toggleLineNameLabel(zoneId);
}
