import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../models/angle_display_format.dart';

final angleDisplayFormatProvider =
    StateNotifierProvider<AngleDisplayFormatNotifier, AngleDisplayFormat>(
      (ref) => AngleDisplayFormatNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class AngleDisplayFormatNotifier extends StateNotifier<AngleDisplayFormat> {
  AngleDisplayFormatNotifier(this._repository)
    : super(AngleDisplayFormat.decimal) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.angleDisplayFormat;
    } catch (error, _) {
      _log.warn(
        '📐 Failed to load angle format from server',
        error: error,
      );
      state = AngleDisplayFormat.decimal;
    }
  }

  Future<void> setFormat(AngleDisplayFormat format) async {
    state = format;
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
