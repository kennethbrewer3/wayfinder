import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'pmtiles_header_bounds.dart';
import 'pmtiles_storage.dart';

/// Registers pre-existing `.pmtiles` files found under [PmtilesStorage.root].
abstract final class PmtilesCatalogSync {
  static Future<void> sync(Session session) async {
    final storage = PmtilesStorage();
    final discovered = storage.discoverNamedArchives();
    final existing = await PmtilesFile.db.find(session);
    final byName = {for (final entry in existing) entry.name: entry};
    var imported = 0;
    var removed = 0;
    var boundsUpdated = 0;

    for (final file in discovered) {
      final name = storage.relativeCatalogName(file);
      if (byName.containsKey(name)) {
        continue;
      }

      final stat = await file.stat();
      final bounds = await _readBounds(file);
      await PmtilesFile.db.insertRow(
        session,
        PmtilesFile(
          name: name,
          sizeBytes: stat.size,
          isActive: false,
          addedAt: stat.modified.toUtc(),
          minZoom: bounds?.minZoom,
          maxZoom: bounds?.maxZoom,
          minLatitude: bounds?.minLatitude,
          minLongitude: bounds?.minLongitude,
          maxLatitude: bounds?.maxLatitude,
          maxLongitude: bounds?.maxLongitude,
        ),
      );
      imported++;
    }

    for (final entry in existing) {
      if (!storage.existsForEntry(id: entry.id.uuid, name: entry.name)) {
        await PmtilesFile.db.deleteRow(session, entry);
        removed++;
        continue;
      }

      if (_hasBounds(entry)) {
        continue;
      }

      final file = storage.resolveFileForEntry(
        id: entry.id.uuid,
        name: entry.name,
      );
      final bounds = await _readBounds(file);
      if (bounds == null) {
        continue;
      }

      await PmtilesFile.db.updateRow(
        session,
        entry.copyWith(
          minZoom: bounds.minZoom,
          maxZoom: bounds.maxZoom,
          minLatitude: bounds.minLatitude,
          minLongitude: bounds.minLongitude,
          maxLatitude: bounds.maxLatitude,
          maxLongitude: bounds.maxLongitude,
        ),
      );
      boundsUpdated++;
    }

    if (imported > 0 || removed > 0 || boundsUpdated > 0) {
      WfLog.info(
        session,
        'pmtiles',
        '📂 PMTiles catalog sync from ${storage.root.path}: '
        'imported=$imported removed=$removed boundsUpdated=$boundsUpdated '
        'discovered=${discovered.length}',
      );
    }
  }

  static bool _hasBounds(PmtilesFile entry) {
    return entry.minZoom != null &&
        entry.maxZoom != null &&
        entry.minLatitude != null &&
        entry.minLongitude != null &&
        entry.maxLatitude != null &&
        entry.maxLongitude != null;
  }

  static Future<PmtilesHeaderBounds?> _readBounds(File file) async {
    try {
      return await PmtilesHeaderBounds.readFromFile(file);
    } catch (error) {
      WfLog.warn(
        null,
        'pmtiles',
        '⚠️ Failed to read PMTiles bounds for ${file.path}: $error',
      );
      return null;
    }
  }
}
