import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'marker_icon_category_key.dart';
import 'marker_icon_category_seed.dart';

/// CRUD and validation for dynamic marker icon categories.
abstract final class MarkerIconCategoryService {
  static Future<void> seedDefaultsIfEmpty(Session session) async {
    final existing = await MarkerIconCategoryDefinition.db.find(
      session,
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return;
    }

    final now = DateTime.now().toUtc();
    for (final seed in MarkerIconCategorySeed.defaults) {
      await MarkerIconCategoryDefinition.db.insertRow(
        session,
        MarkerIconCategoryDefinition(
          key: seed.key,
          label: seed.label,
          sortOrder: seed.sortOrder,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  static Future<List<MarkerIconCategoryDefinition>> listCategories(
    Session session,
  ) {
    return MarkerIconCategoryDefinition.db.find(
      session,
      orderBy: (t) => t.sortOrder,
    );
  }

  static Future<MarkerIconCategoryDefinition?> findByKey(
    Session session,
    String key,
  ) {
    return MarkerIconCategoryDefinition.db.findFirstRow(
      session,
      where: (t) => t.key.equals(key),
    );
  }

  static Future<String> resolveCategoryKey(
    Session session,
    String? raw, {
    String fallback = MarkerIconCategorySeed.defaultCategoryKey,
  }) async {
    await seedDefaultsIfEmpty(session);
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return await _defaultCategoryKey(session, fallback: fallback);
    }

    final existing = await findByKey(session, value);
    if (existing != null) {
      return existing.key;
    }

    throw FormatException('Unknown marker icon category "$raw".');
  }

  static Future<MarkerIconCategoryDefinition> createCategory(
    Session session, {
    required String key,
    required String label,
    int? sortOrder,
  }) async {
    await seedDefaultsIfEmpty(session);
    final normalizedKey = MarkerIconCategoryKey.normalize(key);
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      throw FormatException('Field "label" is required');
    }

    final existing = await findByKey(session, normalizedKey);
    if (existing != null) {
      throw MarkerIconCategoryAlreadyExistsException(normalizedKey);
    }

    final now = DateTime.now().toUtc();
    return MarkerIconCategoryDefinition.db.insertRow(
      session,
      MarkerIconCategoryDefinition(
        key: normalizedKey,
        label: trimmedLabel,
        sortOrder: sortOrder ?? await _nextSortOrder(session),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  static Future<MarkerIconCategoryDefinition> updateCategory(
    Session session, {
    required String key,
    required String label,
    int? sortOrder,
  }) async {
    final normalizedKey = MarkerIconCategoryKey.normalize(key);
    final existing = await findByKey(session, normalizedKey);
    if (existing == null) {
      throw MarkerIconCategoryNotFoundException(normalizedKey);
    }

    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      throw FormatException('Field "label" cannot be empty');
    }

    return MarkerIconCategoryDefinition.db.updateRow(
      session,
      existing.copyWith(
        label: trimmedLabel,
        sortOrder: sortOrder ?? existing.sortOrder,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<bool> deleteCategory(Session session, String key) async {
    final normalizedKey = MarkerIconCategoryKey.normalize(key);
    if (MarkerIconCategoryKey.protectedKeys.contains(normalizedKey)) {
      throw FormatException('Category "$normalizedKey" cannot be deleted.');
    }

    final existing = await findByKey(session, normalizedKey);
    if (existing == null) {
      return false;
    }

    final fallbackKey = await _defaultCategoryKey(session);
    final icons = await MarkerIconCatalogEntry.db.find(
      session,
      where: (t) => t.category.equals(normalizedKey),
    );
    final now = DateTime.now().toUtc();
    for (final icon in icons) {
      await MarkerIconCatalogEntry.db.updateRow(
        session,
        icon.copyWith(category: fallbackKey, updatedAt: now),
      );
    }

    await MarkerIconCategoryDefinition.db.deleteRow(session, existing);
    return true;
  }

  static Future<String> _defaultCategoryKey(
    Session session, {
    String fallback = MarkerIconCategorySeed.defaultCategoryKey,
  }) async {
    final custom = await findByKey(session, fallback);
    if (custom != null) {
      return custom.key;
    }

    final categories = await listCategories(session);
    if (categories.isEmpty) {
      return fallback;
    }
    return categories.first.key;
  }

  static Future<int> _nextSortOrder(Session session) async {
    final rows = await MarkerIconCategoryDefinition.db.find(
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

final class MarkerIconCategoryAlreadyExistsException implements Exception {
  MarkerIconCategoryAlreadyExistsException(this.key);

  final String key;

  @override
  String toString() => 'Marker icon category already exists: $key';
}

final class MarkerIconCategoryNotFoundException implements Exception {
  MarkerIconCategoryNotFoundException(this.key);

  final String key;

  @override
  String toString() => 'Marker icon category not found: $key';
}
