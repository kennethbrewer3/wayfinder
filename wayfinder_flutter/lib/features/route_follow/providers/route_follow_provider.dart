import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../map/providers/device_location_provider.dart';
import '../../map/providers/simulated_gps_walk_delay_provider.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../utils/route_follow_progress.dart';

/// A single named turn-by-turn step (e.g. from OSM routing), positioned by
/// cumulative distance along the followed [RouteFollowState.path].
class RouteFollowNamedInstruction {
  const RouteFollowNamedInstruction({
    required this.text,
    required this.startDistanceMeters,
    this.streetName,
  });

  final String text;
  final String? streetName;
  final double startDistanceMeters;
}

class RouteFollowState {
  const RouteFollowState({
    this.active = false,
    this.zoneId,
    this.routeName = '',
    this.path = const [],
    this.mode = TrackTransportationMode.onFoot,
    this.progress,
    this.simulating = false,
    this.namedInstructions = const [],
  });

  final bool active;
  final UuidValue? zoneId;
  final String routeName;
  final List<LatLng> path;
  final TrackTransportationMode mode;
  final RouteFollowProgress? progress;
  final bool simulating;

  /// Optional OSM turn-by-turn text (e.g. from the routing server), shown in
  /// the HUD in preference to geometry-only left/right cues when present.
  final List<RouteFollowNamedInstruction> namedInstructions;

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
    List<RouteFollowNamedInstruction>? namedInstructions,
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
      namedInstructions: namedInstructions ?? this.namedInstructions,
    );
  }
}

/// Finds the named instruction active at [traveledMeters], or null if
/// [instructions] is empty.
RouteFollowNamedInstruction? currentRouteFollowNamedInstruction(
  List<RouteFollowNamedInstruction> instructions,
  double traveledMeters,
) {
  if (instructions.isEmpty) {
    return null;
  }
  var current = instructions.first;
  for (final instruction in instructions) {
    if (instruction.startDistanceMeters <= traveledMeters + 0.5) {
      current = instruction;
    } else {
      break;
    }
  }
  return current;
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
    UuidValue? zoneId,
    required String routeName,
    required List<LatLng> path,
    TrackTransportationMode mode = TrackTransportationMode.onFoot,
    List<RouteFollowNamedInstruction> namedInstructions = const [],
  }) async {
    if (path.length < 2) {
      return false;
    }
    // Drop any prior simulated walk so we never keep walking an old path.
    _ref.read(deviceLocationProvider.notifier).stopSimulation();
    final ok = await _ref
        .read(deviceLocationProvider.notifier)
        .locateAndFollow();
    state = RouteFollowState(
      active: true,
      zoneId: zoneId,
      routeName: routeName,
      path: List<LatLng>.from(path),
      mode: mode,
      namedInstructions: namedInstructions,
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
