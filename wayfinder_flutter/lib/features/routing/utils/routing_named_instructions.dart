import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_distance.dart';
import '../../route_follow/providers/route_follow_provider.dart';
import '../models/routing_models.dart';

/// Converts GraphHopper [instructions] into HUD-ready named instructions,
/// resolving each instruction's `interval` (point index range) into a
/// cumulative distance along [path] (the same points used for route-follow
/// progress tracking).
List<RouteFollowNamedInstruction> buildRouteFollowNamedInstructions({
  required List<RoutingInstruction> instructions,
  required List<LatLng> path,
}) {
  if (instructions.isEmpty || path.length < 2) {
    return const [];
  }

  final cumulativeMeters = List<double>.filled(path.length, 0);
  for (var i = 1; i < path.length; i++) {
    cumulativeMeters[i] =
        cumulativeMeters[i - 1] + lineLengthMeters(path[i - 1], path[i]);
  }

  final result = <RouteFollowNamedInstruction>[];
  for (final instruction in instructions) {
    final text = instruction.text.trim();
    if (text.isEmpty) {
      continue;
    }
    final interval = instruction.interval;
    final startIndex = (interval != null && interval.isNotEmpty)
        ? interval.first
        : 0;
    final clampedIndex = startIndex.clamp(0, cumulativeMeters.length - 1);
    result.add(
      RouteFollowNamedInstruction(
        text: text,
        streetName: instruction.streetName,
        startDistanceMeters: cumulativeMeters[clampedIndex],
      ),
    );
  }
  return result;
}
