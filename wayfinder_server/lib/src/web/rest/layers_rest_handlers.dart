import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../layers/map_layer_bootstrap.dart';
import '../../layers/map_layer_change_broadcast.dart';
import '../../map/map_marker_change_broadcast.dart';
import 'rest_json.dart';

abstract final class LayersRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final layers = await listLayersEnsuringDefault(session);
      return RestJson.ok(RestJson.encodeModels(layers));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'layer id',
      );
      final layer = await MapLayer.db.findById(session, id);
      if (layer == null) {
        return RestJson.error(404, 'Layer not found');
      }
      return RestJson.ok(RestJson.encodeModel(layer));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final layer = await _layerFromCreateBody(session, body);
      final created = await MapLayer.db.insertRow(session, layer);
      await MapLayerChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'layer id',
      );
      final existing = await MapLayer.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Layer not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await MapLayer.db.updateRow(
        session,
        _mergeLayer(existing, body),
      );
      await MapLayerChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'layer id',
      );

      final layers = await MapLayer.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      if (layers.length <= 1) {
        return RestJson.error(400, 'Cannot delete the last map layer');
      }

      final existing = await MapLayer.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Layer not found');
      }

      final fallback = layers.firstWhere((layer) => layer.id != id);

      await MapMarker.db.updateWhere(
        session,
        where: (t) => t.layerId.equals(id),
        columnValues: (t) => [t.layerId(fallback.id)],
      );
      await MapZone.db.updateWhere(
        session,
        where: (t) => t.layerId.equals(id),
        columnValues: (t) => [t.layerId(fallback.id)],
      );

      await MapLayer.db.deleteWhere(
        session,
        where: (t) => t.id.equals(id),
      );
      await MapLayerChangeBroadcast.deleted(session, id);
      await MapMarkerChangeBroadcast.bulk(session);
      return RestJson.noContent();
    });
  }

  static Future<Result> reorder(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final entries = body['layers'];
      if (entries is! List) {
        throw const FormatException('Field "layers" must be an array');
      }

      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Each layer entry must be an object');
        }
        final id = RestJson.parseUuid(entry['id'], label: 'layer id');
        final sortOrder = entry['sortOrder'];
        if (sortOrder is! int) {
          throw const FormatException('Field "sortOrder" is required');
        }

        final existing = await MapLayer.db.findById(session, id);
        if (existing == null) {
          return RestJson.error(404, 'Layer not found: $id');
        }

        await MapLayer.db.updateRow(
          session,
          existing.copyWith(
            sortOrder: sortOrder,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }

      final layers = await MapLayer.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      await MapLayerChangeBroadcast.bulk(session);
      return RestJson.ok(RestJson.encodeModels(layers));
    });
  }

  static Future<MapLayer> _layerFromCreateBody(
    Session session,
    Map<String, dynamic> body,
  ) async {
    final name = body['name'];
    if (name is! String || name.isEmpty) {
      throw const FormatException('Field "name" is required');
    }

    final existing = await MapLayer.db.find(
      session,
      orderBy: (t) => t.sortOrder,
    );
    final nextSortOrder = existing.isEmpty
        ? 0
        : existing
                  .map((layer) => layer.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final now = DateTime.now().toUtc();
    return MapLayer(
      name: name,
      sortOrder: body['sortOrder'] is int
          ? body['sortOrder'] as int
          : nextSortOrder,
      visible: body['visible'] is bool ? body['visible'] as bool : true,
      createdAt: now,
      updatedAt: now,
    );
  }

  static MapLayer _mergeLayer(
    MapLayer existing,
    Map<String, dynamic> body,
  ) {
    return existing.copyWith(
      name: body['name'] is String ? body['name'] as String : existing.name,
      sortOrder: body['sortOrder'] is int
          ? body['sortOrder'] as int
          : existing.sortOrder,
      visible: body['visible'] is bool
          ? body['visible'] as bool
          : existing.visible,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
