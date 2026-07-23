import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/client_ui_preferences_repository.dart';
import '../models/angle_display_format.dart';

final angleDisplayFormatProvider =
    StateNotifierProvider<AngleDisplayFormatNotifier, AngleDisplayFormat>(
      (ref) => AngleDisplayFormatNotifier(
        ref.watch(clientUiPreferencesRepositoryProvider),
      ),
    );

class AngleDisplayFormatNotifier extends StateNotifier<AngleDisplayFormat> {
  AngleDisplayFormatNotifier(this._repository)
    : super(AngleDisplayFormat.decimal) {
    _load();
  }

  final ClientUiPreferencesRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.get();
      state = preferences.angleDisplayFormat;
    } catch (error, _) {
      _log.warn(
        '📐 Failed to load angle format from device preferences',
        error: error,
      );
      state = AngleDisplayFormat.decimal;
    }
  }

  Future<void> setFormat(AngleDisplayFormat format) async {
    state = format;
    try {
      await _repository.patch(
        (current) => current.copyWith(angleDisplayFormat: format),
      );
    } catch (error, _) {
      _log.warn(
        '📐 Failed to save angle format to device preferences',
        error: error,
      );
    }
  }
}
