import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'rest_json.dart';

abstract final class ZonesRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final zones = await MapZone.db.find(
        session,
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
      if (zone == null) {
        return RestJson.error(404, 'Zone not found');
      }
      return RestJson.ok(RestJson.encodeModel(zone));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final zone = _zoneFromCreateBody(body);
      final created = await MapZone.db.insertRow(session, zone);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'zone id',
      );
      final existing = await MapZone.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Zone not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await MapZone.db.updateRow(
        session,
        _mergeZone(existing, body),
      );
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'zone id',
      );
      final deleted = await MapZone.db.deleteWhere(
        session,
        where: (t) => t.id.equals(id),
      );
      if (deleted.isEmpty) {
        return RestJson.error(404, 'Zone not found');
      }
      return RestJson.noContent();
    });
  }

  static MapZone _zoneFromCreateBody(Map<String, dynamic> body) {
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
      createdAt: now,
      updatedAt: now,
    );
  }

  static MapZone _mergeZone(MapZone existing, Map<String, dynamic> body) {
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
      visible: body['visible'] is bool ? body['visible'] as bool : existing.visible,
      geometryJson: body['geometryJson'] is String
          ? body['geometryJson'] as String
          : existing.geometryJson,
      layerId: body.containsKey('layerId')
          ? RestJson.parseOptionalUuid(body['layerId'], label: 'layerId')
          : existing.layerId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
