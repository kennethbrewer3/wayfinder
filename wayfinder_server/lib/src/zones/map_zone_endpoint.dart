import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import '../map/map_object_actor.dart';
import '../map/map_object_audit.dart';
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
        where: (t) => t.deletedAt.equals(null),
        orderByList: (t) => [Order(column: t.name), Order(column: t.id)],
      ),
      onSuccess: (zones) => 'count=${zones.length}',
    );
  }

  Future<List<MapZone>> listDeletedZones(Session session) {
    return loggedCall(
      session,
      _tag,
      'listDeletedZones',
      () => MapZone.db.find(
        session,
        where: (t) => t.deletedAt.notEquals(null),
        orderBy: (t) => t.deletedAt,
        orderDescending: true,
      ),
      onSuccess: (zones) => 'count=${zones.length}',
    );
  }

  Future<MapZone?> getZone(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getZone',
      () async {
        final zone = await MapZone.db.findById(session, id);
        if (zone == null || zone.deletedAt != null) {
          return null;
        }
        return zone;
      },
      onSuccess: (zone) => zone == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<MapZone> createZone(Session session, MapZone zone) {
    return loggedCall(
      session,
      _tag,
      'createZone',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final now = DateTime.now().toUtc();
        final created = await MapZone.db.insertRow(
          session,
          zone.copyWith(
            createdAt: now,
            updatedAt: now,
            createdByAuthUserId: actor.authUserId,
            createdByUsername: actor.username,
            updatedByAuthUserId: actor.authUserId,
            updatedByUsername: actor.username,
            deletedAt: null,
            deletedByAuthUserId: null,
            deletedByUsername: null,
          ),
        );
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityZone,
          entityId: created.id,
          entityName: created.name,
          action: MapObjectAudit.actionCreated,
          actor: actor,
          snapshot: created,
        );
        await MapZoneChangeBroadcast.created(session, created);
        return created;
      },
      onSuccess: (created) =>
          'id=${created.id} name="${created.name}" type=${created.type} actor=${created.createdByUsername ?? 'anonymous'}',
    );
  }

  Future<MapZone> updateZone(Session session, MapZone zone) {
    return loggedCall(
      session,
      _tag,
      'updateZone',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final before = await MapZone.db.findById(session, zone.id);
        if (before == null || before.deletedAt != null) {
          throw StateError('Zone not found: ${zone.id}');
        }
        final updated = await MapZone.db.updateRow(
          session,
          zone.copyWith(
            createdAt: before.createdAt,
            createdByAuthUserId: before.createdByAuthUserId,
            createdByUsername: before.createdByUsername,
            updatedAt: DateTime.now().toUtc(),
            updatedByAuthUserId: actor.authUserId,
            updatedByUsername: actor.username,
            deletedAt: null,
            deletedByAuthUserId: null,
            deletedByUsername: null,
          ),
        );
        await MarkerTrackingService.syncMarkerIconForTrackZone(
          session: session,
          zone: updated,
        );
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityZone,
          entityId: updated.id,
          entityName: updated.name,
          action: MapObjectAudit.actionUpdated,
          actor: actor,
          snapshot: updated,
        );
        await MapZoneChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) =>
          'id=${updated.id} visible=${updated.visible} actor=${updated.updatedByUsername ?? 'anonymous'}',
    );
  }

  Future<bool> deleteZone(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteZone',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final existing = await MapZone.db.findById(session, id);
        if (existing == null || existing.deletedAt != null) {
          return false;
        }
        final now = DateTime.now().toUtc();
        final softDeleted = await MapZone.db.updateRow(
          session,
          existing.copyWith(
            deletedAt: now,
            deletedByAuthUserId: actor.authUserId,
            deletedByUsername: actor.username,
            updatedAt: now,
            updatedByAuthUserId: actor.authUserId,
            updatedByUsername: actor.username,
          ),
        );
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityZone,
          entityId: softDeleted.id,
          entityName: softDeleted.name,
          action: MapObjectAudit.actionDeleted,
          actor: actor,
          snapshot: softDeleted,
        );
        await MapZoneChangeBroadcast.deleted(session, id);
        return true;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }

  Future<MapZone?> restoreZone(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'restoreZone',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final existing = await MapZone.db.findById(session, id);
        if (existing == null || existing.deletedAt == null) {
          return null;
        }
        final now = DateTime.now().toUtc();
        final restored = await MapZone.db.updateRow(
          session,
          existing.copyWith(
            deletedAt: null,
            deletedByAuthUserId: null,
            deletedByUsername: null,
            updatedAt: now,
            updatedByAuthUserId: actor.authUserId,
            updatedByUsername: actor.username,
          ),
        );
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityZone,
          entityId: restored.id,
          entityName: restored.name,
          action: MapObjectAudit.actionRestored,
          actor: actor,
          snapshot: restored,
        );
        await MapZoneChangeBroadcast.created(session, restored);
        return restored;
      },
      onSuccess: (restored) => restored == null
          ? 'not found id=$id'
          : 'restored id=$id name="${restored.name}"',
    );
  }

  Future<bool> purgeDeletedZone(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'purgeDeletedZone',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final existing = await MapZone.db.findById(session, id);
        if (existing == null || existing.deletedAt == null) {
          return false;
        }
        await MapZone.db.deleteRow(session, existing);
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityZone,
          entityId: id,
          entityName: existing.name,
          action: MapObjectAudit.actionPurged,
          actor: actor,
          snapshot: existing,
        );
        return true;
      },
      onSuccess: (purged) => purged ? 'purged id=$id' : 'not found id=$id',
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
