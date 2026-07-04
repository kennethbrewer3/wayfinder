import 'package:serverpod/serverpod.dart';

import 'app_settings_rest_handlers.dart';
import 'categories_rest_handlers.dart';
import 'health_rest_handlers.dart';
import 'layers_rest_handlers.dart';
import 'map_data_rest_handlers.dart';
import 'markers_rest_handlers.dart';
import 'marker_icon_categories_rest_handlers.dart';
import 'marker_icons_rest_handlers.dart';
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
      ..get('/health', HealthRestHandlers.check)
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
      ..get('/layers', LayersRestHandlers.list)
      ..post('/layers/reorder', LayersRestHandlers.reorder)
      ..get('/layers/:id', LayersRestHandlers.get)
      ..post('/layers', LayersRestHandlers.create)
      ..put('/layers/:id', LayersRestHandlers.update)
      ..patch('/layers/:id', LayersRestHandlers.update)
      ..delete('/layers/:id', LayersRestHandlers.delete)
      ..get('/map-data', MapDataRestHandlers.export)
      ..post('/map-data/restore', MapDataRestHandlers.restore)
      ..get('/pmtiles', PmtilesRestHandlers.list)
      ..post('/pmtiles/upload', PmtilesRestHandlers.upload)
      ..get('/pmtiles/active', PmtilesRestHandlers.getActive)
      ..put('/pmtiles/active', PmtilesRestHandlers.setActive)
      ..delete('/pmtiles/active', PmtilesRestHandlers.clearActive)
      ..delete('/pmtiles/:id', PmtilesRestHandlers.delete)
      ..get('/marker-icons', MarkerIconsRestHandlers.list)
      ..post('/marker-icons', MarkerIconsRestHandlers.create)
      ..get('/marker-icons/:key', MarkerIconsRestHandlers.get)
      ..put('/marker-icons/:key', MarkerIconsRestHandlers.update)
      ..patch('/marker-icons/:key', MarkerIconsRestHandlers.update)
      ..delete('/marker-icons/:key', MarkerIconsRestHandlers.delete)
      ..post('/marker-icons/:key/svg', MarkerIconsRestHandlers.uploadSvg)
      ..get('/marker-icon-categories', MarkerIconCategoriesRestHandlers.list)
      ..post('/marker-icon-categories', MarkerIconCategoriesRestHandlers.create)
      ..get(
        '/marker-icon-categories/:key',
        MarkerIconCategoriesRestHandlers.get,
      )
      ..put(
        '/marker-icon-categories/:key',
        MarkerIconCategoriesRestHandlers.update,
      )
      ..patch(
        '/marker-icon-categories/:key',
        MarkerIconCategoriesRestHandlers.update,
      )
      ..delete(
        '/marker-icon-categories/:key',
        MarkerIconCategoriesRestHandlers.delete,
      )
      ..get('/settings/home', AppSettingsRestHandlers.getHomeLocation)
      ..put('/settings/home', AppSettingsRestHandlers.updateHomeLocation)
      ..delete('/settings/home', AppSettingsRestHandlers.resetHomeLocation)
      ..get(
        '/settings/pmtiles-storage',
        AppSettingsRestHandlers.getPmtilesStoragePath,
      )
      ..put(
        '/settings/pmtiles-storage',
        AppSettingsRestHandlers.updatePmtilesStoragePath,
      )
      ..get(
        '/settings/client-preferences',
        AppSettingsRestHandlers.getClientPreferences,
      )
      ..put(
        '/settings/client-preferences',
        AppSettingsRestHandlers.updateClientPreferences,
      );
  }

  static Future<Result> _index(Request request) async {
    return RestJson.ok({
      'name': 'Wayfinder REST API',
      'resources': {
        'health': '/api/health',
        'markers': '/api/markers',
        'zones': '/api/zones',
        'categories': '/api/categories',
        'layers': '/api/layers',
        'mapData': '/api/map-data',
        'mapDataRestore': '/api/map-data/restore',
        'pmtiles': '/api/pmtiles',
        'pmtilesUpload': '/api/pmtiles/upload?name=<file.pmtiles>',
        'pmtilesDownload': '/pmtiles/files/<id>',
        'markerIcons': '/api/marker-icons',
        'markerIconSvgUpload': '/api/marker-icons/<key>/svg',
        'markerIconSvgUploadWeb': '/marker-icons/upload?key=<key>',
        'markerIconDownload': '/marker-icons/files/<key>.svg',
      },
    });
  }

  @override
  Future<Result> handleCall(Session session, Request request) {
    throw UnimplementedError('RestApiRoute uses injectIn sub-routes');
  }
}
