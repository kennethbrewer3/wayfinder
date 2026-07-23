import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../map/map_object_actor.dart';
import '../../map/map_object_audit.dart';
import '../../map/marker_tracking_service.dart';
import '../../zones/map_zone_change_broadcast.dart';
import 'rest_api_auth.dart';
import 'rest_json.dart';

abstract final class ZonesRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final zones = await MapZone.db.find(
        session,
        where: (t) => t.deletedAt.equals(null),
        orderByList: (t) => [Order(column: t.name), Order(column: t.id)],
      );
      return RestJson.ok(RestJson.encodeModels(zones));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'zone id',
      );
      final zone = await MapZone.db.findById(session, id);
      if (zone == null || zone.deletedAt != null) {
        return RestJson.error(404, 'Zone not found');
      }
      return RestJson.ok(RestJson.encodeModel(zone));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final actor = await _actorFor(request, session);
      final body = await RestJson.readObject(request);
      final zone = _zoneFromCreateBody(body, actor);
      final created = await MapZone.db.insertRow(session, zone);
      await MapObjectAudit.record(
        session: session,
        entityType: MapObjectAudit.entityZone,
        entityId: created.id,
        entityName: created.name,
        action: MapObjectAudit.actionCreated,
        actor: actor,
        snapshot: created,
      );
      await MapZoneChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final actor = await _actorFor(request, session);
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'zone id',
      );
      final existing = await MapZone.db.findById(session, id);
      if (existing == null || existing.deletedAt != null) {
        return RestJson.error(404, 'Zone not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await MapZone.db.updateRow(
        session,
        _mergeZone(existing, body, actor),
      );
      await MarkerTrackingService.syncMarkerIconForTrackZone(
        session: session,
        zone: updated,
      );
      await MapObjectAudit.record(
        session: session,
        entityType: MapObjectAudit.entityZone,
        entityId: updated.id,
        entityName: updated.name,
        action: MapObjectAudit.actionUpdated,
        actor: actor,
        snapshot: updated,
      );
      await MapZoneChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final actor = await _actorFor(request, session);
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'zone id',
      );
      final existing = await MapZone.db.findById(session, id);
      if (existing == null || existing.deletedAt != null) {
        return RestJson.error(404, 'Zone not found');
      }
      final now = DateTime.now().toUtc();
      final softDeleted = await MapZone.db.updateRow(
        session,
        existing.copyWith(
          deletedAt: now,
          deletedByAuthUserId: actor.authUserId,
          deletedByUsername: actor.username,
          updatedAt: now,
          updatedByAuthUserId: actor.authUserId,
          updatedByUsername: actor.username,
        ),
      );
      await MapObjectAudit.record(
        session: session,
        entityType: MapObjectAudit.entityZone,
        entityId: softDeleted.id,
        entityName: softDeleted.name,
        action: MapObjectAudit.actionDeleted,
        actor: actor,
        snapshot: softDeleted,
      );
      await MapZoneChangeBroadcast.deleted(session, id);
      return RestJson.noContent();
    });
  }

  static Future<MapObjectActor> _actorFor(
    Request request,
    Session session,
  ) {
    return MapObjectActor.resolve(
      session,
      unauthenticatedLabel: RestApiAuth.usedApiKey(request)
          ? 'api-key'
          : 'anonymous',
    );
  }

  static MapZone _zoneFromCreateBody(
    Map<String, dynamic> body,
    MapObjectActor actor,
  ) {
    final name = body['name'];
    final type = body['type'];
    final color = body['color'];
    final borderColor = body['borderColor'];
    final borderPattern = body['borderPattern'];
    final fillColor = body['fillColor'];
    final geometryJson = body['geometryJson'];

    if (name is! String || name.isEmpty) {
      throw const FormatException('Field "name" is required');
    }
    if (type is! String || type.isEmpty) {
      throw const FormatException('Field "type" is required');
    }
    if (color is! String || color.isEmpty) {
      throw const FormatException('Field "color" is required');
    }
    if (borderColor is! String || borderColor.isEmpty) {
      throw const FormatException('Field "borderColor" is required');
    }
    if (borderPattern is! String || borderPattern.isEmpty) {
      throw const FormatException('Field "borderPattern" is required');
    }
    if (fillColor is! String || fillColor.isEmpty) {
      throw const FormatException('Field "fillColor" is required');
    }
    if (geometryJson is! String || geometryJson.isEmpty) {
      throw const FormatException('Field "geometryJson" is required');
    }

    final now = DateTime.now().toUtc();
    return MapZone(
      name: name,
      type: type,
      color: color,
      borderColor: borderColor,
      borderPattern: borderPattern,
      fillColor: fillColor,
      visible: body['visible'] is bool ? body['visible'] as bool : true,
      geometryJson: geometryJson,
      layerId: RestJson.parseOptionalUuid(body['layerId'], label: 'layerId'),
      createdByAuthUserId: actor.authUserId,
      createdByUsername: actor.username,
      updatedByAuthUserId: actor.authUserId,
      updatedByUsername: actor.username,
      createdAt: now,
      updatedAt: now,
    );
  }

  static MapZone _mergeZone(
    MapZone existing,
    Map<String, dynamic> body,
    MapObjectActor actor,
  ) {
    return MapZone(
      id: existing.id,
      name: body['name'] is String ? body['name'] as String : existing.name,
      type: body['type'] is String ? body['type'] as String : existing.type,
      color: body['color'] is String ? body['color'] as String : existing.color,
      borderColor: body['borderColor'] is String
          ? body['borderColor'] as String
          : existing.borderColor,
      borderPattern: body['borderPattern'] is String
          ? body['borderPattern'] as String
          : existing.borderPattern,
      fillColor: body['fillColor'] is String
          ? body['fillColor'] as String
          : existing.fillColor,
      visible: body['visible'] is bool
          ? body['visible'] as bool
          : existing.visible,
      geometryJson: body['geometryJson'] is String
          ? body['geometryJson'] as String
          : existing.geometryJson,
      layerId: body.containsKey('layerId')
          ? RestJson.parseOptionalUuid(body['layerId'], label: 'layerId')
          : existing.layerId,
      createdByAuthUserId: existing.createdByAuthUserId,
      createdByUsername: existing.createdByUsername,
      updatedByAuthUserId: actor.authUserId,
      updatedByUsername: actor.username,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
