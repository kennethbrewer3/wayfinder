import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/copy_coordinates.dart';
import '../../elevation/presentation/path_profile_dialog.dart';
import '../../elevation/providers/elevation_providers.dart';
import '../../elevation/utils/elevation_format.dart';
import '../../map/utils/mgrs_utils.dart';
import '../../markers/utils/marker_share_url.dart';
import '../../circles/models/circle_geometry.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/models/range_ring.dart';
import '../../circles/presentation/create_circle_dialog.dart';
import '../../circles/utils/circle_distance.dart';
import '../../evac_kits/models/evac_kit_geometry.dart';
import '../../evac_kits/presentation/create_evac_kit_dialog.dart';
import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../tides/presentation/create_tide_tables.dart';
import '../../layers/presentation/layer_assignment_row.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../lines/utils/line_path.dart';
import '../../lines/utils/line_distance.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../geocoding/presentation/submit_geocoding_contribution.dart';
import '../../geocoding/providers/geocoding_server_provider.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../../markers/presentation/map_object_markdown.dart';
import '../../markers/providers/markers_provider.dart';
import '../../access/providers/access_session_provider.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../../offline_packs/providers/offline_pack_controller.dart';
import '../../offline_packs/providers/offline_snapshot_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../../polygons/presentation/create_polygon_dialog.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../rectangles/presentation/create_rectangle_dialog.dart';
import '../../rectangles/utils/rectangle_dimensions.dart';
import '../../tracks/presentation/create_track_dialog.dart';
import '../../tracks/models/track_geometry.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../../tracks/presentation/track_transportation_icon.dart';
import '../../weather/presentation/weather_station_details_section.dart';
import '../../../core/l10n/localized_labels.dart';
import '../../../core/serverpod_client.dart';
import '../../seasonal_overlays/presentation/create_seasonal_overlay_dialog.dart';
import '../../seasonal_overlays/providers/seasonal_overlays_provider.dart';
import '../../watch_log/presentation/watch_log_details_section.dart';
import 'marker_attachments_details_section.dart';
import 'marker_checklists_details_section.dart';
import 'marker_inventory_details_section.dart';
import 'marker_radio_details_section.dart';
import 'marker_qr_dialog.dart';
import 'marker_tracking_details_section.dart';
import '../utils/effective_marker_icon.dart';

Future<void> showMapObjectDetailsDialog({
  required BuildContext context,
  required WidgetRef ref,
  required SelectedMapObject selection,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return _MapObjectDetailsDialog(
        selection: selection,
        onEdit: () async {
          Navigator.of(dialogContext).pop();
          await _editSelectedObject(
            context: context,
            ref: ref,
            selection: selection,
          );
        },
      );
    },
  );
}

Future<void> _editSelectedObject({
  required BuildContext context,
  required WidgetRef ref,
  required SelectedMapObject selection,
}) async {
  switch (selection.kind) {
    case SelectedMapObjectKind.marker:
      final markers = ref.read(markersProvider).valueOrNull;
      final marker = markers == null
          ? null
          : _findMarkerById(markers, selection.id);
      if (marker == null) {
        return;
      }
      await updateMarkerFromForm(context: context, ref: ref, marker: marker);
    case SelectedMapObjectKind.zone:
      final zone = ref.read(zonesProvider.notifier).zoneById(selection.id);
      if (zone == null) {
        return;
      }
      switch (zone.type) {
        case lineZoneType:
          await updateLineFromForm(context: context, ref: ref, zone: zone);
        case circleZoneType:
          await updateCircleFromForm(context: context, ref: ref, zone: zone);
        case rectangleZoneType:
          await updateRectangleFromForm(
            context: context,
            ref: ref,
            zone: zone,
          );
        case polygonZoneType:
          await updatePolygonFromForm(
            context: context,
            ref: ref,
            zone: zone,
          );
        case evacKitZoneType:
          await updateEvacKitFromForm(
            context: context,
            ref: ref,
            zone: zone,
          );
        case trackZoneType:
          await updateTrackFromForm(
            context: context,
            ref: ref,
            zone: zone,
          );
        default:
          return;
      }
    case SelectedMapObjectKind.seasonalOverlay:
      final overlays = ref.read(seasonalOverlaysProvider).valueOrNull;
      final overlay = overlays == null
          ? null
          : _findSeasonalOverlayById(overlays, selection.id);
      if (overlay == null) {
        return;
      }
      await updateSeasonalOverlayFromForm(
        context: context,
        ref: ref,
        overlay: overlay,
      );
  }
}

