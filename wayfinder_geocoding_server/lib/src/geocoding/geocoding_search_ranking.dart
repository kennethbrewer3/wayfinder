import 'dart:math' as math;

import '../generated/protocol.dart';
import 'geocoding_constants.dart';

void sortAddressResultsByProximity(
  List<GeocodeSearchResult> results, {
  required double latitude,
  required double longitude,
}) {
  final addressResults = results
      .where((result) => result.resultType == GeocodingConstants.resultTypeAddress)
      .toList();
  if (addressResults.length <= 1) {
    return;
  }

  addressResults.sort(
    (a, b) => _distanceSquared(a, latitude, longitude)
        .compareTo(_distanceSquared(b, latitude, longitude)),
  );

  var addressIndex = 0;
  for (var resultIndex = 0; resultIndex < results.length; resultIndex++) {
    if (results[resultIndex].resultType !=
        GeocodingConstants.resultTypeAddress) {
      continue;
    }
    results[resultIndex] = addressResults[addressIndex++];
  }
}

double _distanceSquared(
  GeocodeSearchResult result,
  double latitude,
  double longitude,
) {
  final dLat = result.latitude - latitude;
  final dLon = result.longitude - longitude;
  return (dLat * dLat) + (dLon * dLon);
}

double distanceKm(
  double fromLatitude,
  double fromLongitude,
  double toLatitude,
  double toLongitude,
) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(toLatitude - fromLatitude);
  final dLon = _toRadians(toLongitude - fromLongitude);
  final fromLat = _toRadians(fromLatitude);
  final toLat = _toRadians(toLatitude);
  final haversine = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(fromLat) *
          math.cos(toLat) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
}

double _toRadians(double degrees) => degrees * math.pi / 180;
