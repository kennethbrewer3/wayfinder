import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wayfinder_routing_server/src/config.dart';
import 'package:wayfinder_routing_server/src/polyline.dart';
import 'package:wayfinder_routing_server/src/routing_log.dart';

/// HTTP client that proxies routing requests to GraphHopper.
class GraphHopperClient {
  GraphHopperClient(this.config, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final RoutingConfig config;
  final http.Client _http;

  Future<bool> checkHealth() async {
    try {
      final response = await _http
          .get(Uri.parse('${config.graphHopperUrl}/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } on Object catch (error) {
      routingLog.fine('GraphHopper health check failed: $error');
      return false;
    }
  }

  Future<Map<String, dynamic>> route({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
    String profile = 'foot',
  }) async {
    final uri = Uri.parse('${config.graphHopperUrl}/route');
    final bodyMap = <String, dynamic>{
      'points': [
        [fromLon, fromLat],
        [toLon, toLat],
      ],
      'profile': profile,
      'instructions': true,
      'points_encoded': false,
      'locale': 'en',
    };
    // Existing graphs may only have CH prepared for `car` (older config).
    // Flat `ch.disable` is required for foot/bike on those graphs. Keep CH
    // enabled for car when available — faster and avoids flexible-mode edge
    // cases on large extracts.
    if (profile != 'car') {
      bodyMap['ch.disable'] = true;
    }
    final body = jsonEncode(bodyMap);

    routingLog.info(
      'Route request profile=$profile '
      'from=($fromLat,$fromLon) to=($toLat,$toLon)',
    );
    final startedAt = DateTime.now();
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      routingLog.warning(
        'GraphHopper /route failed '
        '(${response.statusCode}): ${response.body}',
      );
      throw GraphHopperRouteException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final route = translateGraphHopperRoute(decoded);
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    final distance = route['distanceMeters'];
    final instructions = route['instructions'];
    final instructionCount = instructions is List ? instructions.length : 0;
    routingLog.info(
      'Route OK in ${elapsedMs}ms '
      '(distanceMeters=$distance, instructions=$instructionCount)',
    );
    return route;
  }

  void dispose() {
    _http.close();
  }
}

class GraphHopperRouteException implements Exception {
  GraphHopperRouteException({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  String toString() => 'GraphHopper route failed ($statusCode): $body';
}

/// Converts a GraphHopper `/route` JSON payload to the Wayfinder route shape.
Map<String, dynamic> translateGraphHopperRoute(Map<String, dynamic> gh) {
  final paths = gh['paths'] as List<dynamic>?;
  if (paths == null || paths.isEmpty) {
    throw StateError('GraphHopper returned no paths');
  }

  final path = paths.first as Map<String, dynamic>;
  final distanceMeters = (path['distance'] as num?)?.toDouble() ?? 0;
  final timeMs = (path['time'] as num?)?.toInt() ?? 0;

  final pointsEncoded = path['points_encoded'] as bool? ?? false;
  final rawPoints = path['points'];
  final points = <Map<String, double>>[];

  // GH returns either:
  // - encoded polyline string (`points_encoded: true`)
  // - [[lon,lat], ...] list
  // - GeoJSON LineString `{type, coordinates: [[lon,lat], ...]}`
  final List<dynamic>? coordinateList;
  if (rawPoints is List) {
    coordinateList = rawPoints;
  } else if (rawPoints is Map) {
    final coordinates = rawPoints['coordinates'];
    coordinateList = coordinates is List ? coordinates : null;
  } else {
    coordinateList = null;
  }

  if (coordinateList != null) {
    for (final coordinate in coordinateList) {
      if (coordinate is List && coordinate.length >= 2) {
        points.add({
          'lat': (coordinate[1] as num).toDouble(),
          'lon': (coordinate[0] as num).toDouble(),
        });
      }
    }
  } else if (rawPoints is String && (pointsEncoded || rawPoints.isNotEmpty)) {
    for (final pair in decodePolyline(rawPoints)) {
      points.add({'lat': pair[0], 'lon': pair[1]});
    }
  }

  final instructions = <Map<String, dynamic>>[];
  final rawInstructions = path['instructions'] as List<dynamic>?;
  if (rawInstructions != null) {
    for (final item in rawInstructions) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      instructions.add({
        'text': item['text'] as String? ?? '',
        if (item['street_name'] != null)
          'streetName': item['street_name'] as String,
        'distanceMeters': (item['distance'] as num?)?.toDouble() ?? 0,
        'timeMs': (item['time'] as num?)?.toInt() ?? 0,
        if (item['sign'] != null) 'sign': item['sign'],
        if (item['interval'] != null) 'interval': item['interval'],
      });
    }
  }

  return {
    'distanceMeters': distanceMeters,
    'timeMs': timeMs,
    'points': points,
    'instructions': instructions,
  };
}

const supportedRoutingProfiles = {'foot', 'bike', 'car'};

String normalizeRoutingProfile(String? profile) {
  final value = (profile ?? 'foot').toLowerCase();
  if (!supportedRoutingProfiles.contains(value)) {
    throw ArgumentError('Unsupported profile: $profile');
  }
  return value;
}
