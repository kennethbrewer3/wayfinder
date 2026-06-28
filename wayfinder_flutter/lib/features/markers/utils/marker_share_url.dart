import 'package:flutter/foundation.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../map/models/map_viewport.dart';

const markerUrlQueryParam = 'marker';
const markerShareDefaultZoom = 16.0;

UuidValue? _parseMarkerIdFromRaw(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  try {
    return UuidValue.fromString(trimmed);
  } catch (_) {
    return null;
  }
}

Uri _routeUri({
  required String path,
  required Map<String, String> queryParameters,
}) {
  return Uri(path: path, queryParameters: queryParameters);
}

/// Relative app route for go_router, e.g. `/maps?marker=…`.
String mapShareLocation(Uri routeUri) {
  if (!routeUri.hasQuery) {
    return routeUri.path;
  }
  return '${routeUri.path}?${routeUri.query}';
}

Uri absoluteWebShareUri(Uri routeUri) {
  final base = Uri.base;
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: routeUri.path,
    queryParameters: routeUri.queryParameters,
  );
}

String formatMapShareUrl(Uri routeUri) {
  if (kIsWeb) {
    return absoluteWebShareUri(routeUri).toString();
  }
  return mapShareLocation(routeUri);
}

UuidValue? parseMarkerIdFromUri(Uri uri) {
  final direct = _parseMarkerIdFromRaw(uri.queryParameters[markerUrlQueryParam]);
  if (direct != null) {
    return direct;
  }

  if (uri.fragment.isNotEmpty) {
    final fragment =
        uri.fragment.startsWith('/') ? uri.fragment : '/${uri.fragment}';
    final fromFragment = parseMarkerIdFromUri(Uri.parse('http://local$fragment'));
    if (fromFragment != null) {
      return fromFragment;
    }
  }

  final decodedPath = Uri.decodeComponent(uri.path);
  if (decodedPath.contains('?')) {
    final fromPath = parseMarkerIdFromUri(Uri.parse('http://local$decodedPath'));
    if (fromPath != null) {
      return fromPath;
    }
  }

  return null;
}

Uri buildMapShareUri({
  required MapViewport viewport,
  UuidValue? markerId,
}) {
  if (markerId != null) {
    return _routeUri(
      path: '/maps',
      queryParameters: {
        markerUrlQueryParam: markerId.toString(),
      },
    );
  }

  return _routeUri(
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
  return formatMapShareUrl(
    buildMapShareUri(viewport: viewport, markerId: markerId),
  );
}

String buildMarkerShareUrl({
  required MapMarker marker,
}) {
  return formatMapShareUrl(
    _routeUri(
      path: '/maps',
      queryParameters: {
        markerUrlQueryParam: marker.id.toString(),
      },
    ),
  );
}

MapMarker? findMarkerById(List<MapMarker> markers, UuidValue id) {
  final target = id.toString().toLowerCase();
  for (final marker in markers) {
    if (marker.id.toString().toLowerCase() == target) {
      return marker;
    }
  }
  return null;
}

bool mapShareRoutesMatch(Uri current, Uri next) {
  return current.path == next.path &&
      current.queryParameters.toString() == next.queryParameters.toString();
}
