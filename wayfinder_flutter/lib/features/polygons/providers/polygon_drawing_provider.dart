import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_snap.dart';

enum PolygonDrawingPurpose { mapZone, seasonalOverlay }

class PolygonDrawingState {
  const PolygonDrawingState({
    this.active = false,
    this.purpose = PolygonDrawingPurpose.mapZone,
    this.points = const [],
    this.previewPoint,
  });

  final bool active;
  final PolygonDrawingPurpose purpose;
  final List<LatLng> points;
  final LatLng? previewPoint;

  bool get canFinish => active && points.length >= 3;

  PolygonDrawingState copyWith({
    bool? active,
    PolygonDrawingPurpose? purpose,
    List<LatLng>? points,
    LatLng? previewPoint,
    bool clearPreviewPoint = false,
  }) {
    return PolygonDrawingState(
      active: active ?? this.active,
      purpose: purpose ?? this.purpose,
      points: points ?? this.points,
      previewPoint: clearPreviewPoint
          ? null
          : previewPoint ?? this.previewPoint,
    );
  }
}

final polygonDrawingProvider =
    StateNotifierProvider<PolygonDrawingNotifier, PolygonDrawingState>(
      (ref) => PolygonDrawingNotifier(),
    );

class PolygonDrawingNotifier extends StateNotifier<PolygonDrawingState> {
  PolygonDrawingNotifier() : super(const PolygonDrawingState());

  void begin({
    LatLng? firstPoint,
    PolygonDrawingPurpose purpose = PolygonDrawingPurpose.mapZone,
  }) {
    state = PolygonDrawingState(
      active: true,
      purpose: purpose,
      points: firstPoint == null ? const [] : [firstPoint],
    );
  }

  void addVertex(LatLng point) {
    if (!state.active) {
      return;
    }
    final points = state.points;
    if (points.isNotEmpty &&
        areLinePointsTooClose(points.last, point, minMeters: 1)) {
      return;
    }
    state = state.copyWith(
      points: [...points, point],
      clearPreviewPoint: true,
    );
  }

  void undoLastVertex() {
    if (!state.active || state.points.isEmpty) {
      return;
    }
    final next = List<LatLng>.from(state.points)..removeLast();
    state = state.copyWith(points: next);
  }

  void setPreviewPoint(LatLng point) {
    if (!state.active || state.points.isEmpty) {
      return;
    }
    state = state.copyWith(previewPoint: point);
  }

  void reset() {
    state = const PolygonDrawingState();
  }
}
