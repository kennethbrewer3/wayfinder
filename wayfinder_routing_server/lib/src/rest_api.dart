import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:wayfinder_routing_server/src/graphhopper_client.dart';
import 'package:wayfinder_routing_server/src/graphhopper_process.dart';
import 'package:wayfinder_routing_server/src/import_service.dart';
import 'package:wayfinder_routing_server/src/regions.dart';
import 'package:wayfinder_routing_server/src/routing_log.dart';
import 'package:wayfinder_routing_server/src/status_store.dart';

Handler createRestHandler({
  required StatusStore statusStore,
  required ImportService importService,
  required GraphHopperProcess graphHopperProcess,
  required GraphHopperClient graphHopperClient,
}) {
  final router = Router();

  router.get('/', _indexHandler);
  router.get('/api/', _indexHandler);
  router.get('/api/health', (Request request) async {
    final ghHealthy = await graphHopperClient.checkHealth();
    final snapshot = statusStore.current;
    return _jsonResponse(
      {
        'ok': true,
        'service': 'wayfinder-routing',
        'ready': snapshot.ready && ghHealthy,
        'graphhopper': ghHealthy,
        'buildSha': routingBuildSha,
        'buildTime': routingBuildTime,
      },
    );
  });

  router.get('/api/routing/status', (Request request) async {
    final ghHealthy = await graphHopperClient.checkHealth();
    final snapshot = statusStore.current;
    final osm = await importService.localOsmInventory();
    final graphCachePresent = await graphHopperProcess.graphCacheExists();
    return _jsonResponse({
      ...snapshot.toJson(),
      'graphhopperUp': ghHealthy,
      'importInProgress': importService.isImporting,
      'osmPbfPresent': osm.present,
      'osmPbfBytes': osm.bytes,
      'graphCachePresent': graphCachePresent,
    });
  });

  router.get('/api/routing/regions', (Request request) {
    return _jsonResponse({
      'regions': presetRoutingRegions.map((r) => r.toJson()).toList(),
    });
  });

  router.post('/api/routing/import', (Request request) async {
    if (importService.isImporting) {
      routingLog.warning('Rejected import: already in progress');
      return _jsonResponse(
        {'error': 'Import already in progress'},
        statusCode: 409,
      );
    }

    final body = await _readJsonBody(request);
    final regionId = body['regionId'] as String?;
    final sourceUrl = body['sourceUrl'] as String?;
    final forceRedownload = body['forceRedownload'] == true;
    final useLocalPbf = body['useLocalPbf'] == true;
    final regionIdsRaw = body['regionIds'];
    final regionIds = <String>[];
    if (regionIdsRaw is List) {
      for (final item in regionIdsRaw) {
        if (item is String && item.trim().isNotEmpty) {
          regionIds.add(item.trim());
        }
      }
    }
    routingLog.info(
      'POST /api/routing/import body='
      '{regionId: ${regionId ?? 'null'}, regionIds: $regionIds, '
      'sourceUrl: ${sourceUrl ?? 'null'}, '
      'forceRedownload: $forceRedownload, useLocalPbf: $useLocalPbf}',
    );

    try {
      await importService.startImport(
        regionId: regionId,
        regionIds: regionIds.isEmpty ? null : regionIds,
        sourceUrl: sourceUrl,
        forceRedownload: forceRedownload,
        useLocalPbf: useLocalPbf,
      );
      routingLog.info(
        'Import accepted (regionId=${regionId ?? 'none'}, '
        'regionIds=$regionIds, '
        'sourceUrl=${sourceUrl ?? 'from region'}, useLocalPbf=$useLocalPbf)',
      );
      return _jsonResponse({'started': true});
    } on ArgumentError catch (error) {
      routingLog.warning('Import rejected: ${error.message}');
      return _jsonResponse({'error': error.message}, statusCode: 400);
    } on StateError catch (error) {
      routingLog.warning('Import rejected: ${error.message}');
      return _jsonResponse({'error': error.message}, statusCode: 409);
    }
  });

  /// Upload / install a local `.osm.pbf` (raw body stream).
  ///
  /// Prefer copying multi‑GB extracts onto the host data volume with
  /// `scp`/`rsync`, then POST `/api/routing/import` with `useLocalPbf: true`.
  /// This endpoint is for when the client can stream the file to the server.
  ///
  /// Headers:
  /// - `Content-Type: application/octet-stream` (recommended)
  /// - `X-Wayfinder-Osm-Filename: us-latest.osm.pbf` (optional label)
  /// Query: `?build=true` (default) or `?build=false` to only store the file.
  router.post('/api/routing/osm', (Request request) async {
    if (importService.isImporting) {
      routingLog.warning('Rejected OSM upload: import already in progress');
      return _jsonResponse(
        {'error': 'Import already in progress'},
        statusCode: 409,
      );
    }

    final buildParam = request.url.queryParameters['build'];
    final startBuild = buildParam != 'false' && buildParam != '0';
    final filename =
        request.headers['x-wayfinder-osm-filename'] ??
        request.headers['x-filename'];

    routingLog.info(
      'POST /api/routing/osm startBuild=$startBuild '
      'filename=${filename ?? 'osm.pbf'}',
    );

    try {
      final result = await importService.installLocalPbf(
        bytes: request.read(),
        filename: filename,
        startBuild: startBuild,
      );
      return _jsonResponse({
        'uploaded': true,
        'bytes': result.bytes,
        'path': result.path,
        'sourceUrl': result.sourceUrl,
        'buildStarted': result.buildStarted,
      });
    } on ArgumentError catch (error) {
      return _jsonResponse({'error': error.message}, statusCode: 400);
    } on StateError catch (error) {
      return _jsonResponse({'error': error.message}, statusCode: 409);
    } on Object catch (error, stackTrace) {
      routingLog.severe('OSM upload failed', error, stackTrace);
      return _jsonResponse({'error': error.toString()}, statusCode: 500);
    }
  });

  router.post('/api/routing/import/cancel', (Request request) async {
    routingLog.info('Import cancel endpoint called');
    await importService.cancelImport();
    return _jsonResponse({'cancelled': true});
  });

  router.post('/api/routing/route', (Request request) async {
    final snapshot = statusStore.current;
    final ghHealthy = await graphHopperClient.checkHealth();
    if (!snapshot.ready || !ghHealthy) {
      routingLog.warning(
        'Route rejected: engine not ready '
        '(status=${snapshot.status.name}, graphhopperUp=$ghHealthy)',
      );
      return _jsonResponse(
        {
          'error': 'Routing engine is not ready. Import OSM data first.',
          'status': snapshot.status.name,
          'graphhopperUp': ghHealthy,
        },
        statusCode: 503,
      );
    }

    final body = await _readJsonBody(request);
    final from = body['from'] as Map<String, dynamic>?;
    final to = body['to'] as Map<String, dynamic>?;
    if (from == null || to == null) {
      routingLog.warning('Route rejected: missing from/to');
      return _jsonResponse(
        {'error': 'Request body must include from and to coordinates'},
        statusCode: 400,
      );
    }

    try {
      final profile = normalizeRoutingProfile(body['profile'] as String?);
      final route = await graphHopperClient.route(
        fromLat: _requireCoordinate(from, 'lat'),
        fromLon: _requireCoordinate(from, 'lon'),
        toLat: _requireCoordinate(to, 'lat'),
        toLon: _requireCoordinate(to, 'lon'),
        profile: profile,
      );
      return _jsonResponse(route);
    } on ArgumentError catch (error) {
      routingLog.warning('Route rejected: ${error.message}');
      return _jsonResponse({'error': error.message}, statusCode: 400);
    } on GraphHopperRouteException catch (error) {
      routingLog.severe('Route proxy failed: $error');
      return _jsonResponse({'error': error.toString()}, statusCode: 502);
    } on StateError catch (error) {
      routingLog.severe('Route failed: $error');
      return _jsonResponse({'error': error.toString()}, statusCode: 502);
    }
  });

  return router.call;
}

Response _indexHandler(Request request) {
  return _jsonResponse({
    'service': 'wayfinder-routing',
    'endpoints': [
      'GET /api/health',
      'GET /api/routing/status',
      'GET /api/routing/regions',
      'POST /api/routing/import',
      'POST /api/routing/osm',
      'POST /api/routing/import/cancel',
      'POST /api/routing/route',
    ],
  });
}

Future<Map<String, dynamic>> _readJsonBody(Request request) async {
  final raw = await request.readAsString();
  if (raw.trim().isEmpty) {
    return {};
  }
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw ArgumentError('Expected JSON object body');
  }
  return decoded;
}

double _requireCoordinate(Map<String, dynamic> point, String key) {
  final value = point[key];
  if (value is! num) {
    throw ArgumentError('Missing or invalid coordinate: $key');
  }
  return value.toDouble();
}

Response _jsonResponse(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}
