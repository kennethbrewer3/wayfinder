import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../circles/providers/circle_drawing_provider.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/bearing_plot_provider.dart';
import '../../lines/providers/dead_reckoning_provider.dart';
import '../../lines/providers/line_drawing_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/models/marker_color.dart';
import '../../polygons/providers/polygon_drawing_provider.dart';
import '../../rectangles/providers/rectangle_drawing_provider.dart';
import '../../slope/providers/slope_provider.dart';
import '../../viewshed/providers/viewshed_provider.dart';
import '../models/evac_kit_geometry.dart';
import '../providers/evac_kit_drawing_provider.dart';
import '../utils/evac_kit_eta.dart';
import 'evac_kit_form_dialog.dart';

/// Resets other map tools and starts alternate-route drawing for [zone].
///
/// Seeds waypoint 1 from the primary route origin so alternates share the
/// same start (marker or point).
void beginEvacKitAlternateDrawing({
  required WidgetRef ref,
  required MapZone zone,
}) {
  ref.read(selectedMapObjectProvider.notifier).clear();
  ref.read(lineDrawingProvider.notifier).reset();
  ref.read(circleDrawingProvider.notifier).reset();
  ref.read(rectangleDrawingProvider.notifier).reset();
  ref.read(polygonDrawingProvider.notifier).reset();
  ref.read(bearingPlotProvider.notifier).reset();
  ref.read(deadReckoningProvider.notifier).reset();
  ref.read(viewshedProvider.notifier).reset();
  ref.read(slopeProvider.notifier).reset();

  final geometry = EvacKitGeometry.fromZone(zone);
  final origin = geometry?.primaryOriginWaypoint;
  ref
      .read(evacKitDrawingProvider.notifier)
      .beginAlternate(
        kitId: zone.id,
        kitName: zone.name,
        firstWaypoint: origin,
      );
}

Future<bool> createEvacKitFromWaypoints({
  required BuildContext context,
  required WidgetRef ref,
  required List<EvacWaypoint> waypoints,
}) async {
  if (waypoints.length < 2) {
    return false;
  }

  final routeId = newEvacRouteId();
  final draftRoute = EvacRoute(
    id: routeId,
    name: 'Primary',
    role: EvacRouteRole.primary,
    waypoints: waypoints,
    borderPattern: 'solid',
  );
  final lengthMeters = evacRouteLengthMeters(draftRoute);

  final formData = await showEvacKitFormDialog(
    context: context,
    waypointCount: waypoints.length,
    pathLengthMeters: lengthMeters,
    initialLayerId: selectedLayerIdForCreate(ref),
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final geometry = EvacKitGeometry(
    primaryRouteId: routeId,
    defaultMode: formData.defaultMode,
    notes: formData.notes,
    showNameLabel: formData.showNameLabel,
    routes: [
      draftRoute.copyWith(
        name: formData.primaryRouteName,
        color: formatMarkerColorHex(formData.color),
      ),
    ],
  );

  AppLogger.logZones.info(
    '🛟 Creating evac kit',
    data: 'waypoints=${waypoints.length} routes=1',
  );

  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final colorHex = formatMarkerColorHex(formData.color);
  await client.mapZone.createZone(
    MapZone(
      name: formData.name,
      type: evacKitZoneType,
      color: colorHex,
      borderColor: colorHex,
      borderPattern: 'solid',
      fillColor: formatMarkerColorHexWithAlpha(
        formData.color.withValues(alpha: 0.15),
      ),
      visible: true,
      geometryJson: geometry.encode(),
      layerId: formData.layerId ?? selectedLayerIdForCreate(ref),
      createdAt: now,
      updatedAt: now,
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logZones.success('🛟 Evac kit created');
  return true;
}

Future<bool> addEvacKitAlternateRoute({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
  required List<EvacWaypoint> waypoints,
}) async {
  final geometry = EvacKitGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid || waypoints.length < 2) {
    return false;
  }

  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController(
    text: l10n.evacKitAlternateRouteName(geometry.alternateRoutes.length + 1),
  );
  final routeName = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.evacKitAddAlternateTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.evacKitRouteNameLabel,
          ),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              Navigator.of(context).pop(trimmed);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                Navigator.of(context).pop(trimmed);
              }
            },
            child: Text(l10n.actionCreate),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (routeName == null || !context.mounted) {
    return false;
  }

  final alternate = EvacRoute(
    id: newEvacRouteId(),
    name: routeName,
    role: EvacRouteRole.alternate,
    waypoints: waypoints,
    borderPattern: 'dashed',
    color: zone.color,
  );
  final updated = geometry.withRoute(alternate);
  final client = ref.read(serverClientProvider);
  await client.mapZone.updateZone(
    updateZoneEvacKitGeometry(zone, updated),
  );
  ref.read(zonesProvider.notifier).reload();
  return true;
}

Future<bool> updateEvacKitFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
}) async {
  final geometry = EvacKitGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return false;
  }
  final primary = geometry.primaryRoute!;
  final l10n = AppLocalizations.of(context)!;
  final formData = await showEvacKitFormDialog(
    context: context,
    title: l10n.evacKitEditTitle,
    confirmLabel: l10n.actionSave,
    defaultName: zone.name,
    initialNotes: geometry.notes,
    initialColor: parseMarkerColor(zone.color),
    initialDefaultMode: geometry.defaultMode,
    initialShowNameLabel: geometry.showNameLabel,
    initialLayerId: zone.layerId,
    initialPrimaryRouteName: primary.name,
    waypointCount: primary.waypoints.length,
    pathLengthMeters: evacRouteLengthMeters(primary),
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final updatedPrimary = primary.copyWith(
    name: formData.primaryRouteName,
    color: formatMarkerColorHex(formData.color),
  );
  final updatedGeometry = geometry
      .withRoute(updatedPrimary)
      .copyWith(
        defaultMode: formData.defaultMode,
        notes: formData.notes,
        showNameLabel: formData.showNameLabel,
      );

  final colorHex = formatMarkerColorHex(formData.color);
  final client = ref.read(serverClientProvider);
  await client.mapZone.updateZone(
    zone.copyWith(
      name: formData.name,
      color: colorHex,
      borderColor: colorHex,
      fillColor: formatMarkerColorHexWithAlpha(
        formData.color.withValues(alpha: 0.15),
      ),
      layerId: formData.layerId,
      geometryJson: updatedGeometry.encode(),
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  return true;
}
