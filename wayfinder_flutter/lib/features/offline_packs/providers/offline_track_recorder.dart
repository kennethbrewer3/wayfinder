import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/providers/device_location_provider.dart';
import 'offline_pack_controller.dart';
import 'server_reachability_provider.dart';

/// While offline, append GPS fixes to tracking markers in the pack outbox.
final offlineTrackRecorderProvider = Provider<void>((ref) {
  ref.listen<DeviceLocationState>(deviceLocationProvider, (previous, next) {
    if (!ref.read(offlineModeActiveProvider)) {
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
    ref
        .read(offlinePackControllerProvider)
        .appendGpsToTrackingMarkers(position);
  });
});
