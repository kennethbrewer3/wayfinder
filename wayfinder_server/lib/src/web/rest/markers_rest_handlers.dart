import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../map/map_marker_change_broadcast.dart';
import '../../map/map_object_actor.dart';
import '../../map/map_object_audit.dart';
import '../../map/marker_tracking_service.dart';
import '../../map/marker_weather_json.dart';
import '../../map/marker_weather_watch_log_service.dart';
import 'rest_api_auth.dart';
import 'rest_json.dart';

abstract final class MarkersRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final markers = await MapMarker.db.find(
        session,
        where: (t) => t.deletedAt.equals(null),
        orderBy: (t) => t.name,
      );
      return RestJson.ok(RestJson.encodeModels(markers));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'marker id',
      );
      final marker = await MapMarker.db.findById(session, id);
      if (marker == null || marker.deletedAt != null) {
        return RestJson.error(404, 'Marker not found');
      }
      return RestJson.ok(RestJson.encodeModel(marker));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final actor = await _actorFor(request, session);
      final body = await RestJson.readObject(request);
      var created = await MapMarker.db.insertRow(
        session,
        _markerFromCreateBody(body, actor),
      );
      created = await _applyTrackingChanges(
        session: session,
        before: null,
        after: created,
      );
      await MarkerWeatherWatchLogService.maybeAppend(
        session: session,
        before: null,
        after: created,
      );
      await MapObjectAudit.record(
        session: session,
        entityType: MapObjectAudit.entityMarker,
        entityId: created.id,
        entityName: created.name,
        action: MapObjectAudit.actionCreated,
        actor: actor,
        snapshot: created,
      );
      await MapMarkerChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final actor = await _actorFor(request, session);
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'marker id',
      );
      final existing = await MapMarker.db.findById(session, id);
      if (existing == null || existing.deletedAt != null) {
        return RestJson.error(404, 'Marker not found');
      }

      final body = await RestJson.readObject(request);
      var updated = await MapMarker.db.updateRow(
        session,
        _mergeMarker(existing, body, actor),
      );
      updated = await _applyTrackingChanges(
        session: session,
        before: existing,
        after: updated,
      );
      await MarkerWeatherWatchLogService.maybeAppend(
        session: session,
        before: existing,
        after: updated,
      );
      await MapObjectAudit.record(
        session: session,
        entityType: MapObjectAudit.entityMarker,
        entityId: updated.id,
        entityName: updated.name,
        action: MapObjectAudit.actionUpdated,
        actor: actor,
        snapshot: updated,
      );
      await MapMarkerChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final actor = await _actorFor(request, session);
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'marker id',
      );
      final existing = await MapMarker.db.findById(session, id);
      if (existing == null || existing.deletedAt != null) {
        return RestJson.error(404, 'Marker not found');
      }
      await MarkerTrackingService.processMarkerDelete(
        session: session,
        marker: existing,
      );
      final now = DateTime.now().toUtc();
      final softDeleted = await MapMarker.db.updateRow(
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
        entityType: MapObjectAudit.entityMarker,
        entityId: softDeleted.id,
        entityName: softDeleted.name,
        action: MapObjectAudit.actionDeleted,
        actor: actor,
        snapshot: softDeleted,
      );
      await MapMarkerChangeBroadcast.deleted(session, id);
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

  static MapMarker _markerFromCreateBody(
    Map<String, dynamic> body,
    MapObjectActor actor,
  ) {
    final name = body['name'];
    final latitude = body['latitude'];
    final longitude = body['longitude'];
    final color = body['color'];
    final icon = body['icon'];

    if (name is! String || name.isEmpty) {
      throw const FormatException('Field "name" is required');
    }
    if (latitude is! num) {
      throw const FormatException('Field "latitude" is required');
    }
    if (longitude is! num) {
      throw const FormatException('Field "longitude" is required');
    }
    if (color is! String || color.isEmpty) {
      throw const FormatException('Field "color" is required');
    }
    if (icon is! String || icon.isEmpty) {
      throw const FormatException('Field "icon" is required');
    }

    final now = DateTime.now().toUtc();
    return MapMarker(
      name: name,
      notes: body['notes'] as String?,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      elevation: body['elevation'] is num
          ? (body['elevation'] as num).toDouble()
          : 0,
      color: color,
      icon: icon,
      visible: body['visible'] is bool ? body['visible'] as bool : true,
      isTracking: body['isTracking'] is bool
          ? body['isTracking'] as bool
          : false,
      trackZoneId: RestJson.parseOptionalUuid(
        body['trackZoneId'],
        label: 'trackZoneId',
      ),
      weatherJson: body['weatherJson'] as String?,
      inventoryJson: body['inventoryJson'] as String?,
      radioJson: body['radioJson'] as String?,
      checklistsJson: body['checklistsJson'] as String?,
      resourceType: body['resourceType'] as String?,
      layerId: RestJson.parseOptionalUuid(body['layerId'], label: 'layerId'),
      createdByAuthUserId: actor.authUserId,
      createdByUsername: actor.username,
      updatedByAuthUserId: actor.authUserId,
      updatedByUsername: actor.username,
      createdAt: now,
      updatedAt: now,
    );
  }

  static MapMarker _mergeMarker(
    MapMarker existing,
    Map<String, dynamic> body,
    MapObjectActor actor,
  ) {
    return MapMarker(
      id: existing.id,
      name: body['name'] is String ? body['name'] as String : existing.name,
      notes: body.containsKey('notes')
          ? body['notes'] as String?
          : existing.notes,
      latitude: body['latitude'] is num
          ? (body['latitude'] as num).toDouble()
          : existing.latitude,
      longitude: body['longitude'] is num
          ? (body['longitude'] as num).toDouble()
          : existing.longitude,
      elevation: body['elevation'] is num
          ? (body['elevation'] as num).toDouble()
          : existing.elevation,
      color: body['color'] is String ? body['color'] as String : existing.color,
      icon: body['icon'] is String ? body['icon'] as String : existing.icon,
      visible: body['visible'] is bool
          ? body['visible'] as bool
          : existing.visible,
      isTracking: body['isTracking'] is bool
          ? body['isTracking'] as bool
          : existing.isTracking,
      trackZoneId: body.containsKey('trackZoneId')
          ? RestJson.parseOptionalUuid(
              body['trackZoneId'],
              label: 'trackZoneId',
            )
          : existing.trackZoneId,
      weatherJson: body.containsKey('weatherJson')
          ? preserveWeatherJsonDisplayUnits(
              existing.weatherJson,
              body['weatherJson'] as String?,
            )
          : existing.weatherJson,
      inventoryJson: body.containsKey('inventoryJson')
          ? body['inventoryJson'] as String?
          : existing.inventoryJson,
      radioJson: body.containsKey('radioJson')
          ? body['radioJson'] as String?
          : existing.radioJson,
      checklistsJson: body.containsKey('checklistsJson')
          ? body['checklistsJson'] as String?
          : existing.checklistsJson,
      resourceType: body.containsKey('resourceType')
          ? body['resourceType'] as String?
          : existing.resourceType,
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

  static Future<MapMarker> _applyTrackingChanges({
    required Session session,
    required MapMarker? before,
    required MapMarker after,
  }) async {
    var effectiveAfter = after;
    if (effectiveAfter.isTracking &&
        effectiveAfter.trackZoneId == null &&
        before?.trackZoneId != null) {
      effectiveAfter = effectiveAfter.copyWith(
        trackZoneId: before!.trackZoneId,
      );
    }

    final processed = await MarkerTrackingService.processMarkerUpdate(
      session: session,
      before: before,
      after: effectiveAfter,
    );
    if (processed.isTracking == effectiveAfter.isTracking &&
        processed.trackZoneId == effectiveAfter.trackZoneId) {
      return effectiveAfter;
    }
    return MapMarker.db.updateRow(
      session,
      processed.copyWith(updatedAt: DateTime.now().toUtc()),
    );
  }
}
