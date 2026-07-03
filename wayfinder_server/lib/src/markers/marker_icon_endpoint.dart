import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'marker_icon_catalog_service.dart';
import 'marker_icon_key.dart';

class MarkerIconEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'markerIcons';

  Future<List<MarkerIconCatalogEntry>> listCatalog(Session session) {
    return loggedCall(
      session,
      _tag,
      'listCatalog',
      () => MarkerIconCatalogEntry.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      ),
      onSuccess: (entries) => 'count=${entries.length}',
    );
  }

  Future<MarkerIconCatalogEntry> createIcon(
    Session session,
    String key,
    String label, {
    String? materialIcon,
    bool coloredAsset = false,
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
}
