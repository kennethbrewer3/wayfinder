import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme_choice.dart';
import '../data/app_theme_storage.dart';

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeChoice>(
  (ref) => AppThemeNotifier(AppThemeStorage()),
);

class AppThemeNotifier extends StateNotifier<AppThemeChoice> {
  AppThemeNotifier(this._storage) : super(AppThemeChoice.light) {
    _load();
  }

  final AppThemeStorage _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setFamily(AppThemeFamily family) async {
    final next = AppThemeChoice.combine(family, state.brightness);
    state = next;
    await _storage.save(next);
  }

  Future<void> setBrightness(AppThemeBrightness brightness) async {
    final next = AppThemeChoice.combine(state.family, brightness);
    state = next;
    await _storage.save(next);
  }
}
