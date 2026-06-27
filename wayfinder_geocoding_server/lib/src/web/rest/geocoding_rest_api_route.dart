import 'package:serverpod/serverpod.dart';

import 'geocoding_rest_handlers.dart';
import 'rest_json.dart';

/// Geocoding-only REST API mounted at `/api`.
class GeocodingRestApiRoute extends Route {
  GeocodingRestApiRoute();

  @override
  void injectIn(RelicRouter router) {
    router
      ..get('/', _index)
      ..get('/health', _health)
      ..options('/geocoding/settings', _preflight)
      ..get('/geocoding/settings', GeocodingRestHandlers.getSettings)
      ..put('/geocoding/settings', GeocodingRestHandlers.updateSettings)
      ..get(
        '/geocoding/search-readiness',
        GeocodingRestHandlers.getSearchReadiness,
      )
      ..options('/geocoding/import', _preflight)
      ..post('/geocoding/import', GeocodingRestHandlers.startImport)
      ..delete('/geocoding/import', GeocodingRestHandlers.cancelImport)
      ..options('/geocoding/import/cancel', _preflight)
      ..post('/geocoding/import/cancel', GeocodingRestHandlers.cancelImport)
      ..options('/geocoding/import/housenumbers', _preflight)
      ..post(
        '/geocoding/import/housenumbers',
        GeocodingRestHandlers.startHousenumbersImport,
      )
      ..delete(
        '/geocoding/import/housenumbers',
        GeocodingRestHandlers.cancelHousenumbersImport,
      )
      ..options('/geocoding/import/housenumbers/cancel', _preflight)
      ..post(
        '/geocoding/import/housenumbers/cancel',
        GeocodingRestHandlers.cancelHousenumbersImport,
      )
      ..get('/geocoding/search', GeocodingRestHandlers.search)
      ..get('/geocoding/export/places', GeocodingRestHandlers.exportPlaces)
      ..get(
        '/geocoding/export/housenumbers',
        GeocodingRestHandlers.exportHousenumbers,
      )
      ..options('/geocoding/archive/places', _preflight)
      ..post('/geocoding/archive/places', GeocodingRestHandlers.importPlaces)
      ..options('/geocoding/archive/housenumbers', _preflight)
      ..post(
        '/geocoding/archive/housenumbers',
        GeocodingRestHandlers.importHousenumbers,
      )
      ..options('/geocoding/places', _preflight)
      ..delete('/geocoding/places', GeocodingRestHandlers.clearPlaces)
      ..options('/geocoding/housenumbers', _preflight)
      ..delete('/geocoding/housenumbers', GeocodingRestHandlers.clearHousenumbers);
  }

  static Future<Result> _preflight(Request request) async {
    return Response.ok(
      headers: Headers.build((mh) {
        mh.accessControlAllowOrigin =
            const AccessControlAllowOriginHeader.wildcard();
        mh.accessControlAllowMethods = AccessControlAllowMethodsHeader.methods([
          Method.get,
          Method.head,
          Method.post,
          Method.put,
          Method.patch,
          Method.delete,
          Method.options,
        ]);
        mh.accessControlAllowHeaders =
            AccessControlAllowHeadersHeader.headers([
          'Content-Type',
          'Authorization',
          'X-API-Key',
        ]);
        mh.accessControlMaxAge = 86400;
      }),
    );
  }

  static Future<Result> _index(Request request) async {
    return RestJson.ok({
      'name': 'Wayfinder Geocoding REST API',
      'resources': {
        'health': '/api/health',
        'geocodingSettings': '/api/geocoding/settings',
        'geocodingSearchReadiness': '/api/geocoding/search-readiness',
        'geocodingImport': '/api/geocoding/import',
        'geocodingSearch': '/api/geocoding/search?q=<query>',
      },
    });
  }

  static Future<Result> _health(Request request) async {
    return RestJson.ok({'status': 'ok', 'service': 'wayfinder-geocoding'});
  }

  @override
  Future<Result> handleCall(Session session, Request request) {
    throw UnimplementedError('GeocodingRestApiRoute uses injectIn sub-routes');
  }
}
