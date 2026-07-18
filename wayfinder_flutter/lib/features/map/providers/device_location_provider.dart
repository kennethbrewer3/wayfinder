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
  StreamSubscription<Position>? _subscription;

  LocationSettings get _locationSettings {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  /// Start watching location, center-friendly first fix. Enables [following].
  Future<bool> locateAndFollow() async {
    state = state.copyWith(busy: true, clearError: true, following: true);
    final ok = await _ensureTracking();
    state = state.copyWith(busy: false);
    return ok;
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
    await _subscription?.cancel();
    _subscription = null;
    state = const DeviceLocationState();
  }

  Future<bool> _ensureTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          tracking: false,
          following: false,
          errorMessage: DeviceLocationError.serviceDisabled.code,
        );
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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

      // Fresh fix for immediate feedback, then stream for updates.
      try {
        final current = await Geolocator.getCurrentPosition(
          locationSettings: _locationSettings,
        );
        _applyPosition(current);
      } catch (error) {
        _log.warn('📍 getCurrentPosition failed; waiting on stream', error: error);
      }

      await _subscription?.cancel();
      _subscription = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(
        _applyPosition,
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
