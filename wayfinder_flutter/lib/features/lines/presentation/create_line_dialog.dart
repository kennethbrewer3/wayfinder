import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../markers/models/marker_color.dart';
import '../providers/zones_provider.dart';
import '../models/line_geometry.dart';
import '../providers/measurement_units_provider.dart';
import '../utils/line_path.dart';
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
    initialLayerId: selectedLayerIdForCreate(ref),
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
    points: [formData.start, formData.end],
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
      layerId: formData.layerId ?? selectedLayerIdForCreate(ref),
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
  final l10n = AppLocalizations.of(context)!;
  final formData = await showLineFormDialog(
    context: context,
    title: l10n.lineEditTitle,
    confirmLabel: l10n.actionSave,
    defaultName: zone.name,
    start: geometry.start!,
    end: geometry.end!,
    pathLengthMeters: geometry.pathLengthMeters,
    measurementUnits: measurementUnits,
    initialNotes: geometry.notes,
    initialColor: parseMarkerColor(zone.color),
    initialBorderPattern: lineBorderPatternFromStorage(zone.borderPattern),
    initialShowArrows: geometry.showArrows,
    initialLayerId: zone.layerId,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final client = ref.read(serverClientProvider);
  final colorHex = formatMarkerColorHex(formData.color);
  final points = List<LatLng>.from(geometry.points);
  points[0] = formData.start;
  points[points.length - 1] = formData.end;
  final updatedGeometry = geometry.copyWith(
    points: points,
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
      layerId: formData.layerId,
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
