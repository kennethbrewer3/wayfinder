import 'package:serverpod/serverpod.dart';

import 'geocoding_rest_handlers.dart';
import 'rest_json.dart';

/// Geocoding-only REST API mounted at `/api`.
class GeocodingRestApiRoute extends Route {
  GeocodingRestApiRoute() : super(methods: {Method.options});

  @override
  void injectIn(RelicRouter router) {
    router
      ..options('/**', _preflight)
      ..get('/', _index)
      ..get('/health', _health)
      ..get('/geocoding/settings', GeocodingRestHandlers.getSettings)
      ..get(
        '/geocoding/search-readiness',
        GeocodingRestHandlers.getSearchReadiness,
      )
      ..put('/geocoding/settings', GeocodingRestHandlers.updateSettings)
      ..post('/geocoding/import', GeocodingRestHandlers.startImport)
      ..delete('/geocoding/import', GeocodingRestHandlers.cancelImport)
      ..post('/geocoding/import/cancel', GeocodingRestHandlers.cancelImport)
      ..post(
        '/geocoding/import/housenumbers',
        GeocodingRestHandlers.startHousenumbersImport,
      )
      ..delete(
        '/geocoding/import/housenumbers',
        GeocodingRestHandlers.cancelHousenumbersImport,
      )
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
      ..post('/geocoding/archive/places', GeocodingRestHandlers.importPlaces)
      ..post(
        '/geocoding/archive/housenumbers',
        GeocodingRestHandlers.importHousenumbers,
      )
      ..delete('/geocoding/places', GeocodingRestHandlers.clearPlaces)
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
