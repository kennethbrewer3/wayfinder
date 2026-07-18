import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/app_settings_repository.dart';
import '../models/bearing_reference.dart';

final bearingReferenceProvider =
    StateNotifierProvider<BearingReferenceNotifier, BearingReference>(
      (ref) => BearingReferenceNotifier(
        ref.watch(appSettingsRepositoryProvider),
      ),
    );

class BearingReferenceNotifier extends StateNotifier<BearingReference> {
  BearingReferenceNotifier(this._repository)
    : super(BearingReference.trueNorth) {
    _load();
  }

  final AppSettingsRepository _repository;
  static final _log = AppLogger.logSettings;

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      final preferences = await _repository.getClientPreferences();
      state = preferences.bearingReference;
    } catch (error, _) {
      _log.warn(
        '🧭 Failed to load bearing reference from server',
        error: error,
      );
      state = BearingReference.trueNorth;
    }
  }

  Future<void> setReference(BearingReference reference) async {
    state = reference;
    try {
      await _repository.patchClientPreferences(
        (current) => current.copyWith(bearingReference: reference),
      );
    } catch (error, _) {
      _log.warn(
        '🧭 Failed to save bearing reference to server',
        error: error,
      );
    }
  }
}
