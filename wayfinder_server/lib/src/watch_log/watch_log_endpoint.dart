import 'package:serverpod/serverpod.dart';

import '../access/access_control.dart';
import '../access/wayfinder_permissions.dart';
import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'watch_log_entry_change_broadcast.dart';

class WatchLogEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'watchLog';

  Future<List<WatchLogEntry>> listEntries(Session session) {
    return loggedCall(
      session,
      _tag,
      'listEntries',
      () => WatchLogEntry.db.find(
        session,
        orderBy: (t) => t.occurredAt,
        orderDescending: true,
      ),
      onSuccess: (entries) => 'count=${entries.length}',
      requiredPermission: WayfinderPermission.viewWatchLog,
    );
  }

  Future<WatchLogEntry?> getEntry(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getEntry',
      () => WatchLogEntry.db.findById(session, id),
      onSuccess: (entry) => entry == null ? 'not found id=$id' : 'found id=$id',
      requiredPermission: WayfinderPermission.viewWatchLog,
    );
  }

  Future<WatchLogEntry> createEntry(Session session, WatchLogEntry entry) {
    return loggedCall(
      session,
      _tag,
      'createEntry',
      () async {
        final now = DateTime.now().toUtc();
        final created = await WatchLogEntry.db.insertRow(
          session,
          entry.copyWith(
            severity: _normalizeSeverity(entry.severity),
            text: entry.text.trim(),
            author: _optionalTrim(entry.author),
            createdAt: now,
            updatedAt: now,
          ),
        );
        await WatchLogEntryChangeBroadcast.created(session, created);
        return created;
      },
      onSuccess: (created) => 'id=${created.id} severity=${created.severity}',
      requiredPermission: WayfinderPermission.addWatchLog,
    );
  }

  Future<WatchLogEntry> updateEntry(Session session, WatchLogEntry entry) {
    return loggedCall(
      session,
      _tag,
      'updateEntry',
      () async {
        final updated = await WatchLogEntry.db.updateRow(
          session,
          entry.copyWith(
            severity: _normalizeSeverity(entry.severity),
            text: entry.text.trim(),
            author: _optionalTrim(entry.author),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
        await WatchLogEntryChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) => 'id=${updated.id}',
      requiredPermission: WayfinderPermission.addWatchLog,
    );
  }

  Future<bool> deleteEntry(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteEntry',
      () async {
        final deleted = await WatchLogEntry.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        if (deleted.isNotEmpty) {
          await WatchLogEntryChangeBroadcast.deleted(session, id);
        }
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
      requiredPermission: WayfinderPermission.addWatchLog,
    );
  }

  Stream<WatchLogEntryChange> entryChanges(Session session) async* {
    await AccessControl.assertAllowed(
      session,
      tag: _tag,
      operation: 'entryChanges',
      isWrite: false,
      requiredPermission: WayfinderPermission.viewWatchLog,
    );
    final changes = session.messages.createStream<WatchLogEntryChange>(
      WatchLogEntryChangeBroadcast.channel,
    );
    await for (final change in changes) {
      yield change;
    }
  }
}

String _normalizeSeverity(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'notice' => 'notice',
    'warning' => 'warning',
    'critical' => 'critical',
    _ => 'info',
  };
}

String? _optionalTrim(String? raw) {
  final text = raw?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}
