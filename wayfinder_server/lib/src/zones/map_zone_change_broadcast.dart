import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

abstract final class MapZoneChangeBroadcast {
  static const channel = 'map-zone-changes';

  static const typeCreated = 'created';
  static const typeUpdated = 'updated';
  static const typeDeleted = 'deleted';
  static const typeBulk = 'bulk';

  static Future<void> created(Session session, MapZone zone) {
    return _post(
      session,
      MapZoneChange(
        type: typeCreated,
        zone: zone,
        zoneId: zone.id,
      ),
    );
  }

  static Future<void> updated(Session session, MapZone zone) {
    return _post(
      session,
      MapZoneChange(
        type: typeUpdated,
        zone: zone,
        zoneId: zone.id,
      ),
    );
  }

  static Future<void> deleted(Session session, UuidValue zoneId) {
    return _post(
      session,
      MapZoneChange(
        type: typeDeleted,
        zoneId: zoneId,
      ),
    );
  }

  static Future<void> bulk(Session session) {
    return _post(
      session,
      MapZoneChange(type: typeBulk),
    );
  }

  static Future<void> _post(Session session, MapZoneChange change) {
    return session.messages.postMessage(channel, change);
  }
}
