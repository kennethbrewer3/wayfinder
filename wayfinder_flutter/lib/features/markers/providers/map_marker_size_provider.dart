import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/map_marker_size_storage.dart';
import '../models/map_marker_size.dart';

final mapMarkerSizeScaleProvider =
    StateNotifierProvider<MapMarkerSizeScaleNotifier, double>(
      (ref) => MapMarkerSizeScaleNotifier(MapMarkerSizeStorage()),
    );

class MapMarkerSizeScaleNotifier extends StateNotifier<double> {
  MapMarkerSizeScaleNotifier(this._storage)
    : super(mapMarkerSizeScaleDefault) {
    _load();
  }

  final MapMarkerSizeStorage _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setScale(double scale) async {
    state = clampMapMarkerSizeScale(scale);
    await _storage.save(state);
  }
}
