import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/providers/map_providers.dart';
import '../../route_follow/providers/route_follow_provider.dart';
import '../models/routing_models.dart';

/// The most recently computed A→B route, held for the map overlay + HUD.
///
/// Session-only: cleared on app restart and never sent to the server.
class RoutingSessionState {
  const RoutingSessionState({
    this.result,
    this.profile = RoutingProfile.foot,
    this.destinationLabel,
  });

  final RoutingResult? result;
  final RoutingProfile profile;
  final String? destinationLabel;

  bool get hasRoute => result != null;
}

final routingSessionProvider =
    StateNotifierProvider<RoutingSessionNotifier, RoutingSessionState>(
      (ref) => RoutingSessionNotifier(ref),
    );

class RoutingSessionNotifier extends StateNotifier<RoutingSessionState> {
  RoutingSessionNotifier(this._ref) : super(const RoutingSessionState());

  final Ref _ref;

  void setRoute({
    required RoutingResult result,
    RoutingProfile profile = RoutingProfile.foot,
    String? destinationLabel,
  }) {
    // A new A→B route must not keep following/simulating the previous path.
    _stopActiveFollow();
    state = RoutingSessionState(
      result: result,
      profile: profile,
      destinationLabel: destinationLabel,
    );
    // Surface directions in the panel immediately after Route here.
    _ref.read(sidebarProvider.notifier).setExpanded(true);
  }

  void clear() {
    _stopActiveFollow();
    state = const RoutingSessionState();
  }

  void _stopActiveFollow() {
    if (!_ref.read(routeFollowProvider).active) {
      return;
    }
    _ref.read(routeFollowProvider.notifier).stop();
  }
}
