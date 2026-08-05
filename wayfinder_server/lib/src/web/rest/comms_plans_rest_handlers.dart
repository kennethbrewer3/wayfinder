import 'package:serverpod/serverpod.dart';

import '../../comms/comms_plan_change_broadcast.dart';
import '../../generated/protocol.dart';
import 'rest_json.dart';

abstract final class CommsPlansRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final plans = await CommsPlan.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      return RestJson.ok(RestJson.encodeModels(plans));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'plan id',
      );
      final plan = await CommsPlan.db.findById(session, id);
      if (plan == null) {
        return RestJson.error(404, 'Comms plan not found');
      }
      return RestJson.ok(RestJson.encodeModel(plan));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final plan = _planFromCreateBody(body);
      final created = await CommsPlan.db.insertRow(session, plan);
      await CommsPlanChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'plan id',
      );
      final existing = await CommsPlan.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Comms plan not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await CommsPlan.db.updateRow(
        session,
        _mergePlan(existing, body),
      );
      await CommsPlanChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'plan id',
      );
      final existing = await CommsPlan.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Comms plan not found');
      }
      await CommsPlan.db.deleteRow(session, existing);
      await CommsPlanChangeBroadcast.deleted(session, id);
      return RestJson.ok({'deleted': true, 'id': id.uuid});
    });
  }

  static CommsPlan _planFromCreateBody(Map<String, dynamic> body) {
    final now = DateTime.now().toUtc();
    final name = (body['name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      throw const FormatException('Field "name" is required');
    }
    final channelsJson = (body['channelsJson'] as String?)?.trim() ?? '[]';
    final sortOrder = body['sortOrder'] is int
        ? body['sortOrder'] as int
        : (body['sortOrder'] is num ? (body['sortOrder'] as num).toInt() : 0);

    return CommsPlan(
      id: body['id'] is String
          ? UuidValue.fromString(body['id'] as String)
          : null,
      name: name,
      notes: (body['notes'] as String?)?.trim(),
      timezoneIana: (body['timezoneIana'] as String?)?.trim().isNotEmpty == true
          ? (body['timezoneIana'] as String).trim()
          : 'UTC',
      active: body['active'] is bool ? body['active'] as bool : true,
      channelsJson: channelsJson.isEmpty ? '[]' : channelsJson,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  static CommsPlan _mergePlan(CommsPlan existing, Map<String, dynamic> body) {
    return existing.copyWith(
      name: (body['name'] as String?)?.trim() ?? existing.name,
      notes: body.containsKey('notes')
          ? (body['notes'] as String?)?.trim()
          : existing.notes,
      timezoneIana: (body['timezoneIana'] as String?)?.trim().isNotEmpty == true
          ? (body['timezoneIana'] as String).trim()
          : existing.timezoneIana,
      active: body['active'] is bool ? body['active'] as bool : existing.active,
      channelsJson:
          (body['channelsJson'] as String?)?.trim() ?? existing.channelsJson,
      sortOrder: body['sortOrder'] is int
          ? body['sortOrder'] as int
          : (body['sortOrder'] is num
                ? (body['sortOrder'] as num).toInt()
                : existing.sortOrder),
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
