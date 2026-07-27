import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      (ref) => RoutingSessionNotifier(),
    );

class RoutingSessionNotifier extends StateNotifier<RoutingSessionState> {
  RoutingSessionNotifier() : super(const RoutingSessionState());

  void setRoute({
    required RoutingResult result,
    RoutingProfile profile = RoutingProfile.foot,
    String? destinationLabel,
  }) {
    state = RoutingSessionState(
      result: result,
      profile: profile,
      destinationLabel: destinationLabel,
    );
  }

  void clear() {
    state = const RoutingSessionState();
  }
}
