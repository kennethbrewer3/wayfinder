import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../map/map_marker_change_broadcast.dart';
import '../../map/marker_tracking_service.dart';
import 'rest_json.dart';

abstract final class MarkersRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final markers = await MapMarker.db.find(
        session,
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
      if (marker == null) {
        return RestJson.error(404, 'Marker not found');
      }
      return RestJson.ok(RestJson.encodeModel(marker));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      var created = await MapMarker.db.insertRow(
        session,
        _markerFromCreateBody(body),
      );
      created = await _applyTrackingChanges(
        session: session,
        before: null,
        after: created,
      );
      await MapMarkerChangeBroadcast.created(session, created);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'marker id',
      );
      final existing = await MapMarker.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Marker not found');
      }

      final body = await RestJson.readObject(request);
      var updated = await MapMarker.db.updateRow(
        session,
        _mergeMarker(existing, body),
      );
      updated = await _applyTrackingChanges(
        session: session,
        before: existing,
        after: updated,
      );
      await MapMarkerChangeBroadcast.updated(session, updated);
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'marker id',
      );
      final existing = await MapMarker.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Marker not found');
      }
      await MarkerTrackingService.processMarkerDelete(
        session: session,
        marker: existing,
      );
      await MapMarker.db.deleteWhere(
        session,
        where: (t) => t.id.equals(id),
      );
      await MapMarkerChangeBroadcast.deleted(session, id);
      return RestJson.noContent();
    });
  }

  static MapMarker _markerFromCreateBody(Map<String, dynamic> body) {
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
      layerId: RestJson.parseOptionalUuid(body['layerId'], label: 'layerId'),
      createdAt: now,
      updatedAt: now,
    );
  }

  static MapMarker _mergeMarker(
    MapMarker existing,
    Map<String, dynamic> body,
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
      layerId: body.containsKey('layerId')
          ? RestJson.parseOptionalUuid(body['layerId'], label: 'layerId')
          : existing.layerId,
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
