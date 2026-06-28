import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

abstract final class MapMarkerChangeBroadcast {
  static const channel = 'map-marker-changes';

  static const typeCreated = 'created';
  static const typeUpdated = 'updated';
  static const typeDeleted = 'deleted';
  static const typeBulk = 'bulk';

  static Future<void> created(Session session, MapMarker marker) {
    return _post(
      session,
      MapMarkerChange(
        type: typeCreated,
        marker: marker,
        markerId: marker.id,
      ),
    );
  }

  static Future<void> updated(Session session, MapMarker marker) {
    return _post(
      session,
      MapMarkerChange(
        type: typeUpdated,
        marker: marker,
        markerId: marker.id,
      ),
    );
  }

  static Future<void> deleted(Session session, UuidValue markerId) {
    return _post(
      session,
      MapMarkerChange(
        type: typeDeleted,
        markerId: markerId,
      ),
    );
  }

  static Future<void> bulk(Session session) {
    return _post(
      session,
      MapMarkerChange(type: typeBulk),
    );
  }

  static Future<void> _post(Session session, MapMarkerChange change) {
    return session.messages.postMessage(channel, change);
  }
}
