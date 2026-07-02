import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

abstract final class MapLayerChangeBroadcast {
  static const channel = 'map-layer-changes';

  static const typeCreated = 'created';
  static const typeUpdated = 'updated';
  static const typeDeleted = 'deleted';
  static const typeBulk = 'bulk';

  static Future<void> created(Session session, MapLayer layer) {
    return _post(
      session,
      MapLayerChange(
        type: typeCreated,
        layer: layer,
        layerId: layer.id,
      ),
    );
  }

  static Future<void> updated(Session session, MapLayer layer) {
    return _post(
      session,
      MapLayerChange(
        type: typeUpdated,
        layer: layer,
        layerId: layer.id,
      ),
    );
  }

  static Future<void> deleted(Session session, UuidValue layerId) {
    return _post(
      session,
      MapLayerChange(
        type: typeDeleted,
        layerId: layerId,
      ),
    );
  }

  static Future<void> bulk(Session session) {
    return _post(
      session,
      MapLayerChange(type: typeBulk),
    );
  }

  static Future<void> _post(Session session, MapLayerChange change) {
    return session.messages.postMessage(channel, change);
  }
}
