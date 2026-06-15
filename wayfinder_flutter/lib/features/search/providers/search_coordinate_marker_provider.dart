import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class SearchCoordinateMarker {
  const SearchCoordinateMarker({
    required this.location,
    required this.label,
  });

  final LatLng location;
  final String label;
}

class SearchCoordinateMarkerNotifier extends StateNotifier<SearchCoordinateMarker?> {
  SearchCoordinateMarkerNotifier() : super(null);

  void set(LatLng location, String label) {
    state = SearchCoordinateMarker(location: location, label: label);
  }

  void clear() {
    state = null;
  }
}

final searchCoordinateMarkerProvider =
    StateNotifierProvider<SearchCoordinateMarkerNotifier, SearchCoordinateMarker?>(
  (ref) => SearchCoordinateMarkerNotifier(),
);
