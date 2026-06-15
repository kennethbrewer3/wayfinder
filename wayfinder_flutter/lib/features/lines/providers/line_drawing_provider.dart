import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class LineDrawingState {
  const LineDrawingState({
    this.active = false,
    this.start,
    this.previewEnd,
  });

  final bool active;
  final LatLng? start;
  final LatLng? previewEnd;

  bool get awaitingStart => active && start == null;

  bool get awaitingEnd => active && start != null;

  LineDrawingState copyWith({
    bool? active,
    LatLng? start,
    LatLng? previewEnd,
    bool clearStart = false,
    bool clearPreviewEnd = false,
  }) {
    return LineDrawingState(
      active: active ?? this.active,
      start: clearStart ? null : start ?? this.start,
      previewEnd: clearPreviewEnd ? null : previewEnd ?? this.previewEnd,
    );
  }
}

final lineDrawingProvider =
    StateNotifierProvider<LineDrawingNotifier, LineDrawingState>(
  (ref) => LineDrawingNotifier(),
);

class LineDrawingNotifier extends StateNotifier<LineDrawingState> {
  LineDrawingNotifier() : super(const LineDrawingState());

  void begin() {
    state = const LineDrawingState(active: true);
  }

  void setStart(LatLng point) {
    state = LineDrawingState(active: true, start: point);
  }

  void setPreviewEnd(LatLng point) {
    if (!state.active || state.start == null) {
      return;
    }
    state = state.copyWith(previewEnd: point);
  }

  void reset() {
    state = const LineDrawingState();
  }
}
