import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'map_object_actor.dart';

/// Persists and logs map-object mutation audit events.
abstract final class MapObjectAudit {
  static const entityMarker = 'marker';
  static const entityZone = 'zone';

  static const actionCreated = 'created';
  static const actionUpdated = 'updated';
  static const actionDeleted = 'deleted';
  static const actionRestored = 'restored';
  static const actionPurged = 'purged';

  static Future<void> record({
    required Session session,
    required String entityType,
    required UuidValue entityId,
    required String action,
    required MapObjectActor actor,
    String? entityName,
    Object? snapshot,
    String logTag = 'mapAudit',
  }) async {
    final now = DateTime.now().toUtc();
    String? snapshotJson;
    if (snapshot != null) {
      try {
        if (snapshot is String) {
          snapshotJson = snapshot;
        } else if (snapshot is Map<String, dynamic>) {
          snapshotJson = jsonEncode(snapshot);
        } else if (snapshot is SerializableModel) {
          snapshotJson = jsonEncode(snapshot.toJson());
        }
      } catch (_) {
        snapshotJson = null;
      }
    }

    await MapObjectAuditEvent.db.insertRow(
      session,
      MapObjectAuditEvent(
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
        action: action,
        actorAuthUserId: actor.authUserId,
        actorUsername: actor.username,
        snapshotJson: snapshotJson,
        createdAt: now,
      ),
    );

    final namePart = entityName == null || entityName.isEmpty
        ? ''
        : ' name="$entityName"';
    WfLog.info(
      session,
      logTag,
      '📋 $action $entityType id=$entityId$namePart actor=${actor.logLabel}',
    );
  }
}
