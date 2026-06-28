import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../map/map_marker_change_broadcast.dart';
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
      final marker = _markerFromCreateBody(body);
      final created = await MapMarker.db.insertRow(session, marker);
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
      final updated = await MapMarker.db.updateRow(
        session,
        _mergeMarker(existing, body),
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
      final deleted = await MapMarker.db.deleteWhere(
        session,
        where: (t) => t.id.equals(id),
      );
      if (deleted.isEmpty) {
        return RestJson.error(404, 'Marker not found');
      }
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
      visible: body['visible'] is bool ? body['visible'] as bool : existing.visible,
      layerId: body.containsKey('layerId')
          ? RestJson.parseOptionalUuid(body['layerId'], label: 'layerId')
          : existing.layerId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