MapMarker? _findMarkerById(List<MapMarker> markers, UuidValue id) {
  for (final marker in markers) {
    if (marker.id == id) {
      return marker;
    }
  }
  return null;
}

SeasonalOverlay? _findSeasonalOverlayById(
  List<SeasonalOverlay> overlays,
  UuidValue id,
) {
  for (final overlay in overlays) {
    if (overlay.id == id) {
      return overlay;
    }
  }
  return null;
}

class _MapObjectDetailsDialog extends ConsumerWidget {
  const _MapObjectDetailsDialog({
    required this.selection,
    required this.onEdit,
  });

  final SelectedMapObject selection;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final measurementUnits = ref.watch(measurementUnitsProvider);

    return switch (selection.kind) {
      SelectedMapObjectKind.marker => _buildMarkerDialog(
        context,
        ref,
        theme,
        l10n,
      ),
      SelectedMapObjectKind.zone => _buildZoneDialog(
        context,
        ref,
        theme,
        l10n,
        measurementUnits,
      ),
      SelectedMapObjectKind.seasonalOverlay => _buildSeasonalOverlayDialog(
        context,
        ref,
        theme,
        l10n,
      ),
    };
  }

  Widget _buildSeasonalOverlayDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final offline = ref.watch(offlineModeActiveProvider);
    final kiosk = ref.watch(kioskModeActiveProvider);
    final roleLocked = ref.watch(mapEditsLockedByRoleProvider);
    final editLocked = offline || kiosk || roleLocked;
    final overlays = ref.watch(seasonalOverlaysProvider).valueOrNull;
    final overlay = overlays == null
        ? null
        : _findSeasonalOverlayById(overlays, selection.id);
    if (overlay == null) {
      return AlertDialog(
        title: Text(l10n.seasonalOverlayEditTitle),
        content: Text(l10n.seasonalOverlaysEmpty),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      );
    }

    final geometry = PolygonGeometry.fromJsonString(overlay.geometryJson);
    final active = isSeasonalOverlayCurrentlyActive(overlay);
    final notes = overlay.notes?.trim();
    return _DetailsDialogShell(
      title: overlay.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(overlay.borderColor),
        icon: Icons.calendar_month,
      ),
      onEdit: editLocked ? null : onEdit,
      l10n: l10n,
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: l10n.sidebarSeasonalOverlays,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVertices,
          value: geometry == null ? '—' : '${geometry.points.length}',
        ),
        if (geometry != null)
          _DetailRow(
            label: l10n.mapObjectDetailCenter,
            value: _formatLatLng(geometry.labelPoint),
          ),
        _DetailRow(
          label: l10n.seasonalOverlayDateMode,
          value: overlay.dateMode == 'recurring'
              ? l10n.seasonalOverlayDateModeRecurring
              : l10n.seasonalOverlayDateModeAbsolute,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: active
              ? l10n.seasonalOverlayStatusActive
              : l10n.seasonalOverlayStatusInactive,
        ),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _buildMarkerDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final markersAsync = ref.watch(markersProvider);
    final marker = markersAsync.valueOrNull == null
        ? null
        : _findMarkerById(markersAsync.valueOrNull!, selection.id);

    if (marker == null) {
      return _loadingOrMissingDialog(
        context: context,
        theme: theme,
        l10n: l10n,
        loading: markersAsync.isLoading,
        onEdit: onEdit,
      );
    }

    final notes = marker.notes?.trim();
    final shareUrl = buildMarkerShareUrl(marker: marker);
    final mgrs = _mgrsForLatLng(
      LatLng(marker.latitude, marker.longitude),
    );
    final trackZones = trackZonesById(
      ref.watch(zonesProvider).valueOrNull ?? const [],
    );
    void copyShareUrl() => copyTextWithFeedback(
      context,
      text: shareUrl,
      copiedMessage: l10n.mapMarkerUrlCopied,
    );
    final geocodingReachable =
        ref.watch(geocodingServerReachableProvider).valueOrNull ?? false;
    final offline = ref.watch(offlineModeActiveProvider);
    final kiosk = ref.watch(kioskModeActiveProvider);
    final roleLocked = ref.watch(mapEditsLockedByRoleProvider);
    final editLocked = offline || kiosk || roleLocked;
    final pendingCreates =
        ref.watch(offlinePendingCreateMarkerIdsProvider).valueOrNull ??
        const <String>{};
    final unsyncedOffline = offline && pendingCreates.contains(marker.id.uuid);
    final canAddToGeocoding = !editLocked && geocodingReachable;

    return _DetailsDialogShell(
      title: marker.name,
      leading: MarkerIconLargeView(
        iconName: effectiveMarkerIconName(
          marker: marker,
          trackZonesById: trackZones,
        ),
        color: parseMarkerColor(marker.color),
      ),
      onEdit: editLocked ? null : onEdit,
      l10n: l10n,
      linkedMarkerId: marker.id,
      createdByUsername: marker.createdByUsername,
      updatedByUsername: marker.updatedByUsername,
      createdAt: marker.createdAt,
      updatedAt: marker.updatedAt,
      shareUrl: shareUrl,
      onCopyShareUrl: copyShareUrl,
      onShowQrCode: () => showMarkerQrDialog(context: context, marker: marker),
      contentWidth: isWeatherStationMarker(marker) ? 560 : 520,
      additionalActions: [
        if (canAddToGeocoding)
          TextButton.icon(
            onPressed: () async {
              await submitGeocodingContribution(
                context: context,
                ref: ref,
                name: marker.name,
                latitude: marker.latitude,
                longitude: marker.longitude,
                notes: marker.notes,
              );
            },
            icon: const Icon(Icons.public),
            label: Text(l10n.mapAddToGeocodingSearch),
          ),
        if (unsyncedOffline)
          TextButton.icon(
            onPressed: () async {
              final deleted = await ref
                  .read(offlinePackControllerProvider)
                  .deleteUnsyncedMarker(marker.id);
              if (!context.mounted || !deleted) {
                return;
              }
              ref.read(selectedMapObjectProvider.notifier).clear();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.offlineDeleteUnsyncedMarker),
          ),
      ],
      children: [
        if (isWeatherStationMarker(marker))
          WeatherStationDetailsSection(marker: marker),
        MarkerRadioDetailsSection(marker: marker),
        MarkerInventoryDetailsSection(marker: marker),
        MarkerChecklistsDetailsSection(marker: marker),
        MarkerAttachmentsDetailsSection(marker: marker),
        MarkerTrackingDetailsSection(marker: marker),
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: isWeatherStationMarker(marker)
              ? localizedMarkerIconLabel(l10n, marker.icon)
              : l10n.mapObjectTypeMarker,
        ),
        _DetailRow(
          label: l10n.mapMarkerIdLabel,
          value: marker.id.toString(),
          onCopy: () => copyTextWithFeedback(
            context,
            text: marker.id.toString(),
            copiedMessage: l10n.mapMarkerIdCopied,
          ),
          copyTooltip: l10n.mapMarkerCopyIdTooltip,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailCoordinates,
          value: formatCoordinates(marker.latitude, marker.longitude),
          onCopy: () => copyCoordinatesToClipboard(
            context,
            LatLng(marker.latitude, marker.longitude),
          ),
          copyTooltip: l10n.mapRadialCopyCoordinates,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailMgrs,
          value: mgrs ?? l10n.mapObjectDetailMgrsUnavailable,
          onCopy: mgrs == null
              ? null
              : () => copyTextWithFeedback(
                  context,
                  text: mgrs,
                  copiedMessage: l10n.mapMgrsCopied,
                ),
          copyTooltip: l10n.mapMgrsCopyTooltip,
        ),
        _MarkerShareLinkSection(
          label: l10n.mapMarkerShareUrlLabel,
          url: shareUrl,
          copyLabel: l10n.mapMarkerCopyUrlTooltip,
          onCopy: copyShareUrl,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailElevation,
          value: _formatElevation(marker.elevation),
        ),
        _DemElevationRow(
          point: LatLng(marker.latitude, marker.longitude),
          l10n: l10n,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: marker.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        LayerAssignmentRow(
          layerId: marker.layerId,
          onChanged: (layerId) => updateMarkerLayer(
            ref,
            marker: marker,
            layerId: layerId,
          ),
        ),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _buildZoneDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    MeasurementUnits measurementUnits,
  ) {
    final zonesAsync = ref.watch(zonesProvider);
    final zone = zonesAsync.valueOrNull == null
        ? null
        : findZoneById(zonesAsync.valueOrNull!, selection.id);

    if (zone == null) {
      return _loadingOrMissingDialog(
        context: context,
        theme: theme,
        l10n: l10n,
        loading: zonesAsync.isLoading,
        onEdit: onEdit,
      );
    }

    return switch (zone.type) {
      lineZoneType => _lineDetails(
        context: context,
        ref: ref,
        zone: zone,
        l10n: l10n,
        measurementUnits: measurementUnits,
      ),
      circleZoneType => _circleDetails(
        ref: ref,
        zone: zone,
        l10n: l10n,
        measurementUnits: measurementUnits,
      ),
      rectangleZoneType => _rectangleDetails(
        ref: ref,
        zone: zone,
        l10n: l10n,
        measurementUnits: measurementUnits,
      ),
      polygonZoneType => _polygonDetails(
        ref: ref,
        zone: zone,
        l10n: l10n,
      ),
      evacKitZoneType => _evacKitDetails(
        context: context,
        ref: ref,
        zone: zone,
        l10n: l10n,
        measurementUnits: measurementUnits,
      ),
      trackZoneType => _trackDetails(
        context: context,
        ref: ref,
        zone: zone,
        l10n: l10n,
        measurementUnits: measurementUnits,
      ),
      _ => _genericZoneDetails(ref: ref, zone: zone, l10n: l10n),
    };
  }

  Widget _zoneLayerAssignment(WidgetRef ref, MapZone zone) {
    return LayerAssignmentRow(
      layerId: zone.layerId,
      onChanged: (layerId) => updateZoneLayer(
        ref,
        zone: zone,
        layerId: layerId,
      ),
    );
  }

  Widget _lineDetails({
    required BuildContext context,
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
    }

    final notes = geometry.notes?.trim();
    final distance = formatLineDistance(
      geometry.pathLengthMeters,
      measurementUnits,
    );

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        icon: Icons.timeline,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      additionalActions: [
        TextButton.icon(
          onPressed: () {
            unawaited(
              showPathProfileDialog(
                context: context,
                ref: ref,
                title: zone.name,
                pathPoints: geometry.points,
              ),
            );
          },
          icon: const Icon(Icons.terrain),
          label: Text(l10n.elevationProfileButton),
        ),
      ],
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: l10n.mapObjectTypeLine,
        ),
        _DetailRow(label: l10n.mapObjectDetailLength, value: distance),
        _DetailRow(
          label: l10n.mapObjectDetailStart,
          value: _formatLatLng(geometry.start!),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailEnd,
          value: _formatLatLng(geometry.end!),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _trackDetails({
    required BuildContext context,
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = TrackGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
    }

    final distance = geometry.hasRenderablePath
        ? formatLineDistance(
            lineLengthMetersForPoints(geometry.pathPoints),
            measurementUnits,
          )
        : '—';

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        transportationMode: geometry.transportationMode,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      additionalActions: geometry.hasRenderablePath
          ? [
              TextButton.icon(
                onPressed: () {
                  unawaited(
                    showPathProfileDialog(
                      context: context,
                      ref: ref,
                      title: zone.name,
                      pathPoints: geometry.pathPoints,
                    ),
                  );
                },
                icon: const Icon(Icons.terrain),
                label: Text(l10n.elevationProfileButton),
              ),
            ]
          : const [],
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: l10n.mapObjectTypeTrack,
        ),
        _DetailRow(
          label: l10n.trackTransportationModeLabel,
          value: geometry.transportationMode.label(l10n),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailPointCount,
          value: geometry.points.length.toString(),
        ),
        _DetailRow(label: l10n.mapObjectDetailLength, value: distance),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
      ],
    );
  }

  Widget _circleDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
    }

    final notes = geometry.notes?.trim();
    final radius = formatCircleSize(
      geometry.radiusMeters,
      measurementUnits,
      CircleSizeDisplay.radius,
    );
    final diameter = formatCircleSize(
      geometry.radiusMeters,
      measurementUnits,
      CircleSizeDisplay.diameter,
    );
    final mapLabel = formatCircleSizeForMapLabel(
      geometry.radiusMeters,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.borderColor),
        icon: Icons.radio_button_unchecked,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: geometry.rangeRing == null
              ? l10n.mapObjectTypeCircle
              : l10n.mapObjectTypeRangeRing,
        ),
        if (geometry.rangeRing case final rangeRing?) ...[
          _DetailRow(
            label: l10n.rangeRingModeLabel,
            value: rangeRing.mode.label(l10n),
          ),
          _DetailRow(
            label: l10n.rangeRingBasisLabel,
            value: switch (rangeRing.basis) {
              RangeRingBasis.duration => l10n.rangeRingBasisDuration,
              RangeRingBasis.fuel => l10n.rangeRingBasisFuel,
            },
          ),
          if (rangeRing.durationHours != null)
            _DetailRow(
              label: l10n.rangeRingDurationHoursLabel,
              value: l10n.rangeRingDetailDurationHours(
                _trimDetailNumber(rangeRing.durationHours!),
              ),
            ),
          if (rangeRing.fuelLiters != null)
            _DetailRow(
              label: l10n.rangeRingFuelAmountLabel,
              value: l10n.rangeRingDetailFuelLiters(
                _trimDetailNumber(rangeRing.fuelLiters!),
              ),
            ),
        ],
        _DetailRow(label: l10n.mapObjectDetailRadius, value: radius),
        _DetailRow(label: l10n.mapObjectDetailDiameter, value: diameter),
        _DetailRow(
          label: l10n.mapObjectDetailCenter,
          value: _formatLatLng(geometry.center),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailMapLabel,
          value: mapLabel ?? l10n.mapObjectMapLabelNone,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _rectangleDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = RectangleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
    }

    final notes = geometry.notes?.trim();
    final dimensions = formatRectangleDimensions(
      geometry.bounds,
      measurementUnits,
    );
    final area = formatRectangleArea(geometry.bounds, measurementUnits);
    final mapLabel = formatRectangleSizeForMapLabel(
      geometry.bounds,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.borderColor),
        icon: Icons.crop_square,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: switch (geometry.creationMode) {
            RectangleCreationMode.centerExtent => l10n.rectangleModeCenter,
            RectangleCreationMode.corners => l10n.rectangleModeCorners,
          },
        ),
        _DetailRow(label: l10n.mapObjectDetailDimensions, value: dimensions),
        _DetailRow(label: l10n.mapObjectDetailArea, value: area),
        _DetailRow(
          label: l10n.mapObjectDetailCenter,
          value: _formatLatLng(geometry.bounds.center),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailMapLabel,
          value: mapLabel ?? l10n.mapObjectMapLabelNone,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _polygonDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
  }) {
    final geometry = PolygonGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
    }

    final notes = geometry.notes?.trim();
    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.borderColor),
        icon: Icons.polyline,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: l10n.mapObjectTypePolygon,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVertices,
          value: '${geometry.points.length}',
        ),
        _DetailRow(
          label: l10n.mapObjectDetailCenter,
          value: _formatLatLng(geometry.labelPoint),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _evacKitDetails({
    required BuildContext context,
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = EvacKitGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
    }

    final notes = geometry.notes?.trim();
    final theme = Theme.of(context);

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        icon: Icons.route,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      additionalActions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            beginEvacKitAlternateDrawing(ref: ref, zone: zone);
          },
          icon: const Icon(Icons.alt_route),
          label: Text(l10n.evacKitAddAlternate),
        ),
        if (_isWaterEvacMode(geometry.defaultMode))
          TextButton.icon(
            onPressed: () {
              final point = _evacKitTideQueryPoint(geometry);
              Navigator.of(context).pop();
              if (point == null) {
                return;
              }
              unawaited(
                showTideTablesAtPoint(
                  context: context,
                  ref: ref,
                  mapPoint: point,
                ),
              );
            },
            icon: const Icon(Icons.waves),
            label: Text(l10n.tidesOpenFromEvac),
          ),
      ],
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: l10n.mapObjectTypeEvacKit,
        ),
        _DetailRow(
          label: l10n.evacKitDefaultModeLabel,
          value: geometry.defaultMode.label(l10n),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        const SizedBox(height: 8),
        Text(
          l10n.evacKitRoutesLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final route in geometry.routes) ...[
          _EvacKitRouteSection(
            route: route,
            isPrimary: route.id == geometry.primaryRouteId,
            canRemove: geometry.routes.length > 1,
            defaultMode: geometry.defaultMode,
            measurementUnits: measurementUnits,
            l10n: l10n,
            onEditOnMap: () {
              Navigator.of(context).pop();
              beginEvacKitRouteEditing(
                ref: ref,
                zone: zone,
                routeId: route.id,
              );
            },
            onMakePrimary: route.id == geometry.primaryRouteId
                ? null
                : () => unawaited(
                    _makeEvacKitPrimary(
                      context: context,
                      ref: ref,
                      zone: zone,
                      geometry: geometry,
                      routeId: route.id,
                    ),
                  ),
            onRemove: geometry.routes.length <= 1
                ? null
                : () => unawaited(
                    _removeEvacKitRoute(
                      context: context,
                      ref: ref,
                      zone: zone,
                      geometry: geometry,
                      routeId: route.id,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
        ],
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _genericZoneDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
  }) {
    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        icon: Icons.layers,
      ),
      onEdit: onEdit,
      l10n: l10n,
      linkedZoneId: zone.id,
      createdByUsername: zone.createdByUsername,
      updatedByUsername: zone.updatedByUsername,
      createdAt: zone.createdAt,
      updatedAt: zone.updatedAt,
      children: [
        _DetailRow(label: l10n.mapObjectDetailType, value: zone.type),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
      ],
    );
  }

  Widget _loadingOrMissingDialog({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required bool loading,
    required VoidCallback onEdit,
  }) {
    return AlertDialog(
      title: Text(l10n.mapObjectDetailsTitle),
      content: Text(
        loading ? l10n.mapObjectDetailsLoading : l10n.mapObjectDetailsNotFound,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        if (!loading)
          TextButton(
            onPressed: onEdit,
            child: Text(l10n.actionEdit),
          ),
      ],
    );
  }
}

