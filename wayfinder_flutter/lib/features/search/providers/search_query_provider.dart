import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/providers/map_providers.dart';

/// Delay before search results and geocoding requests update while typing.
const mapSearchDebounceDuration = Duration(milliseconds: 450);

/// Minimum characters before querying geocoded place names.
const mapSearchMinGeocodingLength = 3;

final debouncedMapSearchQueryProvider =
    StateNotifierProvider<DebouncedMapSearchQueryNotifier, String>((ref) {
  return DebouncedMapSearchQueryNotifier(ref);
});

class DebouncedMapSearchQueryNotifier extends StateNotifier<String> {
  DebouncedMapSearchQueryNotifier(this._ref) : super('') {
    _subscription = _ref.listen<String>(
      sidebarProvider.select((sidebar) => sidebar.searchQuery),
      (previous, next) {
        _timer?.cancel();
        final trimmed = next.trim();
        if (trimmed.isEmpty) {
          state = '';
          return;
        }

        _timer = Timer(mapSearchDebounceDuration, () {
          state = next;
        });
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;
  Timer? _timer;
  ProviderSubscription<String>? _subscription;

  void flush(String query) {
    _timer?.cancel();
    state = query;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.close();
    super.dispose();
  }
}
