import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../circles/models/circle_geometry.dart';
import '../../circles/models/circle_size_display.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../map/providers/home_location_provider.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/models/marker_radio.dart';
import '../../markers/providers/markers_provider.dart';
import '../../viewshed/providers/viewshed_provider.dart';
import '../models/coverage_plan.dart';
import 'coverage_plan_dialog.dart';

class CoveragePlanCreateResult {
  const CoveragePlanCreateResult({
    required this.markerCount,
    required this.circleCount,
    required this.runViewshedOnSeed,
    required this.seed,
    required this.antennaHeightMeters,
    required this.viewshedRangeMeters,
  });

  final int markerCount;
  final int circleCount;
  final bool runViewshedOnSeed;
  final LatLng seed;
  final double antennaHeightMeters;
  final double viewshedRangeMeters;
}

Future<CoveragePlanCreateResult?> createCoveragePlan({
  required BuildContext context,
  required WidgetRef ref,
  MapMarker? selectedMarker,
  LatLng? mapPoint,
}) async {
  final home = ref.read(homeLocationProvider);
  final result = await showCoveragePlanDialog(
    context: context,
    measurementUnits: ref.read(measurementUnitsProvider),
    selectedMarkerCenter: selectedMarker == null
        ? null
        : LatLng(selectedMarker.latitude, selectedMarker.longitude),
    selectedMarkerName: selectedMarker?.name,
    homeCenter: home.center,
    mapPoint: mapPoint,
  );
  if (result == null || !context.mounted) {
    return null;
  }

  final l10n = AppLocalizations.of(context)!;
  final spec = result.spec;
  final sites = spec.sites();
  final layerId = selectedLayerIdForCreate(ref);
  final client = ref.read(serverClientProvider);
  final now = DateTime.now().toUtc();
  final accent = Color(spec.template.accentColorValue);
  final colorHex = formatMarkerColorHex(accent);
  final fillHex = formatMarkerColorHexWithAlpha(
    accent.withValues(alpha: 0.18),
  );
  final templateLabel = switch (spec.template) {
    CoverageTemplateKind.mesh => l10n.coveragePlanTemplateMesh,
    CoverageTemplateKind.repeater => l10n.coveragePlanTemplateRepeater,
    CoverageTemplateKind.shack => l10n.coveragePlanTemplateShack,
  };

  AppLogger.logZones.info(
    '📡 Creating coverage plan',
    data:
        'template=${spec.template.name} layout=${spec.layout.name} '
        'sites=${sites.length} radius=${spec.coverageRadiusMeters}m',
  );

  var markerCount = 0;
  var circleCount = 0;

  for (final site in sites) {
    final siteName = l10n.coveragePlanSiteName(templateLabel, site.label);
    if (spec.createMarkers) {
      final radioJson = MarkerRadioContact(
        role: spec.template.radioRole,
        notes: l10n.coveragePlanRadioNotes(templateLabel),
      ).toStorageJson();
      await client.mapMarker.createMarker(
        MapMarker(
          name: siteName,
          latitude: site.center.latitude,
          longitude: site.center.longitude,
          elevation: 0,
          color: colorHex,
          icon: spec.template.markerIcon,
          visible: true,
          isTracking: false,
          radioJson: radioJson,
          layerId: layerId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      markerCount += 1;
    }

    if (spec.createCircles) {
      final geometry = CircleGeometry(
        center: site.center,
        radiusMeters: spec.coverageRadiusMeters,
        notes: l10n.coveragePlanCircleNotes(templateLabel),
        sizeDisplay: CircleSizeDisplay.radius,
        showNameLabel: false,
      );
      await client.mapZone.createZone(
        MapZone(
          name: siteName,
          type: circleZoneType,
          color: colorHex,
          borderColor: colorHex,
          borderPattern: 'solid',
          fillColor: fillHex,
          visible: true,
          geometryJson: geometry.encode(),
          layerId: layerId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      circleCount += 1;
    }
  }

  ref.invalidate(markersProvider);
  ref.read(zonesProvider.notifier).reload();
  AppLogger.logZones.success(
    '📡 Coverage plan created',
    data: 'markers=$markerCount circles=$circleCount',
  );

  return CoveragePlanCreateResult(
    markerCount: markerCount,
    circleCount: circleCount,
    runViewshedOnSeed: spec.runViewshedOnSeed,
    seed: spec.seed,
    antennaHeightMeters: spec.template.defaultAntennaHeightMeters,
    viewshedRangeMeters: spec.coverageRadiusMeters.clamp(50, 50000),
  );
}

Future<void> maybeBeginCoverageViewshed({
  required WidgetRef ref,
  required CoveragePlanCreateResult result,
}) async {
  if (!result.runViewshedOnSeed) {
    return;
  }
  await ref
      .read(viewshedProvider.notifier)
      .begin(
        observer: result.seed,
        antennaHeightMeters: result.antennaHeightMeters,
        rangeMeters: result.viewshedRangeMeters,
      );
}