class _DetailsDialogShell extends StatelessWidget {
  const _DetailsDialogShell({
    required this.title,
    required this.leading,
    required this.l10n,
    required this.children,
    this.onEdit,
    this.linkedMarkerId,
    this.linkedZoneId,
    this.shareUrl,
    this.onCopyShareUrl,
    this.onShowQrCode,
    this.contentWidth = 520,
    this.additionalActions = const [],
    this.createdByUsername,
    this.updatedByUsername,
    this.createdAt,
    this.updatedAt,
  });

  final String title;
  final Widget leading;
  final VoidCallback? onEdit;
  final AppLocalizations l10n;
  final List<Widget> children;
  final UuidValue? linkedMarkerId;
  final UuidValue? linkedZoneId;
  final String? shareUrl;
  final VoidCallback? onCopyShareUrl;
  final VoidCallback? onShowQrCode;
  final double contentWidth;
  final List<Widget> additionalActions;
  final String? createdByUsername;
  final String? updatedByUsername;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final createdLabel = _attributionLabel(
      username: createdByUsername,
      at: createdAt,
    );
    final updatedLabel = _attributionLabel(
      username: updatedByUsername,
      at: updatedAt,
    );

    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
      content: SizedBox(
        width: contentWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (linkedMarkerId != null || linkedZoneId != null)
                WatchLogDetailsSection(
                  markerId: linkedMarkerId,
                  zoneId: linkedZoneId,
                ),
              ...children,
              if (createdLabel != null)
                _DetailRow(
                  label: l10n.mapObjectCreatedBy,
                  value: createdLabel,
                ),
              if (updatedLabel != null)
                _DetailRow(
                  label: l10n.mapObjectUpdatedBy,
                  value: updatedLabel,
                ),
            ],
          ),
        ),
      ),
      actions: [
        ...additionalActions,
        if (shareUrl != null && onCopyShareUrl != null)
          TextButton.icon(
            onPressed: onCopyShareUrl,
            icon: const Icon(Icons.link),
            label: Text(l10n.mapMarkerCopyUrlTooltip),
          ),
        if (onShowQrCode != null)
          TextButton.icon(
            onPressed: onShowQrCode,
            icon: const Icon(Icons.qr_code_2),
            label: Text(l10n.mapMarkerQrButton),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        if (onEdit != null)
          FilledButton(
            onPressed: onEdit,
            child: Text(l10n.actionEdit),
          ),
      ],
    );
  }

  String? _attributionLabel({
    required String? username,
    required DateTime? at,
  }) {
    final name = username?.trim();
    final hasName = name != null && name.isNotEmpty;
    if (!hasName && at == null) {
      return null;
    }
    final who = hasName ? name : l10n.mapObjectAttributionUnknown;
    if (at == null) {
      return who;
    }
    return '$who · ${at.toLocal()}';
  }
}

