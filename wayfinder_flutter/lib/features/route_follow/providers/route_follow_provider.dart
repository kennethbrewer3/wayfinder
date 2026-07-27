import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../map/providers/device_location_provider.dart';
import '../../map/providers/simulated_gps_walk_delay_provider.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../utils/route_follow_progress.dart';

class RouteFollowState {
  const RouteFollowState({
    this.active = false,
    this.zoneId,
    this.routeName = '',
    this.path = const [],
    this.mode = TrackTransportationMode.onFoot,
    this.progress,
    this.simulating = false,
  });

  final bool active;
  final UuidValue? zoneId;
  final String routeName;
  final List<LatLng> path;
  final TrackTransportationMode mode;
  final RouteFollowProgress? progress;
  final bool simulating;

  bool get offRoute => progress?.isOffRoute ?? false;
  bool get completed => progress?.completed ?? false;

  RouteFollowState copyWith({
    bool? active,
    UuidValue? zoneId,
    String? routeName,
    List<LatLng>? path,
    TrackTransportationMode? mode,
    RouteFollowProgress? progress,
    bool? simulating,
    bool clearProgress = false,
  }) {
    return RouteFollowState(
      active: active ?? this.active,
      zoneId: zoneId ?? this.zoneId,
      routeName: routeName ?? this.routeName,
      path: path ?? this.path,
      mode: mode ?? this.mode,
      progress: clearProgress ? null : (progress ?? this.progress),
      simulating: simulating ?? this.simulating,
    );
  }
}

final routeFollowProvider =
    StateNotifierProvider<RouteFollowNotifier, RouteFollowState>(
      (ref) => RouteFollowNotifier(ref),
    );

class RouteFollowNotifier extends StateNotifier<RouteFollowState> {
  RouteFollowNotifier(this._ref) : super(const RouteFollowState()) {
    _ref.listen<DeviceLocationState>(deviceLocationProvider, (previous, next) {
      if (!state.active) {
        return;
      }
      final position = next.position;
      if (position == null) {
        return;
      }
      _updateProgress(position);
    });
  }

  final Ref _ref;
  var _wasOffRoute = false;

  Future<bool> start({
    required UuidValue zoneId,
    required String routeName,
    required List<LatLng> path,
    TrackTransportationMode mode = TrackTransportationMode.onFoot,
  }) async {
    if (path.length < 2) {
      return false;
    }
    final ok = await _ref
        .read(deviceLocationProvider.notifier)
        .locateAndFollow();
    state = RouteFollowState(
      active: true,
      zoneId: zoneId,
      routeName: routeName,
      path: List<LatLng>.from(path),
      mode: mode,
    );
    _wasOffRoute = false;
    final position = _ref.read(deviceLocationProvider).position;
    if (position != null) {
      _updateProgress(position);
    }
    return ok || _ref.read(deviceLocationProvider).tracking;
  }

  /// Desk-test: fake GPS along the active route (no walking required).
  Future<void> startSimulation() async {
    if (!state.active || state.path.length < 2) {
      return;
    }
    final stepInterval = Duration(
      milliseconds: _ref.read(simulatedGpsWalkDelayMsProvider),
    );
    await _ref
        .read(deviceLocationProvider.notifier)
        .startSimulatedWalkAlong(
          state.path,
          stepInterval: stepInterval,
          onCompleted: () {
            if (state.active) {
              state = state.copyWith(simulating: false);
            }
          },
        );
    state = state.copyWith(simulating: true);
  }

  void stopSimulation() {
    _ref.read(deviceLocationProvider.notifier).stopSimulation();
    state = state.copyWith(simulating: false);
  }

  void stop() {
    _ref.read(deviceLocationProvider.notifier).stopSimulation();
    state = const RouteFollowState();
    _wasOffRoute = false;
  }

  void _updateProgress(LatLng position) {
    final progress = computeRouteFollowProgress(
      path: state.path,
      position: position,
    );
    if (progress == null) {
      return;
    }
    final offRoute = progress.isOffRoute;
    if (offRoute && !_wasOffRoute) {
      HapticFeedback.heavyImpact();
    } else if (!offRoute && _wasOffRoute) {
      HapticFeedback.selectionClick();
    }
    _wasOffRoute = offRoute;
    state = state.copyWith(progress: progress);
  }
}
