import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class CircleDrawingState {
  const CircleDrawingState({
    this.active = false,
    this.center,
    this.previewRadiusMeters,
  });

  final bool active;
  final LatLng? center;
  final double? previewRadiusMeters;

  bool get awaitingCenter => active && center == null;

  bool get awaitingRadius => active && center != null;

  CircleDrawingState copyWith({
    bool? active,
    LatLng? center,
    double? previewRadiusMeters,
    bool clearCenter = false,
    bool clearPreviewRadius = false,
  }) {
    return CircleDrawingState(
      active: active ?? this.active,
      center: clearCenter ? null : center ?? this.center,
      previewRadiusMeters:
          clearPreviewRadius ? null : previewRadiusMeters ?? this.previewRadiusMeters,
    );
  }
}

final circleDrawingProvider =
    StateNotifierProvider<CircleDrawingNotifier, CircleDrawingState>(
  (ref) => CircleDrawingNotifier(),
);

class CircleDrawingNotifier extends StateNotifier<CircleDrawingState> {
  CircleDrawingNotifier() : super(const CircleDrawingState());

  void begin() {
    state = const CircleDrawingState(active: true);
  }

  void setCenter(LatLng point) {
    state = CircleDrawingState(active: true, center: point);
  }

  void setPreviewRadius(double radiusMeters) {
    if (!state.active || state.center == null) {
      return;
    }
    state = state.copyWith(previewRadiusMeters: radiusMeters);
  }

  void reset() {
    state = const CircleDrawingState();
  }
}