class _MarkerShareLinkSection extends StatelessWidget {
  const _MarkerShareLinkSection({
    required this.label,
    required this.url,
    required this.copyLabel,
    required this.onCopy,
  });

  final String label;
  final String url;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            url,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.link, size: 18),
              label: Text(copyLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.onCopy,
    this.copyTooltip,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;
  final String? copyTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: onCopy != null
                ? SelectableText(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          if (onCopy != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              tooltip: copyTooltip,
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
            ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.l10n, required this.markdown});

  final AppLocalizations l10n;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.formNotesLabel,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: MapObjectMarkdownBody(markdown: markdown),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemElevationRow extends ConsumerWidget {
  const _DemElevationRow({
    required this.point,
    required this.l10n,
  });

  final LatLng point;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(measurementUnitsProvider);
    final demEntriesAsync = ref.watch(elevationDemEntriesProvider);
    final elevationAsync = ref.watch(elevationAtProvider(point));
    final value = demEntriesAsync.when(
      loading: () => '…',
      error: (_, _) => l10n.elevationDemUnavailable,
      data: (entries) {
        if (entries.isEmpty) {
          return l10n.elevationNoDemAvailable;
        }
        return elevationAsync.when(
          data: (meters) => meters == null
              ? l10n.elevationDemUnavailable
              : formatElevationMeters(meters, units),
          loading: () => '…',
          error: (_, _) => l10n.elevationDemUnavailable,
        );
      },
    );
    return _DetailRow(
      label: l10n.elevationDemLabel,
      value: value,
    );
  }
}

