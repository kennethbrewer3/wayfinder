import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'map_marker_change_broadcast.dart';
import 'marker_tracking_service.dart';

class MapMarkerEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapMarker';

  Future<List<MapMarker>> listMarkers(Session session) {
    return loggedCall(
      session,
      _tag,
      'listMarkers',
      () => MapMarker.db.find(
        session,
        orderBy: (t) => t.name,
      ),
      onSuccess: (markers) => 'count=${markers.length}',
    );
  }

  Future<MapMarker?> getMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getMarker',
      () => MapMarker.db.findById(session, id),
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
        final now = DateTime.now().toUtc();
        var created = await MapMarker.db.insertRow(
          session,
          marker.copyWith(
            createdAt: now,
            updatedAt: now,
          ),
        );
        created = await _applyTrackingChanges(
          session: session,
          before: null,
          after: created,
        );
        await MapMarkerChangeBroadcast.created(session, created);
        return created;
      },
      onSuccess: (created) =>
          'id=${created.id} name="${created.name}" lat=${created.latitude} lng=${created.longitude}',
    );
  }

  Future<MapMarker> updateMarker(Session session, MapMarker marker) {
    return loggedCall(
      session,
      _tag,
      'updateMarker',
      () async {
        final before = await MapMarker.db.findById(session, marker.id);
        var incoming = marker;
        if (incoming.trackZoneId == null && before?.trackZoneId != null) {
          incoming = incoming.copyWith(trackZoneId: before!.trackZoneId);
        }
        var updated = await MapMarker.db.updateRow(
          session,
          incoming.copyWith(updatedAt: DateTime.now().toUtc()),
        );
        updated = await _applyTrackingChanges(
          session: session,
          before: before,
          after: updated,
        );
        await MapMarkerChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) =>
          'id=${updated.id} visible=${updated.visible} tracking=${updated.isTracking}',
    );
  }

  Future<bool> deleteMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteMarker',
      () async {
        final existing = await MapMarker.db.findById(session, id);
        if (existing != null) {
          await MarkerTrackingService.processMarkerDelete(
            session: session,
            marker: existing,
          );
        }
        final deleted = await MapMarker.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        if (deleted.isNotEmpty) {
          await MapMarkerChangeBroadcast.deleted(session, id);
        }
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
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
