import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zone IDs (lines/tracks) checked in the sidebar for a combined elevation profile.
final pathProfileSelectionProvider =
    StateNotifierProvider<PathProfileSelectionNotifier, Set<String>>((ref) {
      return PathProfileSelectionNotifier();
    });

class PathProfileSelectionNotifier extends StateNotifier<Set<String>> {
  PathProfileSelectionNotifier() : super(const {});

  void toggle(String zoneId) {
    final next = Set<String>.from(state);
    if (!next.add(zoneId)) {
      next.remove(zoneId);
    }
    state = next;
  }

  void clear() {
    state = const {};
  }

  bool contains(String zoneId) => state.contains(zoneId);
}
