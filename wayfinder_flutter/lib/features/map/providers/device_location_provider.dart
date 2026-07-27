import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/logging/app_logger.dart';
import '../../lines/utils/line_distance.dart';

/// Live device GPS / browser geolocation for the “you are here” overlay.
///
/// Session-only (not synced to the server). Works offline — the OS/GPS stack
/// provides coordinates; no internet is required to plot them on PMTiles.
class DeviceLocationState {
  const DeviceLocationState({
    this.position,
    this.accuracyMeters,
    this.headingDegrees,
    this.tracking = false,
    this.following = false,
    this.busy = false,
    this.errorMessage,
  });

  final LatLng? position;
  final double? accuracyMeters;
  final double? headingDegrees;
  final bool tracking;
  final bool following;
  final bool busy;
  final String? errorMessage;

  bool get hasFix => position != null;

  DeviceLocationState copyWith({
    LatLng? position,
    double? accuracyMeters,
    double? headingDegrees,
    bool? tracking,
    bool? following,
    bool? busy,
    String? errorMessage,
    bool clearError = false,
    bool clearPosition = false,
  }) {
    return DeviceLocationState(
      position: clearPosition ? null : (position ?? this.position),
      accuracyMeters: clearPosition
          ? null
          : (accuracyMeters ?? this.accuracyMeters),
      headingDegrees: clearPosition
          ? null
          : (headingDegrees ?? this.headingDegrees),
      tracking: tracking ?? this.tracking,
      following: following ?? this.following,
      busy: busy ?? this.busy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final deviceLocationProvider =
    StateNotifierProvider<DeviceLocationNotifier, DeviceLocationState>(
      (ref) => DeviceLocationNotifier(),
    );

class DeviceLocationNotifier extends StateNotifier<DeviceLocationState> {
  DeviceLocationNotifier() : super(const DeviceLocationState());

  static final _log = AppLogger.logMap;
  static const _positionTimeout = Duration(seconds: 10);

  StreamSubscription<Position>? _subscription;
  Timer? _simulationTimer;
  var _locateGeneration = 0;
  var _simulating = false;

  bool get isSimulating => _simulating;

  LocationSettings _settings({Duration? timeLimit}) {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        timeLimit: timeLimit,
      );
    }
    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
      timeLimit: timeLimit,
    );
  }

  /// Start watching location (or resume follow if already tracking).
  Future<bool> locateAndFollow() async {
    // Already live — do not re-enter getCurrentPosition (can hang on web and
    // leave busy=true, which disables the toolbar button entirely).
    if (state.tracking && _subscription != null) {
      state = state.copyWith(
        following: true,
        busy: false,
        clearError: true,
      );
      return true;
    }

    final generation = ++_locateGeneration;
    state = state.copyWith(busy: true, clearError: true, following: true);
    try {
      final ok = await _ensureTracking(generation);
      return ok;
    } finally {
      if (generation == _locateGeneration) {
        state = state.copyWith(busy: false);
      }
    }
  }

  /// Keep the blue dot updating but stop recentering the map.
  void stopFollowing() {
    if (!state.following) {
      return;
    }
    state = state.copyWith(following: false);
  }

  void setFollowing(bool following) {
    state = state.copyWith(following: following);
  }

  /// Stop the position stream and hide the overlay.
  Future<void> stop() async {
    _locateGeneration++;
    _stopSimulationTimer();
    await _subscription?.cancel();
    _subscription = null;
    state = const DeviceLocationState();
  }

  /// Inject a fake GPS fix (debug / desk testing). Cancels the live stream.
  Future<void> applySimulatedFix(
    LatLng position, {
    double? headingDegrees,
    double accuracyMeters = 5,
  }) async {
    await _subscription?.cancel();
    _subscription = null;
    _simulating = true;
    state = state.copyWith(
      position: position,
      accuracyMeters: accuracyMeters,
      headingDegrees: headingDegrees,
      tracking: true,
      following: true,
      busy: false,
      clearError: true,
    );
  }

  /// Walk [path] with fake GPS fixes so route-follow can be tested at a desk.
  ///
  /// Replaces the real location stream until [stopSimulation] or [stop].
  Future<void> startSimulatedWalkAlong(
    List<LatLng> path, {
    Duration stepInterval = const Duration(milliseconds: 400),
    double stepMeters = 12,
    void Function()? onCompleted,
  }) async {
    if (path.length < 2) {
      return;
    }
    _locateGeneration++;
    await _subscription?.cancel();
    _subscription = null;
    _stopSimulationTimer();
    _simulating = true;

    final total = _pathLengthMeters(path);
    var traveled = 0.0;
    void publish() {
      final point = _pointAlong(path, traveled) ?? path.first;
      final ahead = _pointAlong(path, traveled + 8) ?? path.last;
      final heading = lineGeodesicBearing(point, ahead);
      state = DeviceLocationState(
        position: point,
        accuracyMeters: 5,
        headingDegrees: heading,
        tracking: true,
        following: true,
        busy: false,
      );
    }

    publish();
    _simulationTimer = Timer.periodic(stepInterval, (timer) {
      traveled += stepMeters;
      if (traveled >= total) {
        traveled = total;
        publish();
        _stopSimulationTimer();
        onCompleted?.call();
        return;
      }
      publish();
    });
  }

