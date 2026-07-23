import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';
import '../models/map_marker_size.dart';

final mapMarkerSizeScaleProvider =
    StateNotifierProvider<MapMarkerSizeScaleNotifier, double>(
      (ref) => MapMarkerSizeScaleNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class MapMarkerSizeScaleNotifier extends StateNotifier<double> {
  MapMarkerSizeScaleNotifier(this._repository)
    : super(mapMarkerSizeScaleDefault) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.mapMarkerSizeScale;
    } catch (error, _) {
      _log.warn(
        '📍 Failed to load map marker size from device preferences',
        error: error,
      );
      state = mapMarkerSizeScaleDefault;
    }
  }

  Future<void> setScale(double scale) async {
    state = clampMapMarkerSizeScale(scale);
    try {
      await _repository.patch(
        (current) => current.copyWith(mapMarkerSizeScale: state),
      );
    } catch (error, _) {
      _log.warn(
        '📍 Failed to save map marker size to device preferences',
        error: error,
      );
    }
  }
}
