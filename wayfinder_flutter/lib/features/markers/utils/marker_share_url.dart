import 'package:flutter/foundation.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

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
  if (markerId != null) {
    return Uri(
      path: '/maps',
      queryParameters: {
        markerUrlQueryParam: markerId.toString(),
      },
    );
  }

  return Uri(
    path: '/maps',
    queryParameters: {
      'lat': viewport.center.latitude.toStringAsFixed(6),
      'lng': viewport.center.longitude.toStringAsFixed(6),
      'zoom': viewport.zoom.toStringAsFixed(2),
    },
  );
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
}) {
  final uri = Uri(
    path: '/maps',
    queryParameters: {
      markerUrlQueryParam: marker.id.toString(),
    },
  );
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

MapMarker? findMarkerById(List<MapMarker> markers, UuidValue id) {
  for (final marker in markers) {
    if (marker.id == id) {
      return marker;
    }
  }
  return null;
}
