import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../access/providers/access_session_provider.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../lines/utils/line_distance.dart';
import '../../map/providers/device_location_provider.dart';
import '../../tracks/models/track_geometry.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../../tracks/presentation/track_transportation_icon.dart';
import '../../tracks/providers/gps_track_binding_provider.dart';

class MarkerTrackingDetailsSection extends ConsumerWidget {
  const MarkerTrackingDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!marker.isTracking) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final trackZone = marker.trackZoneId == null
        ? null
        : ref.watch(zonesProvider.notifier).zoneById(marker.trackZoneId!);
    final geometry = trackZone == null
        ? null
        : TrackGeometry.fromZone(trackZone);
    final mode = geometry?.transportationMode ?? TrackTransportationMode.onFoot;
    final boundId = ref.watch(gpsTrackBindingProvider);
    final recordingThis = boundId == marker.id;
    final editsLocked = ref.watch(mapEditsLockedByRoleProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.markerTrackingLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusChip(
                    label: recordingThis
                        ? l10n.markerTrackingStatusRecordingGps
                        : l10n.markerTrackingStatusActive,
                    color: recordingThis
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.surface.withValues(
                      alpha: 0.9,
                    ),
                    child: TrackTransportationIcon(
                      mode,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trackTransportationModeLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          mode.label(l10n),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (geometry != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _TrackingStat(
                      label: l10n.mapObjectDetailPointCount,
                      value: geometry.points.length.toString(),
                    ),
                    if (geometry.hasRenderablePath)
                      _TrackingStat(
                        label: l10n.mapObjectDetailLength,
                        value: formatLineDistance(
                          lineLengthMetersForPoints(geometry.pathPoints),
                          measurementUnits,
                        ),
                      ),
                  ],
                ),
              ],
              if (!editsLocked) ...[
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _toggleGpsRecording(context, ref),
                  icon: Icon(
                    recordingThis
                        ? Icons.stop_circle_outlined
                        : Icons.gps_fixed,
                  ),
                  label: Text(
                    recordingThis
                        ? l10n.markerTrackingStopGpsTrail
                        : l10n.markerTrackingStartGpsTrail,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.markerTrackingGpsTrailHelp,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleGpsRecording(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final binding = ref.read(gpsTrackBindingProvider.notifier);
    if (ref.read(gpsTrackBindingProvider) == marker.id) {
      binding.stopRecording();
      return;
    }

    final ok = await binding.startRecording(marker.id);
    if (!context.mounted) {
      return;
    }
    if (!ok) {
      final code = ref.read(deviceLocationProvider).errorMessage;
      final message = switch (DeviceLocationError.fromCode(code)) {
        DeviceLocationError.serviceDisabled =>
          l10n.mapDeviceLocationServiceDisabled,
        DeviceLocationError.permissionDenied =>
          l10n.mapDeviceLocationPermissionDenied,
        DeviceLocationError.permissionDeniedForever =>
          l10n.mapDeviceLocationPermissionDeniedForever,
        DeviceLocationError.unavailable ||
        null => l10n.mapDeviceLocationUnavailable,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TrackingStat extends StatelessWidget {
  const _TrackingStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

bool isWeatherStationMarker(MapMarker marker) =>
    marker.icon == 'weather_station';
