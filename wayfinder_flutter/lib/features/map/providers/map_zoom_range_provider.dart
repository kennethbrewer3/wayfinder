import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../models/map_zoom_limits.dart';

final mapZoomRangeProvider =
    StateNotifierProvider<MapZoomRangeNotifier, MapZoomRange>(
      (ref) => MapZoomRangeNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class MapZoomRangeNotifier extends StateNotifier<MapZoomRange> {
  MapZoomRangeNotifier(this._repository) : super(MapZoomRange.defaults) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = normalizeMapZoomRange(
        min: preferences.mapMinZoom,
        max: preferences.mapMaxZoom,
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to load map zoom range from server',
        error: error,
      );
      state = MapZoomRange.defaults;
    }
  }

  Future<void> setRange(MapZoomRange range) async {
    final normalized = validateMapZoomRange(range);
    state = normalized;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(
          mapMinZoom: normalized.min,
          mapMaxZoom: normalized.max,
        ),
      );
    } catch (error, _) {
      _log.warn(
        '🗺️ Failed to save map zoom range to server',
        error: error,
      );
    }
  }
}
