import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../seasonal_overlays/seasonal_overlay_change_broadcast.dart';
import 'rest_json.dart';

abstract final class SeasonalOverlaysRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final overlays = await SeasonalOverlay.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      return RestJson.ok(RestJson.encodeModels(overlays));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'overlay id',
      );
      final overlay = await SeasonalOverlay.db.findById(session, id);
      if (overlay == null) {
        return RestJson.error(404, 'Seasonal overlay not found');
      }
      return RestJson.ok(RestJson.encodeModel(overlay));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final overlay = _overlayFromCreateBody(body);
      final created = await SeasonalOverlay.db.insertRow(session, overlay);
      await SeasonalOverlayChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'overlay id',
      );
      final existing = await SeasonalOverlay.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Seasonal overlay not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await SeasonalOverlay.db.updateRow(
        session,
        _mergeOverlay(existing, body),
      );
      await SeasonalOverlayChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'overlay id',
      );
      final existing = await SeasonalOverlay.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Seasonal overlay not found');
      }
      await SeasonalOverlay.db.deleteRow(session, existing);
      await SeasonalOverlayChangeBroadcast.deleted(session, id);
      return RestJson.ok({'deleted': true, 'id': id.uuid});
    });
  }

  static Future<Result> reorder(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final raw = body['overlays'];
      if (raw is! List) {
        return RestJson.error(400, 'Field "overlays" must be a JSON array');
      }
      for (final entry in raw) {
        if (entry is! Map<String, dynamic>) {
          return RestJson.error(400, 'Each overlay must be a JSON object');
        }
        final overlay = SeasonalOverlay.fromJson(entry);
        await SeasonalOverlay.db.updateRow(session, overlay);
      }
      final result = await SeasonalOverlay.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      await SeasonalOverlayChangeBroadcast.bulk(session);
      return RestJson.ok(RestJson.encodeModels(result));
    });
  }

  static SeasonalOverlay _overlayFromCreateBody(Map<String, dynamic> body) {
    final now = DateTime.now().toUtc();
    final name = (body['name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      throw const FormatException('Field "name" is required');
    }
    final color = (body['color'] as String?)?.trim() ?? '#2E7D32';
    final borderColor = (body['borderColor'] as String?)?.trim() ?? color;
    final fillColor =
        (body['fillColor'] as String?)?.trim() ??
        color; // Client should send alpha-aware fill.
    final dateMode = (body['dateMode'] as String?)?.trim() ?? 'absolute';
    if (dateMode != 'absolute' && dateMode != 'recurring') {
      throw const FormatException(
        'Field "dateMode" must be "absolute" or "recurring"',
      );
    }
    final dateWindowsJson =
        (body['dateWindowsJson'] as String?)?.trim() ?? '[]';
    final geometryJson = (body['geometryJson'] as String?)?.trim();
    if (geometryJson == null || geometryJson.isEmpty) {
      throw const FormatException('Field "geometryJson" is required');
    }
    final sortOrder = body['sortOrder'] is int
        ? body['sortOrder'] as int
        : (body['sortOrder'] is num ? (body['sortOrder'] as num).toInt() : 0);

    return SeasonalOverlay(
      id: body['id'] is String
          ? UuidValue.fromString(body['id'] as String)
          : null,
      name: name,
      color: color,
      borderColor: borderColor,
      fillColor: fillColor,
      visible: body['visible'] is bool ? body['visible'] as bool : true,
      notes: (body['notes'] as String?)?.trim(),
      dateMode: dateMode,
      dateWindowsJson: dateWindowsJson,
      geometryJson: geometryJson,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  static SeasonalOverlay _mergeOverlay(
    SeasonalOverlay existing,
    Map<String, dynamic> body,
  ) {
    return existing.copyWith(
      name: (body['name'] as String?)?.trim() ?? existing.name,
      color: (body['color'] as String?)?.trim() ?? existing.color,
      borderColor:
          (body['borderColor'] as String?)?.trim() ?? existing.borderColor,
      fillColor: (body['fillColor'] as String?)?.trim() ?? existing.fillColor,
      visible: body['visible'] is bool
          ? body['visible'] as bool
          : existing.visible,
      notes: body.containsKey('notes')
          ? (body['notes'] as String?)?.trim()
          : existing.notes,
      dateMode: (body['dateMode'] as String?)?.trim() ?? existing.dateMode,
      dateWindowsJson:
          (body['dateWindowsJson'] as String?)?.trim() ??
          existing.dateWindowsJson,
      geometryJson:
          (body['geometryJson'] as String?)?.trim() ?? existing.geometryJson,
      sortOrder: body['sortOrder'] is int
          ? body['sortOrder'] as int
          : (body['sortOrder'] is num
                ? (body['sortOrder'] as num).toInt()
                : existing.sortOrder),
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
