import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../circles/presentation/map_circle_layer.dart';
import '../../elevation/providers/elevation_providers.dart';
import '../utils/slope_compute.dart';

enum SlopeStatus {
  idle,
  readyToCompute,
  computing,
  ready,
  missingDem,
  error,
}

enum SlopeColorMode {
  /// Color by slope angle (green gentle → red steep).
  slope,

  /// Color by mobility cost derived from slope ([SlopeMobilityMode]).
  cost,
}

class SlopeState {
  const SlopeState({
    this.active = false,
    this.center,
    this.rangeMeters = 3000,
    this.opacity = 0.55,
    this.colorMode = SlopeColorMode.cost,
    this.mobilityMode = SlopeMobilityMode.drive,
    this.bounds,
    this.heatmapBytes,
    this.rangeRing = const [],
    this.progress = 0,
    this.status = SlopeStatus.idle,
    this.errorMessage,
    this.meanSlopeDegrees,
    this.maxSlopeDegrees,
  });

  final bool active;
  final LatLng? center;
  final double rangeMeters;
  final double opacity;
  final SlopeColorMode colorMode;
  final SlopeMobilityMode mobilityMode;
  final LatLngBounds? bounds;
  final Uint8List? heatmapBytes;
  final List<LatLng> rangeRing;
  final double progress;
  final SlopeStatus status;
  final String? errorMessage;
  final double? meanSlopeDegrees;
  final double? maxSlopeDegrees;

  bool get hasResult =>
      heatmapBytes != null && heatmapBytes!.isNotEmpty && bounds != null;

  MemoryImage? get heatmapImage {
    final bytes = heatmapBytes;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    return MemoryImage(bytes);
  }

  SlopeState copyWith({
    bool? active,
    LatLng? center,
    double? rangeMeters,
    double? opacity,
    SlopeColorMode? colorMode,
    SlopeMobilityMode? mobilityMode,
    LatLngBounds? bounds,
    Uint8List? heatmapBytes,
    List<LatLng>? rangeRing,
    double? progress,
    SlopeStatus? status,
    String? errorMessage,
    double? meanSlopeDegrees,
    double? maxSlopeDegrees,
    bool clearCenter = false,
    bool clearBounds = false,
    bool clearHeatmap = false,
    bool clearError = false,
    bool clearStats = false,
  }) {
    return SlopeState(
      active: active ?? this.active,
      center: clearCenter ? null : center ?? this.center,
      rangeMeters: rangeMeters ?? this.rangeMeters,
      opacity: opacity ?? this.opacity,
      colorMode: colorMode ?? this.colorMode,
      mobilityMode: mobilityMode ?? this.mobilityMode,
      bounds: clearBounds ? null : bounds ?? this.bounds,
      heatmapBytes: clearHeatmap ? null : heatmapBytes ?? this.heatmapBytes,
      rangeRing: rangeRing ?? this.rangeRing,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      meanSlopeDegrees: clearStats
          ? null
          : meanSlopeDegrees ?? this.meanSlopeDegrees,
      maxSlopeDegrees: clearStats
          ? null
          : maxSlopeDegrees ?? this.maxSlopeDegrees,
    );
  }
}

final slopeProvider = StateNotifierProvider<SlopeNotifier, SlopeState>(
  (ref) => SlopeNotifier(ref),
);

class SlopeNotifier extends StateNotifier<SlopeState> {
  SlopeNotifier(this._ref) : super(const SlopeState());

  final Ref _ref;
  int _computeGeneration = 0;

  Future<void> begin({required LatLng center}) async {
    _computeGeneration += 1;
    state = SlopeState(
      active: true,
      center: center,
      rangeMeters: state.rangeMeters,
      opacity: state.opacity,
      colorMode: state.colorMode,
      mobilityMode: state.mobilityMode,
      rangeRing: circleBoundaryPoints(
        center: center,
        radiusMeters: state.rangeMeters,
      ),
      status: SlopeStatus.readyToCompute,
    );
    await compute();
  }

