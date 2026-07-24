import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../map/providers/device_location_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../offline_packs/providers/offline_pack_controller.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../../lines/providers/zones_provider.dart';
import 'gps_track_binding_provider.dart';

const _minTrackMoveMeters = 5.0;
const _distance = Distance();

/// Pushes device GPS into the bound tracking marker while My Location is on.
///
/// Online: `mapMarker.updateMarker` (server appends the trail).
/// Offline: pack outbox append for the bound marker only.
final gpsTrackRecorderProvider = Provider<void>((ref) {
  var inFlight = false;
  LatLng? lastSent;

  ref.listen<DeviceLocationState>(deviceLocationProvider, (previous, next) {
    final boundId = ref.read(gpsTrackBindingProvider);
    if (boundId == null || !next.tracking) {
      return;
    }
    final position = next.position;
    if (position == null) {
      return;
    }
    if (previous?.position != null &&
        previous!.position!.latitude == position.latitude &&
        previous.position!.longitude == position.longitude) {
      return;
    }
    if (lastSent != null &&
        _distance.as(LengthUnit.Meter, lastSent!, position) <
            _minTrackMoveMeters) {
      return;
    }
    if (inFlight) {
      return;
    }

    inFlight = true;
    () async {
      try {
        if (ref.read(offlineModeActiveProvider)) {
          await ref
              .read(offlinePackControllerProvider)
              .appendGpsToTrackingMarkers(
                position,
                onlyMarkerId: boundId,
              );
          lastSent = position;
          return;
        }

        final markers = ref.read(markersProvider).valueOrNull;
        MapMarker? marker;
        if (markers != null) {
          for (final candidate in markers) {
            if (candidate.id == boundId) {
              marker = candidate;
              break;
            }
          }
        }
        if (marker == null ||
            !marker.isTracking ||
            marker.trackZoneId == null) {
          AppLogger.logMarkers.warn(
            '📍 GPS trail bind skipped — marker missing or not tracking',
            data: 'markerId=${boundId.uuid}',
          );
          ref.read(gpsTrackBindingProvider.notifier).clear();
          return;
        }

        final moved = _distance.as(
          LengthUnit.Meter,
          LatLng(marker.latitude, marker.longitude),
          position,
        );
        if (moved < _minTrackMoveMeters) {
          return;
        }

        final client = ref.read(serverClientProvider);
        await client.mapMarker.updateMarker(
          marker.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
        lastSent = position;
        ref.invalidate(markersProvider);
        ref.read(zonesProvider.notifier).reload();
      } catch (error, stackTrace) {
        AppLogger.logMarkers.error(
          '📍 Failed to record GPS trail point',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        inFlight = false;
      }
    }();
  });

  ref.listen<UuidValue?>(gpsTrackBindingProvider, (previous, next) {
    lastSent = null;
  });
});
