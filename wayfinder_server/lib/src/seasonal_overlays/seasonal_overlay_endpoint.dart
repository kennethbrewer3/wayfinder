import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'seasonal_overlay_change_broadcast.dart';

class SeasonalOverlayEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'seasonalOverlay';

  Future<List<SeasonalOverlay>> listOverlays(Session session) {
    return loggedCall(
      session,
      _tag,
      'listOverlays',
      () => SeasonalOverlay.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      ),
      onSuccess: (overlays) => 'count=${overlays.length}',
    );
  }

  Future<SeasonalOverlay?> getOverlay(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getOverlay',
      () => SeasonalOverlay.db.findById(session, id),
      onSuccess: (overlay) =>
          overlay == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<SeasonalOverlay> createOverlay(
    Session session,
    SeasonalOverlay overlay,
  ) {
    return loggedCall(
      session,
      _tag,
      'createOverlay',
      () async {
        final now = DateTime.now().toUtc();
        final created = await SeasonalOverlay.db.insertRow(
          session,
          overlay.copyWith(
            createdAt: now,
            updatedAt: now,
          ),
        );
        await SeasonalOverlayChangeBroadcast.created(session, created);
        return created;
      },
      onSuccess: (created) => 'id=${created.id} name="${created.name}"',
    );
  }

  Future<SeasonalOverlay> updateOverlay(
    Session session,
    SeasonalOverlay overlay,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateOverlay',
      () async {
        final updated = await SeasonalOverlay.db.updateRow(
          session,
          overlay.copyWith(updatedAt: DateTime.now().toUtc()),
        );
        await SeasonalOverlayChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) =>
          'id=${updated.id} sortOrder=${updated.sortOrder} visible=${updated.visible}',
    );
  }

  Future<bool> deleteOverlay(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteOverlay',
      () async {
        final deleted = await SeasonalOverlay.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        if (deleted.isNotEmpty) {
          await SeasonalOverlayChangeBroadcast.deleted(session, id);
        }
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
    );
  }

  Future<List<SeasonalOverlay>> reorderOverlays(
    Session session,
    List<SeasonalOverlay> overlays,
  ) {
    return loggedCall(
      session,
      _tag,
      'reorderOverlays',
      () async {
        for (final overlay in overlays) {
          await SeasonalOverlay.db.updateRow(session, overlay);
        }
        final result = await SeasonalOverlay.db.find(
          session,
          orderBy: (t) => t.sortOrder,
        );
        await SeasonalOverlayChangeBroadcast.bulk(session);
        return result;
      },
      onSuccess: (result) => 'count=${result.length}',
    );
  }

  Stream<SeasonalOverlayChange> overlayChanges(Session session) async* {
    final changes = session.messages.createStream<SeasonalOverlayChange>(
      SeasonalOverlayChangeBroadcast.channel,
    );
    await for (final change in changes) {
      yield change;
    }
  }
}
