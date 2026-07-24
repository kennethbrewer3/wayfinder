import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../map/providers/device_location_provider.dart';

/// Marker id that device GPS should update while the user is moving.
///
/// When set, [gpsTrackRecorderProvider] pushes GPS fixes into that tracking
/// marker (online via `updateMarker`, offline via the pack outbox) so the
/// companion track zone grows a persistent trail.
final gpsTrackBindingProvider =
    StateNotifierProvider<GpsTrackBindingNotifier, UuidValue?>((ref) {
      return GpsTrackBindingNotifier(ref);
    });

class GpsTrackBindingNotifier extends StateNotifier<UuidValue?> {
  GpsTrackBindingNotifier(this._ref) : super(null) {
    _ref.listen<DeviceLocationState>(deviceLocationProvider, (previous, next) {
      if ((previous?.tracking ?? false) && !next.tracking) {
        state = null;
      }
    });
  }

  final Ref _ref;

  /// Bind GPS to [markerId] and start (or resume) the location stream.
  Future<bool> startRecording(UuidValue markerId) async {
    state = markerId;
    final ok = await _ref
        .read(deviceLocationProvider.notifier)
        .locateAndFollow();
    if (!ok) {
      state = null;
    }
    return ok;
  }

  /// Stop appending GPS to the marker without necessarily hiding My Location.
  void stopRecording() {
    state = null;
  }

  void bind(UuidValue markerId) {
    state = markerId;
  }

  void clear() {
    state = null;
  }
}
