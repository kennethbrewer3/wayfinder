import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'marker_icon_catalog_sanitizer.dart';
import 'marker_icon_catalog_service.dart';
import 'marker_icon_category_service.dart';
import 'marker_icon_key.dart';

class MarkerIconEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'markerIcons';

  Future<List<MarkerIconCatalogEntry>> listCatalog(Session session) {
    return loggedCall(
      session,
      _tag,
      'listCatalog',
      () async {
        final entries = await MarkerIconCatalogEntry.db.find(
          session,
          orderBy: (t) => t.sortOrder,
        );
        return MarkerIconCatalogSanitizer.effectiveEntries(entries);
      },
      onSuccess: (entries) => 'count=${entries.length}',
    );
  }

  Future<MarkerIconCatalogEntry> createIcon(
    Session session,
    String key,
    String label, {
    String? category,
    String? iconBackgroundColor,
    String? materialIcon,
    bool coloredAsset = true,
    double glyphScale = 1.0,
    int? sortOrder,
  }) {
    return loggedCall(
      session,
      _tag,
      'createIcon',
      () => MarkerIconCatalogService.createEntry(
        session,
        key: key,
        label: label,
        category: category,
        iconBackgroundColor: iconBackgroundColor,
        materialIcon: materialIcon,
        coloredAsset: coloredAsset,
        glyphScale: glyphScale,
        sortOrder: sortOrder,
      ),
      onSuccess: (entry) => 'key=${entry.key}',
    );
  }

  Future<MarkerIconCatalogEntry> updateIcon(
    Session session,
    String key,
    String label, {
    String? category,
    String? iconBackgroundColor,
    String? materialIcon,
    bool? coloredAsset,
    double? glyphScale,
    int? sortOrder,
  }) {
    return loggedCall(
      session,
      _tag,
      'updateIcon',
      () => MarkerIconCatalogService.updateEntry(
        session,
        key: key,
        label: label,
        category: category,
        iconBackgroundColor: iconBackgroundColor,
        materialIcon: materialIcon,
        coloredAsset: coloredAsset,
        glyphScale: glyphScale,
        sortOrder: sortOrder,
      ),
      onSuccess: (entry) => 'key=${entry.key}',
    );
  }

  Future<bool> deleteIcon(Session session, String key) {
    return loggedCall(
      session,
      _tag,
      'deleteIcon',
      () => MarkerIconCatalogService.deleteEntry(
        session,
        MarkerIconKey.normalize(key),
      ),
      onSuccess: (deleted) =>
          deleted ? 'deleted key=$key' : 'not found key=$key',
    );
  }

  Future<List<MarkerIconCategoryDefinition>> listCategories(Session session) {
    return loggedCall(
      session,
      _tag,
      'listCategories',
      () async {
        await MarkerIconCategoryService.seedDefaultsIfEmpty(session);
        return MarkerIconCategoryService.listCategories(session);
      },
      onSuccess: (categories) => 'count=${categories.length}',
    );
  }

  Future<MarkerIconCategoryDefinition> createCategory(
    Session session,
    String key,
    String label, {
    int? sortOrder,
  }) {
    return loggedCall(
      session,
      _tag,
      'createCategory',
      () => MarkerIconCategoryService.createCategory(
        session,
        key: key,
        label: label,
        sortOrder: sortOrder,
      ),
      onSuccess: (category) => 'key=${category.key}',
    );
  }

  Future<MarkerIconCategoryDefinition> updateCategory(
    Session session,
    String key,
    String label, {
    int? sortOrder,
  }) {
    return loggedCall(
      session,
      _tag,
      'updateCategory',
      () => MarkerIconCategoryService.updateCategory(
        session,
        key: key,
        label: label,
        sortOrder: sortOrder,
      ),
      onSuccess: (category) => 'key=${category.key}',
    );
  }

  Future<bool> deleteCategory(Session session, String key) {
    return loggedCall(
      session,
      _tag,
      'deleteCategory',
      () => MarkerIconCategoryService.deleteCategory(session, key),
      onSuccess: (deleted) =>
          deleted ? 'deleted key=$key' : 'not found key=$key',
    );
  }
}
