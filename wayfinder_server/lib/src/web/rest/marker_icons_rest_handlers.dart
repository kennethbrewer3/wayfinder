import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../markers/marker_icon_key.dart';
import '../../markers/marker_icon_storage.dart';
import '../../markers/marker_icon_upload_handler.dart';
import 'rest_json.dart';

abstract final class MarkerIconsRestHandlers {
  static final _keyParam = PathParam<String>(#key, (value) => value);

  static MarkerIconStorage get _storage => MarkerIconStorage();

  static Future<Result> list(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final entries = await MarkerIconCatalogEntry.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      );
      return RestJson.ok(
        entries.map(_encodeEntry).toList(),
      );
    });
  }

  static Future<Result> get(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final key = _readKey(request);
      final entry = await _findByKey(session, key);
      if (entry == null) {
        return RestJson.error(404, 'Marker icon not found');
      }
      return RestJson.ok(_encodeEntry(entry));
    });
  }

  static Future<Result> create(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final key = MarkerIconKey.normalize(body['key'] as String? ?? '');
      final label = (body['label'] as String?)?.trim();
      if (label == null || label.isEmpty) {
        throw const FormatException('Field "label" is required');
      }

      final existing = await _findByKey(session, key);
      if (existing != null) {
        return RestJson.error(409, 'Marker icon already exists');
      }

      final now = DateTime.now().toUtc();
      final entry = MarkerIconCatalogEntry(
        key: key,
        label: label,
        materialIcon: _optionalString(body['materialIcon']),
        coloredAsset: body['coloredAsset'] as bool? ?? false,
        glyphScale: _parseGlyphScale(body['glyphScale']),
        hasCustomSvg: false,
        sortOrder: body['sortOrder'] as int? ?? await _nextSortOrder(session),
        createdAt: now,
        updatedAt: now,
      );

      final saved = await MarkerIconCatalogEntry.db.insertRow(session, entry);
      return RestJson.created(_encodeEntry(saved));
    });
  }

  static Future<Result> update(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final key = _readKey(request);
      final existing = await _findByKey(session, key);
      if (existing == null) {
        return RestJson.error(404, 'Marker icon not found');
      }

      final body = await RestJson.readObject(request);
      final updated = existing.copyWith(
        label: body.containsKey('label')
            ? _requiredLabel(body['label'])
            : existing.label,
        materialIcon: body.containsKey('materialIcon')
            ? _optionalString(body['materialIcon'])
            : existing.materialIcon,
        coloredAsset: body.containsKey('coloredAsset')
            ? body['coloredAsset'] as bool
            : existing.coloredAsset,
        glyphScale: body.containsKey('glyphScale')
            ? _parseGlyphScale(body['glyphScale'])
            : existing.glyphScale,
        sortOrder: body.containsKey('sortOrder')
            ? body['sortOrder'] as int
            : existing.sortOrder,
        updatedAt: DateTime.now().toUtc(),
      );

      final saved = await MarkerIconCatalogEntry.db.updateRow(session, updated);
      return RestJson.ok(_encodeEntry(saved));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final key = _readKey(request);
      final existing = await _findByKey(session, key);
      if (existing == null) {
        return RestJson.error(404, 'Marker icon not found');
      }

      await _storage.delete(key);
      await MarkerIconCatalogEntry.db.deleteRow(session, existing);
      return RestJson.noContent();
    });
  }

  static Future<Result> uploadSvg(Request request) async {
    final session = await request.session;
    try {
      final key = _readKey(request);
      return handleMarkerIconSvgUpload(session, request, key);
    } on FormatException catch (error) {
      return RestJson.error(400, error.message);
    }
  }

  static String _readKey(Request request) {
    final raw = request.pathParameters.get(_keyParam);
    return MarkerIconKey.normalize(raw);
  }

  static Future<MarkerIconCatalogEntry?> _findByKey(
    Session session,
    String key,
  ) {
    return MarkerIconCatalogEntry.db.findFirstRow(
      session,
      where: (t) => t.key.equals(key),
    );
  }

  static Map<String, dynamic> _encodeEntry(MarkerIconCatalogEntry entry) {
    final json = RestJson.encodeModel(entry);
    json['svgUrl'] = entry.hasCustomSvg
        ? '/marker-icons/files/${entry.key}.svg'
        : null;
    return json;
  }

  static String? _optionalString(Object? raw) {
    if (raw == null) {
      return null;
    }
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static String _requiredLabel(Object? raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) {
      throw const FormatException('Field "label" cannot be empty');
    }
    return value;
  }

  static double _parseGlyphScale(Object? raw) {
    if (raw == null) {
      return 1.0;
    }
    if (raw is num) {
      final value = raw.toDouble();
      if (value <= 0 || value > 2) {
        throw const FormatException('Field "glyphScale" must be between 0 and 2');
      }
      return value;
    }
    throw const FormatException('Field "glyphScale" must be a number');
  }

  static Future<int> _nextSortOrder(Session session) async {
    final rows = await MarkerIconCatalogEntry.db.find(
      session,
      orderBy: (t) => t.sortOrder,
      orderDescending: true,
      limit: 1,
    );
    if (rows.isEmpty) {
      return 0;
    }
    return rows.first.sortOrder + 1;
  }
}
