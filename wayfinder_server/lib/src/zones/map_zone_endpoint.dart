import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import '../map/marker_tracking_service.dart';
import 'map_zone_change_broadcast.dart';

class MapZoneEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapZone';

  Future<List<MapZone>> listZones(Session session) {
    return loggedCall(
      session,
      _tag,
      'listZones',
      () => MapZone.db.find(
        session,
        orderByList: (t) => [Order(column: t.name), Order(column: t.id)],
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
        final created = await MapZone.db.insertRow(
          session,
          zone.copyWith(
            createdAt: now,
            updatedAt: now,
          ),
        );
        await MapZoneChangeBroadcast.created(session, created);
        return created;
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
      () async {
        final updated = await MapZone.db.updateRow(
          session,
          zone.copyWith(updatedAt: DateTime.now().toUtc()),
        );
        await MarkerTrackingService.syncMarkerIconForTrackZone(
          session: session,
          zone: updated,
        );
        await MapZoneChangeBroadcast.updated(session, updated);
        return updated;
      },
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
        if (deleted.isNotEmpty) {
          await MapZoneChangeBroadcast.deleted(session, id);
        }
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }

  Stream<MapZoneChange> zoneChanges(Session session) async* {
    final changes = session.messages.createStream<MapZoneChange>(
      MapZoneChangeBroadcast.channel,
    );
    await for (final change in changes) {
      yield change;
    }
  }
}
