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
    final root = storage.root;

    if (!root.existsSync()) {
      WfLog.warn(
        session,
        'pmtiles',
        '📂 PMTiles catalog sync skipped — storage unavailable at ${root.path}',
      );
      return;
    }

    final discovered = storage.discoverNamedArchives();
    final discoveredByName = <String, File>{
      for (final file in discovered)
        storage.relativeCatalogName(file): file,
    };
    final discoveredByBasename = <String, String>{};
    for (final name in discoveredByName.keys) {
      discoveredByBasename.putIfAbsent(_basename(name), () => name);
    }

    final existing = await PmtilesFile.db.find(session);
    var imported = 0;
    var removed = 0;
    var boundsUpdated = 0;
    var relocated = 0;
    final skipRemovals = discovered.isEmpty && existing.isNotEmpty;

    if (discovered.isEmpty && existing.isEmpty) {
      WfLog.info(
        session,
        'pmtiles',
        '📂 PMTiles catalog sync found 0 .pmtiles files under ${root.path}',
      );
    }

    if (skipRemovals) {
      WfLog.warn(
        session,
        'pmtiles',
        '📂 PMTiles catalog sync found 0 files on disk but '
        '${existing.length} catalog entries — skipping removals',
      );
    }

    for (final entry in existing) {
      if (storage.existsForEntry(id: entry.id.uuid, name: entry.name)) {
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
        continue;
      }

      final relocatedName = discoveredByBasename[_basename(entry.name)];
      if (relocatedName != null) {
        final file = discoveredByName[relocatedName]!;
        final stat = await file.stat();
        await PmtilesFile.db.updateRow(
          session,
          entry.copyWith(
            name: relocatedName,
            sizeBytes: stat.size,
          ),
        );
        relocated++;
        continue;
      }

      if (skipRemovals) {
        continue;
      }

      await PmtilesFile.db.deleteRow(session, entry);
      removed++;
    }

    final catalog = await PmtilesFile.db.find(session);
    final byName = {for (final entry in catalog) entry.name: entry};

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
          isActive: true,
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

    if (imported > 0 || removed > 0 || boundsUpdated > 0 || relocated > 0) {
      WfLog.info(
        session,
        'pmtiles',
        '📂 PMTiles catalog sync from ${storage.root.path}: '
        'imported=$imported removed=$removed relocated=$relocated '
        'boundsUpdated=$boundsUpdated discovered=${discovered.length}',
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

  static String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.substring(normalized.lastIndexOf('/') + 1);
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
