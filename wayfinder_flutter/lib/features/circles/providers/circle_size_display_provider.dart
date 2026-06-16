import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/circle_size_display_storage.dart';
import '../models/circle_size_display.dart';

final circleSizeDisplayProvider =
    StateNotifierProvider<CircleSizeDisplayNotifier, CircleSizeDisplay>(
  (ref) => CircleSizeDisplayNotifier(CircleSizeDisplayStorage()),
);

class CircleSizeDisplayNotifier extends StateNotifier<CircleSizeDisplay> {
  CircleSizeDisplayNotifier(this._storage) : super(CircleSizeDisplay.radius) {
    _load();
  }

  final CircleSizeDisplayStorage _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setDisplay(CircleSizeDisplay display) async {
    state = display;
    await _storage.save(display);
  }
}
