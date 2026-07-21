import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../watch_log/watch_log_entry_change_broadcast.dart';
import 'rest_json.dart';

abstract final class WatchLogRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final entries = await WatchLogEntry.db.find(
        session,
        orderBy: (t) => t.occurredAt,
        orderDescending: true,
      );
      return RestJson.ok(RestJson.encodeModels(entries));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'entry id',
      );
      final entry = await WatchLogEntry.db.findById(session, id);
      if (entry == null) {
        return RestJson.error(404, 'Watch log entry not found');
      }
      return RestJson.ok(RestJson.encodeModel(entry));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final entry = _entryFromCreateBody(body);
      final created = await WatchLogEntry.db.insertRow(session, entry);
      await WatchLogEntryChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'entry id',
      );
      final existing = await WatchLogEntry.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Watch log entry not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await WatchLogEntry.db.updateRow(
        session,
        _mergeEntry(existing, body),
      );
      await WatchLogEntryChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'entry id',
      );
      final existing = await WatchLogEntry.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Watch log entry not found');
      }
      await WatchLogEntry.db.deleteRow(session, existing);
      await WatchLogEntryChangeBroadcast.deleted(session, id);
      return RestJson.ok({'deleted': true, 'id': id.uuid});
    });
  }

  static WatchLogEntry _entryFromCreateBody(Map<String, dynamic> body) {
    final now = DateTime.now().toUtc();
    final text = (body['text'] as String?)?.trim();
    if (text == null || text.isEmpty) {
      throw const FormatException('Field "text" is required');
    }
    final occurredAt = body['occurredAt'] is String
        ? DateTime.tryParse(body['occurredAt'] as String)?.toUtc()
        : null;
    return WatchLogEntry(
      occurredAt: occurredAt ?? now,
      author: _optionalString(body['author']),
      severity: _normalizeSeverity(body['severity'] as String?),
      text: text,
      markerId: RestJson.parseOptionalUuid(
        body['markerId'],
        label: 'markerId',
      ),
      zoneId: RestJson.parseOptionalUuid(body['zoneId'], label: 'zoneId'),
      createdAt: now,
      updatedAt: now,
    );
  }

  static WatchLogEntry _mergeEntry(
    WatchLogEntry existing,
    Map<String, dynamic> body,
  ) {
    final text = body.containsKey('text')
        ? (body['text'] as String?)?.trim()
        : existing.text;
    if (text == null || text.isEmpty) {
      throw const FormatException('Field "text" cannot be empty');
    }
    final occurredAt = body.containsKey('occurredAt')
        ? (body['occurredAt'] is String
              ? DateTime.tryParse(body['occurredAt'] as String)?.toUtc()
              : null)
        : existing.occurredAt;
    return WatchLogEntry(
      id: existing.id,
      occurredAt: occurredAt ?? existing.occurredAt,
      author: body.containsKey('author')
          ? _optionalString(body['author'])
          : existing.author,
      severity: body.containsKey('severity')
          ? _normalizeSeverity(body['severity'] as String?)
          : existing.severity,
      text: text,
      markerId: body.containsKey('markerId')
          ? RestJson.parseOptionalUuid(body['markerId'], label: 'markerId')
          : existing.markerId,
      zoneId: body.containsKey('zoneId')
          ? RestJson.parseOptionalUuid(body['zoneId'], label: 'zoneId')
          : existing.zoneId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  static String _normalizeSeverity(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'notice' => 'notice',
      'warning' => 'warning',
      'critical' => 'critical',
      _ => 'info',
    };
  }

  static String? _optionalString(Object? raw) {
    final text = raw?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }
}
