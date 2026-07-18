import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide normalizeBearing;

import '../utils/bearing_utils.dart';
import '../utils/dead_reckoning_math.dart';

/// Typical single-step length used when no preference is stored yet (~30 in).
const defaultPaceLengthMeters = 0.75;

enum DeadReckoningDistanceMode { distance, paces }

class DeadReckoningState {
  const DeadReckoningState({
    this.active = false,
    this.anchor,
    this.headingTrueDegrees = 0,
    this.distanceMeters = 100,
    this.paceCount = 100,
    this.paceLengthMeters = defaultPaceLengthMeters,
    this.distanceMode = DeadReckoningDistanceMode.paces,
    this.previewEnd,
  });

  final bool active;
  final LatLng? anchor;
  final double headingTrueDegrees;
  final double distanceMeters;
  final double paceCount;
  final double paceLengthMeters;
  final DeadReckoningDistanceMode distanceMode;
  final LatLng? previewEnd;

  double get effectiveDistanceMeters =>
      distanceMode == DeadReckoningDistanceMode.paces
      ? distanceMetersFromPaces(
          paceCount: paceCount,
          paceLengthMeters: paceLengthMeters,
        )
      : distanceMeters;

  DeadReckoningState copyWith({
    bool? active,
    LatLng? anchor,
    double? headingTrueDegrees,
    double? distanceMeters,
    double? paceCount,
    double? paceLengthMeters,
    DeadReckoningDistanceMode? distanceMode,
    LatLng? previewEnd,
    bool clearAnchor = false,
    bool clearPreviewEnd = false,
  }) {
    return DeadReckoningState(
      active: active ?? this.active,
      anchor: clearAnchor ? null : anchor ?? this.anchor,
      headingTrueDegrees: headingTrueDegrees ?? this.headingTrueDegrees,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      paceCount: paceCount ?? this.paceCount,
      paceLengthMeters: paceLengthMeters ?? this.paceLengthMeters,
      distanceMode: distanceMode ?? this.distanceMode,
      previewEnd: clearPreviewEnd ? null : previewEnd ?? this.previewEnd,
    );
  }
}

final deadReckoningProvider =
    StateNotifierProvider<DeadReckoningNotifier, DeadReckoningState>(
      (ref) => DeadReckoningNotifier(),
    );

class DeadReckoningNotifier extends StateNotifier<DeadReckoningState> {
  DeadReckoningNotifier() : super(const DeadReckoningState());

  void begin({
    required LatLng anchor,
    double? headingTrueDegrees,
    double? paceLengthMeters,
  }) {
    final heading = normalizeBearing(headingTrueDegrees ?? 0);
    final paceLength = paceLengthMeters ?? defaultPaceLengthMeters;
    final draft = DeadReckoningState(
      active: true,
      anchor: anchor,
      headingTrueDegrees: heading,
      paceLengthMeters: paceLength <= 0 ? defaultPaceLengthMeters : paceLength,
    );
    state = draft.copyWith(previewEnd: _previewFor(draft));
  }

  void setHeadingTrue(double degrees) {
    if (!state.active) {
      return;
    }
    final next = state.copyWith(headingTrueDegrees: normalizeBearing(degrees));
    state = next.copyWith(previewEnd: _previewFor(next));
  }

  void setDistanceMeters(double meters) {
    if (!state.active || meters < 0) {
      return;
    }
    final next = state.copyWith(distanceMeters: meters);
    state = next.copyWith(previewEnd: _previewFor(next));
  }

  void setPaceCount(double paces) {
    if (!state.active || paces < 0) {
      return;
    }
    final next = state.copyWith(paceCount: paces);
    state = next.copyWith(previewEnd: _previewFor(next));
  }

  void setPaceLengthMeters(double meters) {
    if (!state.active || meters <= 0) {
      return;
    }
    final next = state.copyWith(paceLengthMeters: meters);
    state = next.copyWith(previewEnd: _previewFor(next));
  }

  void setDistanceMode(DeadReckoningDistanceMode mode) {
    if (!state.active) {
      return;
    }
    final next = state.copyWith(distanceMode: mode);
    state = next.copyWith(previewEnd: _previewFor(next));
  }

  void reset() {
    state = const DeadReckoningState();
  }

  LatLng? _previewFor(DeadReckoningState value) {
    final anchor = value.anchor;
    final distance = value.effectiveDistanceMeters;
    if (anchor == null || distance < 1) {
      return null;
    }
    return pointAtTrueBearing(
      anchor: anchor,
      bearingDegrees: value.headingTrueDegrees,
      distanceMeters: distance,
    );
  }
}
