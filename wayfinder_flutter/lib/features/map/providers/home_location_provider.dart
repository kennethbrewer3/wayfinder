import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/data/app_settings_repository.dart';
import '../models/home_location.dart';

final homeLocationProvider =
    StateNotifierProvider<HomeLocationNotifier, HomeLocation>(
  (ref) => HomeLocationNotifier(ref.watch(appSettingsRepositoryProvider)),
);

class HomeLocationNotifier extends StateNotifier<HomeLocation> {
  HomeLocationNotifier(this._repository) : super(HomeLocation.defaults) {
    _load();
  }

  final AppSettingsRepository _repository;

  Future<void> _load() async {
    try {
      state = await _repository.getHomeLocation();
    } catch (_) {
      state = HomeLocation.defaults;
    }
  }

  Future<void> reload() => _load();

  Future<void> setLocation(HomeLocation location) async {
    state = await _repository.updateHomeLocation(location);
  }

  Future<void> resetToDefaults() async {
    state = await _repository.resetHomeLocation();
  }
}
