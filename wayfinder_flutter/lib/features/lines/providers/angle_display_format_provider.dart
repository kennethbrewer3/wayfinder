import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../data/angle_display_format_storage.dart';
import '../models/angle_display_format.dart';

final angleDisplayFormatProvider =
    StateNotifierProvider<AngleDisplayFormatNotifier, AngleDisplayFormat>(
  (ref) => AngleDisplayFormatNotifier(
    ref.watch(appSettingsRepositoryProvider),
    AngleDisplayFormatStorage(),
  ),
);

class AngleDisplayFormatNotifier extends StateNotifier<AngleDisplayFormat> {
  AngleDisplayFormatNotifier(this._repository, this._storage)
      : super(AngleDisplayFormat.decimal) {
    _load();
  }

  final AppSettingsRepository _repository;
  final AngleDisplayFormatStorage _storage;
  static final _log = AppLogger.logSettings;

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.angleDisplayFormat;
      await _storage.save(state);
      return;
    } catch (error, _) {
      _log.warn(
        '📐 Failed to load angle format from server',
        error: error,
      );
    }
    state = await _storage.load();
  }

  Future<void> setFormat(AngleDisplayFormat format) async {
    state = format;
    await _storage.save(format);
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(angleDisplayFormat: format),
      );
    } catch (error, _) {
      _log.warn(
        '📐 Failed to save angle format to server',
        error: error,
      );
    }
  }
}
