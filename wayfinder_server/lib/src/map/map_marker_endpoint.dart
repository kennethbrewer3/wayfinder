import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import '../markers/marker_attachment_service.dart';
import 'map_marker_change_broadcast.dart';
import 'map_object_actor.dart';
import 'map_object_audit.dart';
import 'marker_tracking_service.dart';
import 'marker_weather_json.dart';

class MapMarkerEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapMarker';

  Future<List<MapMarker>> listMarkers(Session session) {
    return loggedCall(
      session,
      _tag,
      'listMarkers',
      () => MapMarker.db.find(
        session,
        where: (t) => t.deletedAt.equals(null),
        orderBy: (t) => t.name,
      ),
      onSuccess: (markers) => 'count=${markers.length}',
    );
  }

  Future<List<MapMarker>> listDeletedMarkers(Session session) {
    return loggedCall(
      session,
      _tag,
      'listDeletedMarkers',
      () => MapMarker.db.find(
        session,
        where: (t) => t.deletedAt.notEquals(null),
        orderBy: (t) => t.deletedAt,
        orderDescending: true,
      ),
      onSuccess: (markers) => 'count=${markers.length}',
    );
  }

  Future<MapMarker?> getMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getMarker',
      () async {
        final marker = await MapMarker.db.findById(session, id);
        if (marker == null || marker.deletedAt != null) {
          return null;
        }
        return marker;
      },
      onSuccess: (marker) =>
          marker == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<MapMarker> createMarker(Session session, MapMarker marker) {
    return loggedCall(
      session,
      _tag,
      'createMarker',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final now = DateTime.now().toUtc();
        var created = await MapMarker.db.insertRow(
          session,
          marker.copyWith(
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
        created = await _applyTrackingChanges(
          session: session,
          before: null,
          after: created,
        );
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityMarker,
          entityId: created.id,
          entityName: created.name,
          action: MapObjectAudit.actionCreated,
          actor: actor,
          snapshot: created,
        );
        await MapMarkerChangeBroadcast.created(session, created);
        return created;
      },
      onSuccess: (created) =>
          'id=${created.id} name="${created.name}" lat=${created.latitude} lng=${created.longitude} actor=${created.createdByUsername ?? 'anonymous'}',
    );
  }

  Future<MapMarker> updateMarker(Session session, MapMarker marker) {
    return loggedCall(
      session,
      _tag,
      'updateMarker',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final before = await MapMarker.db.findById(session, marker.id);
        if (before == null || before.deletedAt != null) {
          throw StateError('Marker not found: ${marker.id}');
        }
        var incoming = marker;
        if (incoming.trackZoneId == null && before.trackZoneId != null) {
          incoming = incoming.copyWith(trackZoneId: before.trackZoneId);
        }
        incoming = incoming.copyWith(
          weatherJson: preserveWeatherJsonDisplayUnits(
            before.weatherJson,
            incoming.weatherJson,
          ),
          createdAt: before.createdAt,
          createdByAuthUserId: before.createdByAuthUserId,
          createdByUsername: before.createdByUsername,
          updatedAt: DateTime.now().toUtc(),
          updatedByAuthUserId: actor.authUserId,
          updatedByUsername: actor.username,
          deletedAt: null,
          deletedByAuthUserId: null,
          deletedByUsername: null,
        );
        var updated = await MapMarker.db.updateRow(session, incoming);
        updated = await _applyTrackingChanges(
          session: session,
          before: before,
          after: updated,
        );
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityMarker,
          entityId: updated.id,
          entityName: updated.name,
          action: MapObjectAudit.actionUpdated,
          actor: actor,
          snapshot: updated,
        );
        await MapMarkerChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) =>
          'id=${updated.id} visible=${updated.visible} tracking=${updated.isTracking} actor=${updated.updatedByUsername ?? 'anonymous'}',
    );
  }

  Future<bool> deleteMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteMarker',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final existing = await MapMarker.db.findById(session, id);
        if (existing == null || existing.deletedAt != null) {
          return false;
        }
        await MarkerTrackingService.processMarkerDelete(
          session: session,
          marker: existing,
        );
        final now = DateTime.now().toUtc();
        final softDeleted = await MapMarker.db.updateRow(
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
          entityType: MapObjectAudit.entityMarker,
          entityId: softDeleted.id,
          entityName: softDeleted.name,
          action: MapObjectAudit.actionDeleted,
          actor: actor,
          snapshot: softDeleted,
        );
        await MapMarkerChangeBroadcast.deleted(session, id);
        return true;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }

  Future<MapMarker?> restoreMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'restoreMarker',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final existing = await MapMarker.db.findById(session, id);
        if (existing == null || existing.deletedAt == null) {
          return null;
        }
        final now = DateTime.now().toUtc();
        final restored = await MapMarker.db.updateRow(
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
          entityType: MapObjectAudit.entityMarker,
          entityId: restored.id,
          entityName: restored.name,
          action: MapObjectAudit.actionRestored,
          actor: actor,
          snapshot: restored,
        );
        await MapMarkerChangeBroadcast.created(session, restored);
        return restored;
      },
      onSuccess: (restored) => restored == null
          ? 'not found id=$id'
          : 'restored id=$id name="${restored.name}"',
    );
  }

  Future<bool> purgeDeletedMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'purgeDeletedMarker',
      () async {
        final actor = await MapObjectActor.resolve(session);
        final existing = await MapMarker.db.findById(session, id);
        if (existing == null || existing.deletedAt == null) {
          return false;
        }
        await MapMarker.db.deleteRow(session, existing);
        await MarkerAttachmentService.deleteAllForMarker(session, id);
        await MapObjectAudit.record(
          session: session,
          entityType: MapObjectAudit.entityMarker,
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

  Stream<MapMarkerChange> markerChanges(Session session) async* {
    final changes = session.messages.createStream<MapMarkerChange>(
      MapMarkerChangeBroadcast.channel,
    );
    await for (final change in changes) {
      yield change;
    }
  }

  static Future<MapMarker> _applyTrackingChanges({
    required Session session,
    required MapMarker? before,
    required MapMarker after,
  }) async {
    var effectiveAfter = after;
    if (effectiveAfter.isTracking &&
        effectiveAfter.trackZoneId == null &&
        before?.trackZoneId != null) {
      effectiveAfter = effectiveAfter.copyWith(
        trackZoneId: before!.trackZoneId,
      );
    }

    final processed = await MarkerTrackingService.processMarkerUpdate(
      session: session,
      before: before,
      after: effectiveAfter,
    );
    if (processed.isTracking == effectiveAfter.isTracking &&
        processed.trackZoneId == effectiveAfter.trackZoneId) {
      return effectiveAfter;
    }
    return MapMarker.db.updateRow(
      session,
      processed.copyWith(updatedAt: DateTime.now().toUtc()),
    );
  }
}
