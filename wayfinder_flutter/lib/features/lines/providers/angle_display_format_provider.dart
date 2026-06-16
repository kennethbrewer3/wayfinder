import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/angle_display_format_storage.dart';
import '../models/angle_display_format.dart';

final angleDisplayFormatProvider =
    StateNotifierProvider<AngleDisplayFormatNotifier, AngleDisplayFormat>(
  (ref) => AngleDisplayFormatNotifier(AngleDisplayFormatStorage()),
);

class AngleDisplayFormatNotifier extends StateNotifier<AngleDisplayFormat> {
  AngleDisplayFormatNotifier(this._storage)
      : super(AngleDisplayFormat.decimal) {
    _load();
  }

  final AngleDisplayFormatStorage _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setFormat(AngleDisplayFormat format) async {
    state = format;
    await _storage.save(format);
  }
}
