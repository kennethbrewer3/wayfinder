import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/rectangle_geometry.dart';

class RectangleDrawingState {
  const RectangleDrawingState({
    this.active = false,
    this.mode,
    this.anchor,
    this.previewPoint,
  });

  final bool active;
  final RectangleCreationMode? mode;
  final LatLng? anchor;
  final LatLng? previewPoint;

  bool get awaitingSecondPoint => active && anchor != null;

  RectangleDrawingState copyWith({
    bool? active,
    RectangleCreationMode? mode,
    LatLng? anchor,
    LatLng? previewPoint,
    bool clearAnchor = false,
    bool clearPreviewPoint = false,
  }) {
    return RectangleDrawingState(
      active: active ?? this.active,
      mode: mode ?? this.mode,
      anchor: clearAnchor ? null : anchor ?? this.anchor,
      previewPoint:
          clearPreviewPoint ? null : previewPoint ?? this.previewPoint,
    );
  }
}

final rectangleDrawingProvider =
    StateNotifierProvider<RectangleDrawingNotifier, RectangleDrawingState>(
  (ref) => RectangleDrawingNotifier(),
);

class RectangleDrawingNotifier extends StateNotifier<RectangleDrawingState> {
  RectangleDrawingNotifier() : super(const RectangleDrawingState());

  void beginCenterExtent(LatLng center) {
    state = RectangleDrawingState(
      active: true,
      mode: RectangleCreationMode.centerExtent,
      anchor: center,
    );
  }

  void beginCorners(LatLng cornerA) {
    state = RectangleDrawingState(
      active: true,
      mode: RectangleCreationMode.corners,
      anchor: cornerA,
    );
  }

  void setPreviewPoint(LatLng point) {
    if (!state.active || state.anchor == null) {
      return;
    }
    state = state.copyWith(previewPoint: point);
  }

  void reset() {
    state = const RectangleDrawingState();
  }
}
