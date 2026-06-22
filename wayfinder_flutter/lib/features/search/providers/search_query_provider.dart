import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimum characters before querying geocoded place names.
const mapSearchMinGeocodingLength = 3;

/// Query used for map search results, geocoding, and sidebar filtering.
/// Updated only when the user submits search (search button or Enter).
final submittedMapSearchQueryProvider =
    StateNotifierProvider<SubmittedMapSearchQueryNotifier, String>((ref) {
  return SubmittedMapSearchQueryNotifier();
});

/// Backwards-compatible alias for older call sites.
final debouncedMapSearchQueryProvider = submittedMapSearchQueryProvider;

class SubmittedMapSearchQueryNotifier extends StateNotifier<String> {
  SubmittedMapSearchQueryNotifier() : super('');

  void submit(String query) {
    state = query.trim();
  }

  void clear() {
    state = '';
  }

  /// Alias kept for existing call sites.
  void flush(String query) => submit(query);
}