  void setRangeMeters(double meters) {
    if (!state.active) {
      return;
    }
    final center = state.center;
    final clamped = meters.clamp(minSlopeRangeMeters, maxSlopeRangeMeters);
    state = state.copyWith(
      rangeMeters: clamped,
      rangeRing: center == null
          ? const []
          : circleBoundaryPoints(center: center, radiusMeters: clamped),
      clearHeatmap: true,
      clearBounds: true,
      clearStats: true,
      status: SlopeStatus.readyToCompute,
      clearError: true,
    );
  }

  void setOpacity(double opacity) {
    if (!state.active) {
      return;
    }
    state = state.copyWith(opacity: opacity.clamp(0.15, 0.9));
  }

  void setColorMode(SlopeColorMode mode) {
    if (!state.active || mode == state.colorMode) {
      return;
    }
    state = state.copyWith(
      colorMode: mode,
      clearHeatmap: true,
      clearBounds: true,
      clearStats: true,
      status: SlopeStatus.readyToCompute,
      clearError: true,
    );
  }

  void setMobilityMode(SlopeMobilityMode mode) {
    if (!state.active || mode == state.mobilityMode) {
      return;
    }
    state = state.copyWith(
      mobilityMode: mode,
      clearHeatmap: true,
      clearBounds: true,
      clearStats: true,
      status: SlopeStatus.readyToCompute,
      clearError: true,
    );
  }

  Future<void> compute() async {
    final center = state.center;
    if (!state.active || center == null) {
      return;
    }

    final generation = ++_computeGeneration;
    final range = state.rangeMeters.clamp(
      minSlopeRangeMeters,
      maxSlopeRangeMeters,
    );
    final layout = slopeGridLayoutForRange(range);
    final step = layout.stepMeters;
    final size = layout.size;
    final bounds = slopeBoundsForCenter(center: center, rangeMeters: range);

    state = state.copyWith(
      status: SlopeStatus.computing,
      progress: 0,
      clearHeatmap: true,
      clearBounds: true,
      clearStats: true,
      clearError: true,
      bounds: bounds,
      rangeRing: circleBoundaryPoints(center: center, radiusMeters: range),
    );

    final sampler = await _ref.read(elevationSamplerProvider.future);
    if (generation != _computeGeneration) {
      return;
    }
    if (!sampler.hasDem) {
      state = state.copyWith(status: SlopeStatus.missingDem);
      return;
    }

    final points = slopeGridSamplePoints(
      center: center,
      rangeMeters: range,
      stepMeters: step,
    );

    final elevations = <double?>[];
    const chunk = 64;
    for (var i = 0; i < points.length; i += chunk) {
      if (generation != _computeGeneration) {
        return;
      }
      final end = (i + chunk).clamp(0, points.length);
      final batch = await sampler.elevationsAlong(points.sublist(i, end));
      elevations.addAll(batch);
      state = state.copyWith(
        progress: end / points.length * 0.85,
        status: SlopeStatus.computing,
      );
      await Future<void>.delayed(Duration.zero);
    }

    if (generation != _computeGeneration) {
      return;
    }

    final slopes = slopeDegreesGrid(
      elevations: elevations,
      size: size,
      cellSizeMeters: step,
    );

    var sum = 0.0;
    var count = 0;
    var maxSlope = 0.0;
    for (final slope in slopes) {
      if (slope == null) {
        continue;
      }
      sum += slope;
      count += 1;
      if (slope > maxSlope) {
        maxSlope = slope;
      }
    }

    final png = await encodeSlopeHeatmapPng(
      slopesDegrees: slopes,
      size: size,
      colorByCost: state.colorMode == SlopeColorMode.cost,
      mobilityMode: state.mobilityMode,
      opacity: 1.0, // layer opacity applied by OverlayImage
    );
    if (generation != _computeGeneration) {
      return;
    }
    if (png.isEmpty) {
      state = state.copyWith(
        status: SlopeStatus.error,
        errorMessage: 'Failed to encode slope heatmap',
      );
      return;
    }

    state = state.copyWith(
      progress: 1,
      heatmapBytes: png,
      bounds: bounds,
      meanSlopeDegrees: count == 0 ? null : sum / count,
      maxSlopeDegrees: count == 0 ? null : maxSlope,
      status: SlopeStatus.ready,
      clearError: true,
    );
  }

  void reset() {
    _computeGeneration += 1;
    state = const SlopeState();
  }
}
