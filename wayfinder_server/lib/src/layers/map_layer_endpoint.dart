import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'map_layer_bootstrap.dart';

class MapLayerEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapLayer';

  Future<List<MapLayer>> listLayers(Session session) {
    return loggedCall(
      session,
      _tag,
      'listLayers',
      () => listLayersEnsuringDefault(session),
      onSuccess: (layers) => 'count=${layers.length}',
    );
  }

  Future<MapLayer?> getLayer(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getLayer',
      () => MapLayer.db.findById(session, id),
      onSuccess: (layer) =>
          layer == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<MapLayer> createLayer(Session session, MapLayer layer) {
    return loggedCall(
      session,
      _tag,
      'createLayer',
      () => MapLayer.db.insertRow(session, layer),
      onSuccess: (created) => 'id=${created.id} name="${created.name}"',
    );
  }

  Future<MapLayer> updateLayer(Session session, MapLayer layer) {
    return loggedCall(
      session,
      _tag,
      'updateLayer',
      () => MapLayer.db.updateRow(session, layer),
      onSuccess: (updated) =>
          'id=${updated.id} sortOrder=${updated.sortOrder} visible=${updated.visible}',
    );
  }

  Future<bool> deleteLayer(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteLayer',
      () async {
        final layers = await MapLayer.db.find(
          session,
          orderBy: (t) => t.sortOrder,
        );
        if (layers.length <= 1) {
          throw Exception('Cannot delete the last map layer');
        }

        final fallback = layers.firstWhere(
          (layer) => layer.id != id,
          orElse: () => throw Exception('No fallback layer available'),
        );

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

        final deleted = await MapLayer.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }

  Future<List<MapLayer>> reorderLayers(
    Session session,
    List<MapLayer> layers,
  ) {
    return loggedCall(
      session,
      _tag,
      'reorderLayers',
      () async {
        final updated = <MapLayer>[];
        for (final layer in layers) {
          updated.add(await MapLayer.db.updateRow(session, layer));
        }
        return MapLayer.db.find(
          session,
          orderBy: (t) => t.sortOrder,
        );
      },
      onSuccess: (result) => 'count=${result.length}',
    );
  }
}