class _ZoneTypeAvatar extends StatelessWidget {
  const _ZoneTypeAvatar({
    required this.color,
    this.icon,
    this.transportationMode,
  }) : assert(icon != null || transportationMode != null);

  final Color color;
  final IconData? icon;
  final TrackTransportationMode? transportationMode;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 18,
      child: transportationMode != null
          ? TrackTransportationIcon(
              transportationMode!,
              size: 18,
              color: Colors.white,
            )
          : Icon(icon!, color: Colors.white, size: 18),
    );
  }
}

class _EvacKitRouteSection extends StatelessWidget {
  const _EvacKitRouteSection({
    required this.route,
    required this.isPrimary,
    required this.canRemove,
    required this.defaultMode,
    required this.measurementUnits,
    required this.l10n,
    required this.onEditOnMap,
    this.onMakePrimary,
    this.onRemove,
  });

  final EvacRoute route;
  final bool isPrimary;
  final bool canRemove;
  final TrackTransportationMode defaultMode;
  final MeasurementUnits measurementUnits;
  final AppLocalizations l10n;
  final VoidCallback onEditOnMap;
  final VoidCallback? onMakePrimary;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lengthMeters = evacRouteLengthMeters(route);
    final distance = formatLineDistance(lengthMeters, measurementUnits);
    final defaultEta = formatEvacDuration(
      evacRouteDuration(lengthMeters: lengthMeters, mode: defaultMode),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    isPrimary
                        ? l10n.evacKitPrimaryBadge
                        : l10n.evacKitAlternateBadge,
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: canRemove && !isPrimary
                        ? l10n.evacKitRemoveAlternate
                        : l10n.evacKitRemoveRoute,
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: l10n.evacKitWaypointsLabel,
              value: '${route.waypoints.length}',
            ),
            _DetailRow(
              label: l10n.evacKitDistanceLabel,
              value: distance,
            ),
            _DetailRow(
              label: l10n.evacKitEtaLabel,
              value: '${defaultMode.label(l10n)}: $defaultEta',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final mode in evacKitEtaModes)
                  Chip(
                    avatar: TrackTransportationIcon(mode, size: 16),
                    label: Text(
                      formatEvacDuration(
                        evacRouteDuration(
                          lengthMeters: lengthMeters,
                          mode: mode,
                        ),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: onEditOnMap,
                  icon: const Icon(Icons.edit_road),
                  label: Text(l10n.evacKitEditRouteOnMap),
                ),
                if (onMakePrimary != null)
                  TextButton.icon(
                    onPressed: onMakePrimary,
                    icon: const Icon(Icons.star_outline),
                    label: Text(l10n.evacKitMakePrimary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _makeEvacKitPrimary({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
  required EvacKitGeometry geometry,
  required String routeId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final route = geometry.routes
      .where((entry) => entry.id == routeId)
      .firstOrNull;
  if (route == null) {
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.evacKitMakePrimary),
        content: Text(l10n.evacKitMakePrimaryConfirm(route.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.evacKitMakePrimary),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) {
    return;
  }
  final client = ref.read(serverClientProvider);
  await client.mapZone.updateZone(
    updateZoneEvacKitGeometry(zone, geometry.withPrimaryRoute(routeId)),
  );
  ref.read(zonesProvider.notifier).reload();
}

Future<void> _removeEvacKitRoute({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
  required EvacKitGeometry geometry,
  required String routeId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  if (geometry.routes.length <= 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.evacKitCannotRemoveLastRoute)),
    );
    return;
  }

  final isPrimary = routeId == geometry.primaryRouteId;
  final alternates = [
    for (final route in geometry.routes)
      if (route.id != geometry.primaryRouteId) route,
  ];

  String? newPrimaryRouteId;
  if (isPrimary) {
    if (alternates.length == 1) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.evacKitRemoveRoute),
            content: Text(
              l10n.evacKitRemovePrimarySingleConfirm(alternates.first.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.actionDelete),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
      newPrimaryRouteId = alternates.first.id;
    } else {
      newPrimaryRouteId = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return SimpleDialog(
            title: Text(l10n.evacKitChooseNewPrimary),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(l10n.evacKitRemovePrimaryConfirm),
              ),
              for (final route in alternates)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(route.id),
                  child: Text(route.name),
                ),
              SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionCancel),
              ),
            ],
          );
        },
      );
      if (newPrimaryRouteId == null) {
        return;
      }
    }
  } else {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.evacKitRemoveAlternate),
          content: Text(l10n.evacKitRemoveAlternateConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
  }

  if (!context.mounted) {
    return;
  }
  final next = geometry.withoutRoute(
    routeId,
    newPrimaryRouteId: newPrimaryRouteId,
  );
  if (next == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.evacKitCannotRemoveLastRoute)),
    );
    return;
  }
  final client = ref.read(serverClientProvider);
  await client.mapZone.updateZone(
    updateZoneEvacKitGeometry(zone, next),
  );
  ref.read(zonesProvider.notifier).reload();
}

bool _isWaterEvacMode(TrackTransportationMode mode) {
  return switch (mode) {
    TrackTransportationMode.canoe ||
    TrackTransportationMode.watercraft ||
    TrackTransportationMode.sailboat => true,
    _ => false,
  };
}

LatLng? _evacKitTideQueryPoint(EvacKitGeometry geometry) {
  final route = geometry.primaryRoute;
  if (route == null || route.waypoints.isEmpty) {
    return null;
  }
  final mid = route.waypoints[route.waypoints.length ~/ 2];
  return mid.point;
}

String _trimDetailNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}

String _formatElevation(double elevation) {
  if (elevation == elevation.roundToDouble()) {
    return '${elevation.toInt()} m';
  }
  return '${elevation.toStringAsFixed(1)} m';
}

String _formatLatLng(LatLng point) {
  return formatLatLng(point);
}

/// Spaced MGRS for [point], or null outside the supported band / on conversion failure.
String? _mgrsForLatLng(LatLng point) {
  try {
    return formatMgrs(latLngToMgrs(point, accuracy: 5));
  } catch (_) {
    return null;
  }
}
