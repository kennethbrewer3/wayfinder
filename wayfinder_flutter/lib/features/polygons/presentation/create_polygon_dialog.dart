import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/models/marker_color.dart';
import '../../radio_sync/providers/radio_sync_controller.dart';
import '../models/polygon_geometry.dart';
import 'polygon_form_dialog.dart';

Future<bool> createPolygonFromPoints({
  required BuildContext context,
  required WidgetRef ref,
  required List<LatLng> points,
}) async {
  if (points.length < 3) {
    return false;
  }

  final formData = await showPolygonFormDialog(
    context: context,
    points: points,
    initialLayerId: selectedLayerIdForCreate(ref),
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  AppLogger.logZones.info(
    '⬠ Creating polygon AOI',
    data: 'vertices=${points.length}',
  );

  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final geometry = PolygonGeometry(
    points: points,
    notes: formData.notes,
    showNameLabel: formData.showNameLabel,
  );

  final zone = MapZone(
    name: formData.name,
    type: polygonZoneType,
    color: formatMarkerColorHex(formData.borderColor),
    borderColor: formatMarkerColorHex(formData.borderColor),
    borderPattern: 'solid',
    fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
    visible: true,
    geometryJson: geometry.encode(),
    layerId: formData.layerId ?? selectedLayerIdForCreate(ref),
    createdAt: now,
    updatedAt: now,
  );
  await client.mapZone.createZone(zone);
  await ref.read(radioSyncControllerProvider).emitLightZone(zone);
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logZones.success('⬠ Polygon AOI created');
  return true;
}

Future<bool> updatePolygonFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
}) async {
  final geometry = PolygonGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return false;
  }

  final l10n = AppLocalizations.of(context)!;
  final formData = await showPolygonFormDialog(
    context: context,
    points: geometry.points,
    title: l10n.polygonEditTitle,
    confirmLabel: l10n.actionSave,
    defaultName: zone.name,
    initialNotes: geometry.notes,
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
    showNameLabel: formData.showNameLabel,
  );

  final updatedZone = zone.copyWith(
    name: formData.name,
    color: formatMarkerColorHex(formData.borderColor),
    borderColor: formatMarkerColorHex(formData.borderColor),
    fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
    geometryJson: updatedGeometry.encode(),
    layerId: formData.layerId,
    updatedAt: DateTime.now().toUtc(),
  );
  await client.mapZone.updateZone(updatedZone);
  await ref.read(radioSyncControllerProvider).emitLightZone(updatedZone);
  ref.read(zonesProvider.notifier).reload();
  return true;
}

Future<void> togglePolygonNameLabel({
  required WidgetRef ref,
  required UuidValue zoneId,
}) {
  return ref.read(zonesProvider.notifier).togglePolygonNameLabel(zoneId);
}
