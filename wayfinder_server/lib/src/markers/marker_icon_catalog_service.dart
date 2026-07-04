import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'marker_icon_background_color.dart';
import 'marker_icon_category_service.dart';
import 'marker_icon_key.dart';
import 'marker_icon_storage.dart';

/// Shared marker icon catalog mutations for REST and Serverpod endpoints.
abstract final class MarkerIconCatalogService {
  static Future<MarkerIconCatalogEntry?> findByKey(
    Session session,
    String key,
  ) {
    return MarkerIconCatalogEntry.db.findFirstRow(
      session,
      where: (t) => t.key.equals(key),
    );
  }

  static Future<MarkerIconCatalogEntry> createEntry(
    Session session, {
    required String key,
    required String label,
    String? category,
    String? iconBackgroundColor,
    String? materialIcon,
    bool coloredAsset = false,
    double glyphScale = 1.0,
    int? sortOrder,
  }) async {
    final normalizedKey = MarkerIconKey.normalize(key);
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      throw FormatException('Field "label" is required');
    }

    final existing = await findByKey(session, normalizedKey);
    if (existing != null) {
      throw MarkerIconAlreadyExistsException(normalizedKey);
    }

    final now = DateTime.now().toUtc();
    final resolvedCategory = await MarkerIconCategoryService.resolveCategoryKey(
      session,
      category,
    );
    final entry = MarkerIconCatalogEntry(
      key: normalizedKey,
      label: trimmedLabel,
      category: resolvedCategory,
      iconBackgroundColor: MarkerIconBackgroundColor.normalize(
        iconBackgroundColor,
      ),
      materialIcon: _optionalString(materialIcon),
      coloredAsset: coloredAsset,
      glyphScale: _parseGlyphScale(glyphScale),
      hasCustomSvg: false,
      sortOrder: sortOrder ?? await nextSortOrder(session),
      createdAt: now,
      updatedAt: now,
    );

    return MarkerIconCatalogEntry.db.insertRow(session, entry);
  }

  static Future<MarkerIconCatalogEntry> updateEntry(
    Session session, {
    required String key,
    required String label,
    String? category,
    String? iconBackgroundColor,
    String? materialIcon,
    bool? coloredAsset,
    double? glyphScale,
    int? sortOrder,
  }) async {
    final normalizedKey = MarkerIconKey.normalize(key);
    final existing = await findByKey(session, normalizedKey);
    if (existing == null) {
      throw MarkerIconNotFoundException(normalizedKey);
    }

    final resolvedCategory = category != null
        ? await MarkerIconCategoryService.resolveCategoryKey(session, category)
        : existing.category;
    final updated = existing.copyWith(
      label: label.trim().isEmpty ? existing.label : label.trim(),
      category: resolvedCategory,
      iconBackgroundColor: iconBackgroundColor != null
          ? MarkerIconBackgroundColor.normalize(iconBackgroundColor)
          : existing.iconBackgroundColor,
      materialIcon: materialIcon != null
          ? _optionalString(materialIcon)
          : existing.materialIcon,
      coloredAsset: coloredAsset ?? existing.coloredAsset,
      glyphScale: glyphScale != null
          ? _parseGlyphScale(glyphScale)
          : existing.glyphScale,
      sortOrder: sortOrder ?? existing.sortOrder,
      updatedAt: DateTime.now().toUtc(),
    );

    return MarkerIconCatalogEntry.db.updateRow(session, updated);
  }

  static Future<bool> deleteEntry(Session session, String key) async {
    final normalizedKey = MarkerIconKey.normalize(key);
    final existing = await findByKey(session, normalizedKey);
    if (existing == null) {
      return false;
    }

    await MarkerIconCatalogEntry.db.deleteRow(session, existing);
    await MarkerIconStorage().delete(normalizedKey);
    return true;
  }

  static Future<int> nextSortOrder(Session session) async {
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

  static String? _optionalString(String? raw) {
    if (raw == null) {
      return null;
    }
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static double _parseGlyphScale(double raw) {
    if (raw <= 0 || raw > 2) {
      throw FormatException('Field "glyphScale" must be between 0 and 2');
    }
    return raw;
  }
}

final class MarkerIconAlreadyExistsException implements Exception {
  MarkerIconAlreadyExistsException(this.key);

  final String key;

  @override
  String toString() => 'Marker icon already exists: $key';
}

final class MarkerIconNotFoundException implements Exception {
  MarkerIconNotFoundException(this.key);

  final String key;

  @override
  String toString() => 'Marker icon not found: $key';
}
