import 'package:serverpod/serverpod.dart';

import 'categories_rest_handlers.dart';
import 'markers_rest_handlers.dart';
import 'pmtiles_rest_handlers.dart';
import 'rest_json.dart';
import 'zones_rest_handlers.dart';

/// Public REST API mounted at `/api`.
class RestApiRoute extends Route {
  RestApiRoute() : super(methods: {Method.options});

  @override
  void injectIn(RelicRouter router) {
    router
      ..get('/', _index)
      ..get('/markers', MarkersRestHandlers.list)
      ..get('/markers/:id', MarkersRestHandlers.get)
      ..post('/markers', MarkersRestHandlers.create)
      ..put('/markers/:id', MarkersRestHandlers.update)
      ..patch('/markers/:id', MarkersRestHandlers.update)
      ..delete('/markers/:id', MarkersRestHandlers.delete)
      ..get('/zones', ZonesRestHandlers.list)
      ..get('/zones/:id', ZonesRestHandlers.get)
      ..post('/zones', ZonesRestHandlers.create)
      ..put('/zones/:id', ZonesRestHandlers.update)
      ..patch('/zones/:id', ZonesRestHandlers.update)
      ..delete('/zones/:id', ZonesRestHandlers.delete)
      ..get('/categories', CategoriesRestHandlers.list)
      ..get('/categories/:id', CategoriesRestHandlers.get)
      ..post('/categories', CategoriesRestHandlers.create)
      ..put('/categories/:id', CategoriesRestHandlers.update)
      ..patch('/categories/:id', CategoriesRestHandlers.update)
      ..delete('/categories/:id', CategoriesRestHandlers.delete)
      ..get('/pmtiles', PmtilesRestHandlers.list)
      ..post('/pmtiles/upload', PmtilesRestHandlers.upload)
      ..get('/pmtiles/active', PmtilesRestHandlers.getActive)
      ..put('/pmtiles/active', PmtilesRestHandlers.setActive)
      ..delete('/pmtiles/active', PmtilesRestHandlers.clearActive)
      ..delete('/pmtiles/:id', PmtilesRestHandlers.delete);
  }

  static Future<Result> _index(Request request) async {
    return RestJson.ok({
      'name': 'Wayfinder REST API',
      'resources': {
        'markers': '/api/markers',
        'zones': '/api/zones',
        'categories': '/api/categories',
        'pmtiles': '/api/pmtiles',
        'pmtilesUpload': '/api/pmtiles/upload?name=<file.pmtiles>',
        'pmtilesDownload': '/pmtiles/files/<id>',
      },
    });
  }

  @override
  Future<Result> handleCall(Session session, Request request) {
    throw UnimplementedError('RestApiRoute uses injectIn sub-routes');
  }
}
