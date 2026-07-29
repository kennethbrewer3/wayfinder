import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../route_follow/providers/route_follow_provider.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../models/routing_models.dart';
import '../providers/routing_session_provider.dart';
import '../utils/routing_named_instructions.dart';

/// Maps a routing travel profile onto the follow HUD's transportation mode.
TrackTransportationMode transportationModeForRoutingProfile(
  RoutingProfile profile,
) {
  return switch (profile) {
    RoutingProfile.foot => TrackTransportationMode.onFoot,
    RoutingProfile.bike => TrackTransportationMode.bike,
    RoutingProfile.car => TrackTransportationMode.landVehicle,
  };
}

/// Starts route-follow for the active [routingSessionProvider] result.
///
/// Accepts a [ProviderContainer] so callers can survive dialog dispose (do not
/// pass a [WidgetRef] from a popped details sheet).
///
/// Returns `false` when there is no usable geometry (fewer than 2 points).
Future<bool> startFollowFromRoutingSession(
  ProviderContainer container, {
  bool simulate = false,
}) async {
  final session = container.read(routingSessionProvider);
  final result = session.result;
  if (result == null) {
    return false;
  }

  final path = [
    for (final point in result.points) LatLng(point.lat, point.lon),
  ];
  if (path.length < 2) {
    return false;
  }

  final namedInstructions = buildRouteFollowNamedInstructions(
    instructions: result.instructions,
    path: path,
  );
  final ok = await container
      .read(routeFollowProvider.notifier)
      .start(
        routeName: session.destinationLabel ?? '',
        path: path,
        mode: transportationModeForRoutingProfile(session.profile),
        namedInstructions: namedInstructions,
      );
  if (simulate) {
    await container.read(routeFollowProvider.notifier).startSimulation();
  }
  return ok;
}
