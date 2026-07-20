import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// One-shot intent: map canvas enters route edit for this kit/route.
class EvacKitRouteEditIntent {
  const EvacKitRouteEditIntent({
    required this.kitId,
    required this.routeId,
  });

  final UuidValue kitId;
  final String routeId;
}

final evacKitRouteEditIntentProvider =
    StateProvider<EvacKitRouteEditIntent?>((ref) => null);
