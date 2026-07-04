import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/marker_icon_background_color_storage.dart';

final markerIconBackgroundColorProvider =
    StateNotifierProvider<MarkerIconBackgroundColorNotifier, Color>(
  (ref) => MarkerIconBackgroundColorNotifier(MarkerIconBackgroundColorStorage()),
);

class MarkerIconBackgroundColorNotifier extends StateNotifier<Color> {
  MarkerIconBackgroundColorNotifier(this._storage)
      : super(parseDefaultBackgroundColor()) {
    _load();
  }

  final MarkerIconBackgroundColorStorage _storage;

  static Color parseDefaultBackgroundColor() {
    return const Color(0xFFFFFFFF);
  }

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setColor(Color color) async {
    state = color;
    await _storage.save(color);
  }
}
