import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../circles/presentation/map_circle_layer.dart';
import '../../elevation/providers/elevation_providers.dart';
import '../../lines/utils/bearing_utils.dart';
import '../utils/viewshed_compute.dart';

enum ViewshedStatus {
  idle,
  readyToCompute,
  computing,
  ready,
  missingDem,
  missingElevation,
  error,
}

class ViewshedState {
  const ViewshedState({
    this.active = false,
    this.observer,
    this.antennaHeightMeters = 2,
    this.rangeMeters = 5000,
    this.targetHeightAglMeters = 0,
    this.observerGroundMeters,
    this.visiblePolygon = const [],
    this.rangeRing = const [],
    this.progress = 0,
    this.status = ViewshedStatus.idle,
    this.errorMessage,
  });

  final bool active;
  final LatLng? observer;
  final double antennaHeightMeters;
  final double rangeMeters;
  final double targetHeightAglMeters;
  final double? observerGroundMeters;
  final List<LatLng> visiblePolygon;
  final List<LatLng> rangeRing;
  final double progress;
  final ViewshedStatus status;
  final String? errorMessage;

  bool get hasResult => visiblePolygon.length >= 3;

  double? get observerEyeMeters {
    final ground = observerGroundMeters;
    if (ground == null) {
      return null;
    }
    return ground + antennaHeightMeters;
  }

  ViewshedState copyWith({
    bool? active,
    LatLng? observer,
    double? antennaHeightMeters,
    double? rangeMeters,
    double? targetHeightAglMeters,
    double? observerGroundMeters,
    List<LatLng>? visiblePolygon,
    List<LatLng>? rangeRing,
    double? progress,
    ViewshedStatus? status,
    String? errorMessage,
    bool clearObserver = false,
    bool clearObserverGround = false,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ViewshedState(
      active: active ?? this.active,
      observer: clearObserver ? null : observer ?? this.observer,
      antennaHeightMeters: antennaHeightMeters ?? this.antennaHeightMeters,
      rangeMeters: rangeMeters ?? this.rangeMeters,
      targetHeightAglMeters:
          targetHeightAglMeters ?? this.targetHeightAglMeters,
      observerGroundMeters: clearObserverGround
          ? null
          : observerGroundMeters ?? this.observerGroundMeters,
      visiblePolygon: clearResult
          ? const []
          : visiblePolygon ?? this.visiblePolygon,
      rangeRing: clearResult ? const [] : rangeRing ?? this.rangeRing,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final viewshedProvider = StateNotifierProvider<ViewshedNotifier, ViewshedState>(
  (ref) => ViewshedNotifier(ref),
);

class ViewshedNotifier extends StateNotifier<ViewshedState> {
  ViewshedNotifier(this._ref) : super(const ViewshedState());

  final Ref _ref;
  int _computeGeneration = 0;

  static const _rayCount = 72;

  Future<void> begin({
    required LatLng observer,
    double? antennaHeightMeters,
  }) async {
    _computeGeneration += 1;
    final rangeRing = circleBoundaryPoints(
      center: observer,
      radiusMeters: state.rangeMeters,
    );
    state = ViewshedState(
      active: true,
      observer: observer,
      antennaHeightMeters: antennaHeightMeters ?? state.antennaHeightMeters,
      rangeMeters: state.rangeMeters,
      targetHeightAglMeters: state.targetHeightAglMeters,
      rangeRing: rangeRing,
      status: ViewshedStatus.readyToCompute,
    );
    await compute();
  }

  void setAntennaHeightMeters(double meters) {
    if (!state.active || meters < 0) {
      return;
    }
    state = state.copyWith(
      antennaHeightMeters: meters,
      clearResult: true,
      status: ViewshedStatus.readyToCompute,
      clearError: true,
    );
  }

  void setRangeMeters(double meters) {
    if (!state.active || meters < 50) {
      return;
    }
    final observer = state.observer;
    state = state.copyWith(
      rangeMeters: meters.clamp(50, 50000),
      rangeRing: observer == null
          ? const []
          : circleBoundaryPoints(center: observer, radiusMeters: meters),
      clearResult: true,
      status: ViewshedStatus.readyToCompute,
      clearError: true,
    );
  }

  void setTargetHeightAglMeters(double meters) {
    if (!state.active || meters < 0) {
      return;
    }
    state = state.copyWith(
      targetHeightAglMeters: meters,
      clearResult: true,
      status: ViewshedStatus.readyToCompute,
      clearError: true,
    );
  }

  Future<void> compute() async {
    final observer = state.observer;
    if (!state.active || observer == null) {
      return;
    }

    final generation = ++_computeGeneration;
    state = state.copyWith(
      status: ViewshedStatus.computing,
      progress: 0,
      clearResult: true,
      clearError: true,
      rangeRing: circleBoundaryPoints(
        center: observer,
        radiusMeters: state.rangeMeters,
      ),
    );

    final sampler = await _ref.read(elevationSamplerProvider.future);
    if (generation != _computeGeneration) {
      return;
    }
    if (!sampler.hasDem) {
      state = state.copyWith(status: ViewshedStatus.missingDem);
      return;
    }

    final ground = await sampler.elevationAt(observer);
    if (generation != _computeGeneration) {
      return;
    }
    if (ground == null) {
      state = state.copyWith(status: ViewshedStatus.missingElevation);
      return;
    }

    final eye = ground + state.antennaHeightMeters;
    final range = state.rangeMeters;
    final step = viewshedStepMetersForRange(range);
    final targetAgl = state.targetHeightAglMeters;
    final rays = <ViewshedRayResult>[];

    for (var i = 0; i < _rayCount; i++) {
      if (generation != _computeGeneration) {
        return;
      }
      final bearing = i * 360.0 / _rayCount;
      final samplePoints = <LatLng>[];
      final distances = <double>[];
      for (var distance = step; distance <= range + 0.5; distance += step) {
        final clamped = distance > range ? range : distance;
        distances.add(clamped);
        samplePoints.add(
          pointAtTrueBearing(
            anchor: observer,
            bearingDegrees: bearing,
            distanceMeters: clamped,
          ),
        );
      }

      final heights = await sampler.elevationsAlong(samplePoints);
      if (generation != _computeGeneration) {
        return;
      }

      final ray = castViewshedRaySamples(
        observer: observer,
        observerEyeMeters: eye,
        bearingDegrees: bearing,
        samplePoints: samplePoints,
        distancesMeters: distances,
        elevationsMeters: heights,
        targetHeightAglMeters: targetAgl,
      );
      rays.add(ray);

      if (i % 4 == 0 || i == _rayCount - 1) {
        state = state.copyWith(
          observerGroundMeters: ground,
          progress: (i + 1) / _rayCount,
          visiblePolygon: viewshedPolygonFromRays(rays),
          status: ViewshedStatus.computing,
        );
        await Future<void>.delayed(Duration.zero);
      }
    }

    if (generation != _computeGeneration) {
      return;
    }

    state = state.copyWith(
      observerGroundMeters: ground,
      progress: 1,
      visiblePolygon: viewshedPolygonFromRays(rays),
      status: ViewshedStatus.ready,
      clearError: true,
    );
  }

  void reset() {
    _computeGeneration += 1;
    state = const ViewshedState();
  }
}
