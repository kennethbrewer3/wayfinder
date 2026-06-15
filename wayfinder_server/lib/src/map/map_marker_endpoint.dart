import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';

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
        return MapMarker.db.insertRow(
          session,
          marker.copyWith(
            createdAt: now,
            updatedAt: now,
          ),
        );
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
      () => MapMarker.db.updateRow(
        session,
        marker.copyWith(updatedAt: DateTime.now().toUtc()),
      ),
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
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }
}