  void stopSimulation() {
    _stopSimulationTimer();
  }

  void _stopSimulationTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _simulating = false;
  }

  Future<bool> _ensureTracking(int generation) async {
    _stopSimulationTimer();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isCurrentGeneration(generation)) {
        return false;
      }
      if (!serviceEnabled) {
        state = state.copyWith(
          tracking: false,
          following: false,
          errorMessage: DeviceLocationError.serviceDisabled.code,
        );
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (!_isCurrentGeneration(generation)) {
        return false;
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!_isCurrentGeneration(generation)) {
          return false;
        }
      }
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          tracking: false,
          following: false,
          errorMessage: DeviceLocationError.permissionDenied.code,
        );
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          tracking: false,
          following: false,
          errorMessage: DeviceLocationError.permissionDeniedForever.code,
        );
        return false;
      }

      // Prefer a quick cached fix so the UI is not blocked on a cold GNSS lock.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (!_isCurrentGeneration(generation)) {
          return false;
        }
        if (last != null) {
          _applyPosition(last);
        }
      } catch (_) {
        // Optional warm start.
      }

      try {
        final current = await Geolocator.getCurrentPosition(
          locationSettings: _settings(timeLimit: _positionTimeout),
        );
        if (!_isCurrentGeneration(generation)) {
          return false;
        }
        _applyPosition(current);
      } catch (error) {
        _log.warn(
          '📍 getCurrentPosition failed; waiting on stream',
          error: error,
        );
      }

      if (!_isCurrentGeneration(generation)) {
        return false;
      }

      await _subscription?.cancel();
      _subscription =
          Geolocator.getPositionStream(
            locationSettings: _settings(),
          ).listen(
            (position) {
              if (_subscription == null) {
                return;
              }
              _applyPosition(position);
            },
            onError: (Object error) {
              _log.warn('📍 Position stream error', error: error);
              state = state.copyWith(
                errorMessage: DeviceLocationError.unavailable.code,
              );
            },
          );

      state = state.copyWith(tracking: true, clearError: true);
      return state.hasFix || state.tracking;
    } catch (error, stackTrace) {
      if (!_isCurrentGeneration(generation)) {
        return false;
      }
      _log.error(
        '📍 Failed to start device location',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        tracking: false,
        following: false,
        busy: false,
        errorMessage: DeviceLocationError.unavailable.code,
      );
      return false;
    }
  }

  bool _isCurrentGeneration(int generation) => generation == _locateGeneration;

  void _applyPosition(Position position) {
    state = state.copyWith(
      position: LatLng(position.latitude, position.longitude),
      accuracyMeters: position.accuracy.isFinite && position.accuracy > 0
          ? position.accuracy
          : null,
      headingDegrees: position.heading.isFinite && position.heading >= 0
          ? position.heading
          : null,
      tracking: true,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _locateGeneration++;
    _stopSimulationTimer();
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}

double _pathLengthMeters(List<LatLng> path) => lineLengthMetersForPoints(path);

LatLng? _pointAlong(List<LatLng> path, double distanceMeters) {
  if (path.isEmpty) {
    return null;
  }
  if (distanceMeters <= 0) {
    return path.first;
  }
  var remaining = distanceMeters;
  for (var i = 0; i < path.length - 1; i++) {
    final start = path[i];
    final end = path[i + 1];
    final segmentLength = lineLengthMeters(start, end);
    if (remaining <= segmentLength) {
      if (segmentLength < 0.5) {
        return start;
      }
      final bearing = lineGeodesicCalculator.bearing(start, end);
      return lineGeodesicCalculator.offset(start, remaining, bearing);
    }
    remaining -= segmentLength;
  }
  return path.last;
}

double lineGeodesicBearing(LatLng from, LatLng to) {
  return lineGeodesicCalculator.bearing(from, to);
}

/// Stable error codes mapped to l10n in the UI.
enum DeviceLocationError {
  serviceDisabled('serviceDisabled'),
  permissionDenied('permissionDenied'),
  permissionDeniedForever('permissionDeniedForever'),
  unavailable('unavailable');

  const DeviceLocationError(this.code);
  final String code;

  static DeviceLocationError? fromCode(String? code) {
    if (code == null) {
      return null;
    }
    for (final value in values) {
      if (value.code == code) {
        return value;
      }
    }
    return null;
  }
}
