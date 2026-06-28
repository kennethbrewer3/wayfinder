import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class SearchCoordinateMarker {
  const SearchCoordinateMarker({
    required this.location,
    required this.label,
    this.iconName = 'my_location',
  });

  final LatLng location;
  final String label;
  final String iconName;
}

class SearchCoordinateMarkerNotifier extends StateNotifier<SearchCoordinateMarker?> {
  SearchCoordinateMarkerNotifier() : super(null);

  void set(
    LatLng location,
    String label, {
    String iconName = 'my_location',
  }) {
    state = SearchCoordinateMarker(
      location: location,
      label: label,
      iconName: iconName,
    );
  }

  void clear() {
    state = null;
  }
}

final searchCoordinateMarkerProvider =
    StateNotifierProvider<SearchCoordinateMarkerNotifier, SearchCoordinateMarker?>(
  (ref) => SearchCoordinateMarkerNotifier(),
);
