import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'map_marker_change_broadcast.dart';

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
      onSuccess: (marker) => marker == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<MapMarker> createMarker(Session session, MapMarker marker) {
    return loggedCall(
      session,
      _tag,
      'createMarker',
      () async {
        final now = DateTime.now().toUtc();
        final created = await MapMarker.db.insertRow(
          session,
          marker.copyWith(
            createdAt: now,
            updatedAt: now,
          ),
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
        final updated = await MapMarker.db.updateRow(
          session,
          marker.copyWith(updatedAt: DateTime.now().toUtc()),
        );
        await MapMarkerChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) => 'id=${updated.id} visible=${updated.visible}',
    );
  }

  Future<bool> deleteMarker(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteMarker',
      () async {
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
}
