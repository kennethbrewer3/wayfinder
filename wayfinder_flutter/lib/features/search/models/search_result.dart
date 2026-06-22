import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../geocoding/models/geocoding_models.dart';

enum SearchResultType { marker, zone, coordinate, place, address }

class SearchResult {
  const SearchResult({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.type,
    required this.location,
    this.zoom = 14,
  });

  final String id;
  final String label;
  final String subtitle;
  final SearchResultType type;
  final LatLng location;
  final double zoom;
}

List<SearchResult> buildSearchResults({
  required String query,
  required List<MapMarker> markers,
  required List<MapZone> zones,
}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return const [];
  }

  final normalized = trimmed.toLowerCase();
  final results = <SearchResult>[];

  final coordinate = _parseCoordinate(trimmed);
  if (coordinate != null) {
    results.add(
      SearchResult(
        id: 'coordinate',
        label: trimmed,
        subtitle: 'Coordinates',
        type: SearchResultType.coordinate,
        location: coordinate,
        zoom: 14,
      ),
    );
  }

  for (final marker in markers) {
    if (!marker.visible) continue;
    if (marker.name.toLowerCase().contains(normalized)) {
      results.add(
        SearchResult(
          id: marker.id.toString(),
          label: marker.name,
          subtitle: 'Marker',
          type: SearchResultType.marker,
          location: LatLng(marker.latitude, marker.longitude),
        ),
      );
    }
  }

  for (final zone in zones) {
    if (!zone.visible) continue;
    if (zone.name.toLowerCase().contains(normalized)) {
      final location = _zoneCenter(zone);
      if (location == null) continue;
      results.add(
        SearchResult(
          id: zone.id.toString(),
          label: zone.name,
          subtitle: 'Zone (${zone.type})',
          type: SearchResultType.zone,
          location: location,
        ),
      );
    }
  }

  return results;
}

SearchResult geocodingPlaceToSearchResult(GeocodingPlaceResult place) {
  final type = place.isAddress
      ? SearchResultType.address
      : SearchResultType.place;
  return SearchResult(
    id: '${type.name}-${place.id}',
    label: place.label,
    subtitle: place.subtitle,
    type: type,
    location: LatLng(place.latitude, place.longitude),
    zoom: _zoomForImportance(place.importance, isAddress: place.isAddress),
  );
}

double _zoomForImportance(double importance, {required bool isAddress}) {
  if (isAddress) {
    return 18;
  }
  if (importance >= 0.7) {
    return 12;
  }
  if (importance >= 0.4) {
    return 10;
  }
  return 8;
}

LatLng? _parseCoordinate(String input) {
  final parts = input.split(',').map((part) => part.trim()).toList();
  if (parts.length != 2) return null;

  final lat = double.tryParse(parts[0]);
  final lng = double.tryParse(parts[1]);
  if (lat == null || lng == null) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return LatLng(lat, lng);
}

LatLng? _zoneCenter(MapZone zone) {
  try {
    final geometry = zone.geometryJson;
    if (geometry.contains('"center"')) {
      final latMatch = RegExp(r'"lat"\s*:\s*(-?\d+\.?\d*)').firstMatch(geometry);
      final lngMatch = RegExp(r'"lng"\s*:\s*(-?\d+\.?\d*)').firstMatch(geometry);
      if (latMatch != null && lngMatch != null) {
        return LatLng(
          double.parse(latMatch.group(1)!),
          double.parse(lngMatch.group(1)!),
        );
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}
