import 'dart:convert';

import 'package:serverpod/serverpod.dart';

/// JSON helpers for the public REST API (plain JSON, no Serverpod class names).
abstract final class RestJson {
  static Map<String, dynamic> encodeModel(SerializableModel model) {
    final json = Map<String, dynamic>.from(model.toJson());
    json.remove('__className__');
    return json;
  }

  static List<Map<String, dynamic>> encodeModels(
    Iterable<SerializableModel> models,
  ) {
    return models.map(encodeModel).toList();
  }

  static Response ok(Object? body) {
    return Response.ok(
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
    );
  }

  static Response created(Object? body) {
    return Response(
      201,
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
    );
  }

  static Response noContent() => Response.noContent();

  static Response error(int statusCode, String message) {
    final body = Body.fromString(
      jsonEncode({'error': message}),
      mimeType: MimeType.json,
    );

    return switch (statusCode) {
      400 => Response.badRequest(body: body),
      401 => Response.unauthorized(body: body),
      403 => Response.forbidden(body: body),
      404 => Response.notFound(body: body),
      _ => Response.internalServerError(body: body),
    };
  }

  static Future<Map<String, dynamic>> readObject(Request request) async {
    final raw = await request.readAsString();
    if (raw.trim().isEmpty) {
      throw const FormatException('Request body must be a JSON object');
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Request body must be a JSON object');
    }

    return decoded;
  }

  static UuidValue parseUuid(String raw, {String label = 'id'}) {
    try {
      return UuidValue.fromString(raw);
    } on FormatException {
      throw FormatException('Invalid UUID for $label: $raw');
    }
  }

  static UuidValue? parseOptionalUuid(
    Object? raw, {
    String label = 'id',
  }) {
    if (raw == null) {
      return null;
    }
    if (raw is! String || raw.isEmpty) {
      throw FormatException('$label must be a UUID string');
    }
    return parseUuid(raw, label: label);
  }

  static Future<Result> handleErrors(Future<Result> Function() action) async {
    try {
      return await action();
    } on FormatException catch (error) {
      return RestJson.error(400, error.message);
    } on StateError catch (error) {
      return RestJson.error(400, error.message);
    }
  }
}
