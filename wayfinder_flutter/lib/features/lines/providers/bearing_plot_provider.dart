import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../utils/bearing_utils.dart';
import '../utils/line_distance.dart';

class BearingPlotState {
  const BearingPlotState({
    this.active = false,
    this.awaitingPlotClick = false,
    this.anchor,
    this.referenceBearing,
    this.plotBearing,
    this.previewEnd,
    this.referenceLineId,
  });

  final bool active;
  final bool awaitingPlotClick;
  final LatLng? anchor;
  final double? referenceBearing;
  final double? plotBearing;
  final LatLng? previewEnd;
  final UuidValue? referenceLineId;

  double? get relativeBearing {
    final reference = referenceBearing;
    final plot = plotBearing;
    if (reference == null || plot == null) {
      return null;
    }
    return signedRelativeBearing(
      referenceBearing: reference,
      targetBearing: plot,
    );
  }

  BearingPlotState copyWith({
    bool? active,
    bool? awaitingPlotClick,
    LatLng? anchor,
    double? referenceBearing,
    double? plotBearing,
    LatLng? previewEnd,
    UuidValue? referenceLineId,
    bool clearAnchor = false,
    bool clearPreviewEnd = false,
    bool clearReferenceLineId = false,
  }) {
    return BearingPlotState(
      active: active ?? this.active,
      awaitingPlotClick: awaitingPlotClick ?? this.awaitingPlotClick,
      anchor: clearAnchor ? null : anchor ?? this.anchor,
      referenceBearing: referenceBearing ?? this.referenceBearing,
      plotBearing: plotBearing ?? this.plotBearing,
      previewEnd: clearPreviewEnd ? null : previewEnd ?? this.previewEnd,
      referenceLineId: clearReferenceLineId
          ? null
          : referenceLineId ?? this.referenceLineId,
    );
  }
}

final bearingPlotProvider =
    StateNotifierProvider<BearingPlotNotifier, BearingPlotState>(
  (ref) => BearingPlotNotifier(),
);

class BearingPlotNotifier extends StateNotifier<BearingPlotState> {
  BearingPlotNotifier() : super(const BearingPlotState());

  void begin({
    required LatLng anchor,
    required double referenceBearing,
    required UuidValue referenceLineId,
  }) {
    state = BearingPlotState(
      active: true,
      awaitingPlotClick: true,
      anchor: anchor,
      referenceBearing: referenceBearing,
      referenceLineId: referenceLineId,
    );
  }

  void updatePlot({
    required double plotBearing,
    required LatLng previewEnd,
  }) {
    if (!state.active || state.anchor == null) {
      return;
    }
    state = state.copyWith(
      plotBearing: plotBearing,
      previewEnd: previewEnd,
    );
  }

  void setRelativeBearing(double relativeBearing) {
    final reference = state.referenceBearing;
    final anchor = state.anchor;
    if (!state.active || reference == null || anchor == null) {
      return;
    }

    final plotBearing = absoluteBearingFromRelative(
      referenceBearing: reference,
      relativeBearing: relativeBearing,
    );
    final distanceMeters = state.previewEnd == null
        ? 1000.0
        : lineLengthMeters(anchor, state.previewEnd!);
    final previewEnd = pointAtTrueBearing(
      anchor: anchor,
      bearingDegrees: plotBearing,
      distanceMeters: math.max(distanceMeters, 50),
    );

    state = state.copyWith(
      plotBearing: plotBearing,
      previewEnd: previewEnd,
    );
  }

  void reset() {
    state = const BearingPlotState();
  }
}
