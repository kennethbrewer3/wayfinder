import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';

class MapZoneEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapZone';

  Future<List<MapZone>> listZones(Session session) {
    return loggedCall(
      session,
      _tag,
      'listZones',
      () => MapZone.db.find(
        session,
        orderBy: (t) => t.name,
      ),
      onSuccess: (zones) => 'count=${zones.length}',
    );
  }

  Future<MapZone?> getZone(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getZone',
      () => MapZone.db.findById(session, id),
      onSuccess: (zone) => zone == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<MapZone> createZone(Session session, MapZone zone) {
    return loggedCall(
      session,
      _tag,
      'createZone',
      () async {
        final now = DateTime.now().toUtc();
        return MapZone.db.insertRow(
          session,
          zone.copyWith(
            createdAt: now,
            updatedAt: now,
          ),
        );
      },
      onSuccess: (created) =>
          'id=${created.id} name="${created.name}" type=${created.type}',
    );
  }

  Future<MapZone> updateZone(Session session, MapZone zone) {
    return loggedCall(
      session,
      _tag,
      'updateZone',
      () => MapZone.db.updateRow(
        session,
        zone.copyWith(updatedAt: DateTime.now().toUtc()),
      ),
      onSuccess: (updated) => 'id=${updated.id} visible=${updated.visible}',
    );
  }

  Future<bool> deleteZone(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteZone',
      () async {
        final deleted = await MapZone.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }
}
