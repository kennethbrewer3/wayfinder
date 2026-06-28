import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/constants.dart';
import '../../map/models/map_viewport.dart';

const markerUrlQueryParam = 'marker';
const markerShareDefaultZoom = 16.0;

UuidValue? parseMarkerIdFromUri(Uri uri) {
  final raw = uri.queryParameters[markerUrlQueryParam]?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    return UuidValue.fromString(raw);
  } catch (_) {
    return null;
  }
}

Uri buildMapShareUri({
  required MapViewport viewport,
  UuidValue? markerId,
}) {
  final queryParameters = <String, String>{
    'lat': viewport.center.latitude.toStringAsFixed(6),
    'lng': viewport.center.longitude.toStringAsFixed(6),
    'zoom': viewport.zoom.toStringAsFixed(2),
  };
  if (markerId != null) {
    queryParameters[markerUrlQueryParam] = markerId.toString();
  }
  return Uri(path: '/maps', queryParameters: queryParameters);
}

String buildMapShareUrl({
  required MapViewport viewport,
  UuidValue? markerId,
}) {
  final uri = buildMapShareUri(viewport: viewport, markerId: markerId);
  if (kIsWeb) {
    return Uri.base
        .replace(
          path: uri.path,
          queryParameters: uri.queryParameters,
          fragment: uri.fragment,
        )
        .toString();
  }
  return uri.toString();
}

String buildMarkerShareUrl({
  required MapMarker marker,
  double zoom = markerShareDefaultZoom,
}) {
  return buildMapShareUrl(
    viewport: MapViewport(
      center: LatLng(marker.latitude, marker.longitude),
      zoom: zoom.clamp(0, AppConstants.maxMapZoom),
    ),
    markerId: marker.id,
  );
}

MapMarker? findMarkerById(List<MapMarker> markers, UuidValue id) {
  for (final marker in markers) {
    if (marker.id == id) {
      return marker;
    }
  }
  return null;
}
