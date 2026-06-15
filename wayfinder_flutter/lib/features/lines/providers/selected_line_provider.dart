import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

final selectedLineProvider =
    StateNotifierProvider<SelectedLineNotifier, UuidValue?>(
  (ref) => SelectedLineNotifier(),
);

class SelectedLineNotifier extends StateNotifier<UuidValue?> {
  SelectedLineNotifier() : super(null);

  void select(UuidValue id) {
    state = id;
  }

  void clear() {
    state = null;
  }

  void toggle(UuidValue id) {
    state = state == id ? null : id;
  }
}
