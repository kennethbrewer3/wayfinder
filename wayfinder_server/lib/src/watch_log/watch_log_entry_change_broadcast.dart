import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

abstract final class WatchLogEntryChangeBroadcast {
  static const channel = 'watch-log-entry-changes';

  static const typeCreated = 'created';
  static const typeUpdated = 'updated';
  static const typeDeleted = 'deleted';
  static const typeBulk = 'bulk';

  static Future<void> created(Session session, WatchLogEntry entry) {
    return _post(
      session,
      WatchLogEntryChange(
        type: typeCreated,
        entry: entry,
        entryId: entry.id,
      ),
    );
  }

  static Future<void> updated(Session session, WatchLogEntry entry) {
    return _post(
      session,
      WatchLogEntryChange(
        type: typeUpdated,
        entry: entry,
        entryId: entry.id,
      ),
    );
  }

  static Future<void> deleted(Session session, UuidValue entryId) {
    return _post(
      session,
      WatchLogEntryChange(
        type: typeDeleted,
        entryId: entryId,
      ),
    );
  }

  static Future<void> bulk(Session session) {
    return _post(
      session,
      WatchLogEntryChange(type: typeBulk),
    );
  }

  static Future<void> _post(Session session, WatchLogEntryChange change) {
    return session.messages.postMessage(channel, change);
  }
}
