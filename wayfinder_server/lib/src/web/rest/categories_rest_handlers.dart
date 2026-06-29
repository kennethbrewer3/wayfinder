import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'rest_json.dart';

abstract final class CategoriesRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final categories = await Category.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      return RestJson.ok(RestJson.encodeModels(categories));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'category id',
      );
      final category = await Category.db.findById(session, id);
      if (category == null) {
        return RestJson.error(404, 'Category not found');
      }
      return RestJson.ok(RestJson.encodeModel(category));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final category = _categoryFromCreateBody(body);
      final created = await Category.db.insertRow(session, category);
      return RestJson.created(RestJson.encodeModel(created));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'category id',
      );
      final existing = await Category.db.findById(session, id);
      if (existing == null) {
        return RestJson.error(404, 'Category not found');
      }

      final body = await RestJson.readObject(request);
      final updated = await Category.db.updateRow(
        session,
        _mergeCategory(existing, body),
      );
      return RestJson.ok(RestJson.encodeModel(updated));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'category id',
      );
      final deleted = await Category.db.deleteWhere(
        session,
        where: (t) => t.id.equals(id),
      );
      if (deleted.isEmpty) {
        return RestJson.error(404, 'Category not found');
      }
      return RestJson.noContent();
    });
  }

  static Category _categoryFromCreateBody(Map<String, dynamic> body) {
    final name = body['name'];
    final sortOrder = body['sortOrder'];

    if (name is! String || name.isEmpty) {
      throw const FormatException('Field "name" is required');
    }
    if (sortOrder is! int) {
      throw const FormatException('Field "sortOrder" is required');
    }

    return Category(
      parentId: RestJson.parseOptionalUuid(body['parentId'], label: 'parentId'),
      name: name,
      sortOrder: sortOrder,
    );
  }

  static Category _mergeCategory(
    Category existing,
    Map<String, dynamic> body,
  ) {
    return Category(
      id: existing.id,
      parentId: body.containsKey('parentId')
          ? RestJson.parseOptionalUuid(body['parentId'], label: 'parentId')
          : existing.parentId,
      name: body['name'] is String ? body['name'] as String : existing.name,
      sortOrder: body['sortOrder'] is int
          ? body['sortOrder'] as int
          : existing.sortOrder,
    );
  }
}
