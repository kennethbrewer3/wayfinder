import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../markers/models/marker_color.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../models/seasonal_date_window.dart';
import '../providers/seasonal_overlays_provider.dart';
import 'seasonal_overlay_form_dialog.dart';

Future<bool> createSeasonalOverlayFromPoints({
  required BuildContext context,
  required WidgetRef ref,
  required List<LatLng> points,
}) async {
  if (points.length < 3) {
    return false;
  }

  final formData = await showSeasonalOverlayFormDialog(
    context: context,
    points: points,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  AppLogger.logMap.info(
    '🗓️ Creating seasonal overlay',
    data: 'vertices=${points.length} mode=${formData.dateMode}',
  );

  final now = DateTime.now().toUtc();
  final existing =
      ref.read(seasonalOverlaysProvider).valueOrNull ??
      const <SeasonalOverlay>[];
  final nextSortOrder = existing.isEmpty
      ? 0
      : existing.map((o) => o.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  final geometry = PolygonGeometry(points: points, notes: formData.notes);
  final schedule = SeasonalSchedule(
    dateMode: formData.dateMode,
    windows: formData.windows,
  );

  await ref
      .read(seasonalOverlaysProvider.notifier)
      .create(
        SeasonalOverlay(
          name: formData.name,
          color: formatMarkerColorHex(formData.borderColor),
          borderColor: formatMarkerColorHex(formData.borderColor),
          fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
          visible: true,
          notes: formData.notes,
          dateMode: formData.dateMode,
          dateWindowsJson: schedule.encode(),
          geometryJson: geometry.encode(),
          sortOrder: nextSortOrder,
          createdAt: now,
          updatedAt: now,
        ),
      );
  AppLogger.logMap.success('🗓️ Seasonal overlay created');
  return true;
}

Future<bool> updateSeasonalOverlayFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required SeasonalOverlay overlay,
}) async {
  final geometry = PolygonGeometry.fromJsonString(overlay.geometryJson);
  if (geometry == null || !geometry.isValid) {
    return false;
  }

  final l10n = AppLocalizations.of(context)!;
  final schedule = SeasonalSchedule.parse(
    dateMode: overlay.dateMode,
    dateWindowsJson: overlay.dateWindowsJson,
  );
  final formData = await showSeasonalOverlayFormDialog(
    context: context,
    points: geometry.points,
    title: l10n.seasonalOverlayEditTitle,
    confirmLabel: l10n.actionSave,
    defaultName: overlay.name,
    initialNotes: overlay.notes ?? geometry.notes,
    initialBorderColor: parseMarkerColor(overlay.borderColor),
    initialFillColor: parseMarkerColor(overlay.fillColor),
    initialDateMode: schedule.dateMode,
    initialWindows: schedule.windows.isEmpty ? null : schedule.windows,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final updatedSchedule = SeasonalSchedule(
    dateMode: formData.dateMode,
    windows: formData.windows,
  );
  final updatedGeometry = geometry.copyWith(notes: formData.notes);

  await ref
      .read(seasonalOverlaysProvider.notifier)
      .updateOverlay(
        overlay.copyWith(
          name: formData.name,
          color: formatMarkerColorHex(formData.borderColor),
          borderColor: formatMarkerColorHex(formData.borderColor),
          fillColor: formatMarkerColorHexWithAlpha(formData.fillColor),
          notes: formData.notes,
          dateMode: formData.dateMode,
          dateWindowsJson: updatedSchedule.encode(),
          geometryJson: updatedGeometry.encode(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
  return true;
}
