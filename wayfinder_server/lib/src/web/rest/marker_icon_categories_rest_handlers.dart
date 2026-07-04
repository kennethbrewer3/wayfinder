import 'package:serverpod/serverpod.dart';

import '../../markers/marker_icon_category_key.dart';
import '../../markers/marker_icon_category_service.dart';
import 'rest_json.dart';

abstract final class MarkerIconCategoriesRestHandlers {
  static final _keyParam = PathParam<String>(#key, (value) => value);

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      await MarkerIconCategoryService.seedDefaultsIfEmpty(session);
      final categories = await MarkerIconCategoryService.listCategories(
        session,
      );
      return RestJson.ok(RestJson.encodeModels(categories));
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final key = _readKey(request);
      final category = await MarkerIconCategoryService.findByKey(session, key);
      if (category == null) {
        return RestJson.error(404, 'Marker icon category not found');
      }
      return RestJson.ok(RestJson.encodeModel(category));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      try {
        final saved = await MarkerIconCategoryService.createCategory(
          session,
          key: body['key'] as String? ?? '',
          label: body['label'] as String? ?? '',
          sortOrder: body['sortOrder'] as int?,
        );
        return RestJson.created(RestJson.encodeModel(saved));
      } on MarkerIconCategoryAlreadyExistsException {
        return RestJson.error(409, 'Marker icon category already exists');
      }
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final key = _readKey(request);
      final body = await RestJson.readObject(request);
      final existing = await MarkerIconCategoryService.findByKey(session, key);
      if (existing == null) {
        return RestJson.error(404, 'Marker icon category not found');
      }
      try {
        final saved = await MarkerIconCategoryService.updateCategory(
          session,
          key: key,
          label: body.containsKey('label')
              ? _requiredLabel(body['label'])
              : existing.label,
          sortOrder: body.containsKey('sortOrder')
              ? body['sortOrder'] as int
              : null,
        );
        return RestJson.ok(RestJson.encodeModel(saved));
      } on MarkerIconCategoryNotFoundException {
        return RestJson.error(404, 'Marker icon category not found');
      }
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final key = _readKey(request);
      try {
        final deleted = await MarkerIconCategoryService.deleteCategory(
          session,
          key,
        );
        if (!deleted) {
          return RestJson.error(404, 'Marker icon category not found');
        }
        return RestJson.noContent();
      } on FormatException catch (error) {
        return RestJson.error(400, error.message);
      }
    });
  }

  static String _readKey(Request request) {
    final raw = request.pathParameters.get(_keyParam);
    return MarkerIconCategoryKey.normalize(raw);
  }

  static String _requiredLabel(Object? raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) {
      throw const FormatException('Field "label" cannot be empty');
    }
    return value;
  }
}
