import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../elevation/providers/elevation_providers.dart';
import '../../elevation/utils/elevation_format.dart';
import '../../lines/providers/bearing_reference_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../tracks/providers/gps_track_binding_provider.dart';
import '../providers/device_location_provider.dart';
import '../providers/map_mgrs_grid_provider.dart';
import '../providers/selected_map_object_provider.dart';
import '../utils/device_location_readout.dart';
import '../utils/magnetic_declination.dart';

/// Compact GPS status: current position, plus range/bearing to a selected marker.
class MapDeviceLocationHud extends ConsumerWidget {
  const MapDeviceLocationHud({
    super.key,
    required this.zoom,
  });

  final double zoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final location = ref.watch(deviceLocationProvider);
    final point = location.position;
    if (!location.tracking || point == null) {
      return const SizedBox.shrink();
    }

    final showMgrs = ref.watch(mapMgrsGridEnabledProvider);
    final units = ref.watch(measurementUnitsProvider);
    final bearingReference = ref.watch(bearingReferenceProvider);
    final selection = ref.watch(selectedMapObjectProvider);
    final markers = ref.watch(markersProvider).valueOrNull ?? const [];
    final boundMarkerId = ref.watch(gpsTrackBindingProvider);
    String? recordingTrailName;
    if (boundMarkerId != null) {
      for (final candidate in markers) {
        if (candidate.id == boundMarkerId) {
          recordingTrailName = candidate.name.trim().isEmpty
              ? l10n.mapDeviceLocationSelectedMarker
              : candidate.name.trim();
          break;
        }
      }
    }
    final target = selectedMarkerTarget(
      selection: selection,
      markers: markers,
    );
    final declination = magneticDeclinationDegrees(location: point);
    final hereElevation = ref.watch(elevationAtProvider(point)).valueOrNull;
    final targetElevation = target == null
        ? null
        : ref
              .watch(
                elevationAtProvider(
                  LatLng(target.latitude, target.longitude),
                ),
              )
              .valueOrNull;

    final positionText = formatDeviceLocationPosition(
      location: point,
      showMgrs: showMgrs,
      zoom: zoom,
    );

    String? rangeText;
    String? targetName;
    String? climbText;
    if (target != null) {
      targetName = target.name.trim().isEmpty
          ? l10n.mapDeviceLocationSelectedMarker
          : target.name.trim();
      rangeText = formatDeviceLocationRange(
        from: point,
        to: LatLng(target.latitude, target.longitude),
        units: units,
        bearingReference: bearingReference,
        declinationDegrees: declination,
      );
      if (hereElevation != null && targetElevation != null) {
        climbText = l10n.elevationClimbToMarker(
          targetName,
          formatElevationDeltaMeters(
            targetElevation - hereElevation,
            units,
          ),
        );
      }
    }

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  location.following ? Icons.gps_fixed : Icons.gps_not_fixed,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    hereElevation == null
                        ? positionText
                        : '$positionText · ${formatElevationMeters(hereElevation, units)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (recordingTrailName != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.mapDeviceLocationRecordingTrail(recordingTrailName),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              formatMagneticDeclination(declination),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (rangeText != null && targetName != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.mapDeviceLocationToMarker(targetName, rangeText),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (climbText != null) ...[
                const SizedBox(height: 2),
                Text(
                  climbText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(height: 2),
              Text(
                l10n.mapDeviceLocationSelectMarkerHint,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
