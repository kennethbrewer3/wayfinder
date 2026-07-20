import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

abstract final class SeasonalOverlayChangeBroadcast {
  static const channel = 'seasonal-overlay-changes';

  static const typeCreated = 'created';
  static const typeUpdated = 'updated';
  static const typeDeleted = 'deleted';
  static const typeBulk = 'bulk';

  static Future<void> created(Session session, SeasonalOverlay overlay) {
    return _post(
      session,
      SeasonalOverlayChange(
        type: typeCreated,
        overlay: overlay,
        overlayId: overlay.id,
      ),
    );
  }

  static Future<void> updated(Session session, SeasonalOverlay overlay) {
    return _post(
      session,
      SeasonalOverlayChange(
        type: typeUpdated,
        overlay: overlay,
        overlayId: overlay.id,
      ),
    );
  }

  static Future<void> deleted(Session session, UuidValue overlayId) {
    return _post(
      session,
      SeasonalOverlayChange(
        type: typeDeleted,
        overlayId: overlayId,
      ),
    );
  }

  static Future<void> bulk(Session session) {
    return _post(
      session,
      SeasonalOverlayChange(type: typeBulk),
    );
  }

  static Future<void> _post(Session session, SeasonalOverlayChange change) {
    return session.messages.postMessage(channel, change);
  }
}
