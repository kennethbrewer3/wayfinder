import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/logging/app_logger.dart';

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
  var _locateGeneration = 0;

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
    await _subscription?.cancel();
    _subscription = null;
    state = const DeviceLocationState();
  }

  Future<bool> _ensureTracking(int generation) async {
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
      _subscription = Geolocator.getPositionStream(
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
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
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
