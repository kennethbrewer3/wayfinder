import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'pmtiles_catalog_sync.dart';
import 'pmtiles_storage.dart';

class PmtilesEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'pmtiles';

  PmtilesStorage get _storage => PmtilesStorage();

  Future<List<PmtilesFile>> listFiles(Session session) {
    return loggedCall(
      session,
      _tag,
      'listFiles',
      () async {
        await PmtilesCatalogSync.sync(session);
        return PmtilesFile.db.find(
          session,
          orderBy: (t) => t.addedAt,
          orderDescending: true,
        );
      },
      onSuccess: (files) => 'count=${files.length}',
    );
  }

  Future<List<PmtilesGroup>> listGroups(Session session) {
    return loggedCall(
      session,
      _tag,
      'listGroups',
      () => PmtilesGroup.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      ),
      onSuccess: (groups) => 'count=${groups.length}',
    );
  }

  Future<PmtilesGroup> createGroup(Session session, String name) {
    return loggedCall(
      session,
      _tag,
      'createGroup',
      () async {
        final trimmed = name.trim();
        if (trimmed.isEmpty) {
          throw FormatException('Group name cannot be empty.');
        }

        final existing = await PmtilesGroup.db.count(
          session,
          where: (t) => t.name.equals(trimmed),
        );
        if (existing > 0) {
          throw FormatException('A group named "$trimmed" already exists.');
        }

        final groups = await PmtilesGroup.db.find(session);
        final nextSortOrder = groups.isEmpty
            ? 0
            : groups.map((group) => group.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

        return PmtilesGroup.db.insertRow(
          session,
          PmtilesGroup(
            name: trimmed,
            sortOrder: nextSortOrder,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      },
      onSuccess: (group) => 'id=${group.id.uuid} name="${group.name}"',
    );
  }

  Future<PmtilesGroup> renameGroup(
    Session session,
    UuidValue id,
    String name,
  ) {
    return loggedCall(
      session,
      _tag,
      'renameGroup',
      () async {
        final group = await PmtilesGroup.db.findById(session, id);
        if (group == null) {
          throw FormatException('PMTiles group not found: ${id.uuid}');
        }

        final trimmed = name.trim();
        if (trimmed.isEmpty) {
          throw FormatException('Group name cannot be empty.');
        }

        return PmtilesGroup.db.updateRow(
          session,
          group.copyWith(name: trimmed),
        );
      },
      onSuccess: (group) => 'id=${group.id.uuid} name="${group.name}"',
    );
  }

  Future<bool> deleteGroup(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteGroup',
      () async {
        final group = await PmtilesGroup.db.findById(session, id);
        if (group == null) {
          return false;
        }

        await PmtilesFile.db.updateWhere(
          session,
          where: (t) => t.groupId.equals(id),
          columnValues: (t) => [t.groupId(null)],
        );
        await PmtilesGroup.db.deleteRow(session, group);
        return true;
      },
      onSuccess: (deleted) =>
          deleted ? 'deleted id=${id.uuid}' : 'not found id=${id.uuid}',
    );
  }

  Future<void> setFileGroup(
    Session session,
    UuidValue fileId,
    UuidValue? groupId,
  ) {
    return loggedCall(
      session,
      _tag,
      'setFileGroup',
      () async {
        final file = await PmtilesFile.db.findById(session, fileId);
        if (file == null) {
          throw FormatException('PMTiles file not found: ${fileId.uuid}');
        }

        if (groupId != null) {
          final group = await PmtilesGroup.db.findById(session, groupId);
          if (group == null) {
            throw FormatException('PMTiles group not found: ${groupId.uuid}');
          }
        }

        await PmtilesFile.db.updateRow(
          session,
          file.copyWith(groupId: groupId),
        );
      },
      onSuccess: (_) => 'fileId=${fileId.uuid} groupId=${groupId?.uuid ?? '(none)'}',
    );
  }

  Future<void> setGroupEnabled(
    Session session,
    UuidValue groupId, {
    required bool enabled,
  }) {
    return loggedCall(
      session,
      _tag,
      'setGroupEnabled',
      () async {
        final group = await PmtilesGroup.db.findById(session, groupId);
        if (group == null) {
          throw FormatException('PMTiles group not found: ${groupId.uuid}');
        }

        if (enabled) {
          final files = await PmtilesFile.db.find(
            session,
            where: (t) => t.groupId.equals(groupId),
          );
          for (final file in files) {
            if (!_storage.existsForEntry(id: file.id.uuid, name: file.name)) {
              throw StateError(
                'PMTiles file bytes missing on disk: ${file.id.uuid}',
              );
            }
          }
        }

        await PmtilesFile.db.updateWhere(
          session,
          where: (t) => t.groupId.equals(groupId),
          columnValues: (t) => [t.isActive(enabled)],
        );
      },
      onSuccess: (_) => 'groupId=${groupId.uuid} enabled=$enabled',
    );
  }

  Future<void> setUngroupedEnabled(
    Session session, {
    required bool enabled,
  }) {
    return loggedCall(
      session,
      _tag,
      'setUngroupedEnabled',
      () async {
        if (enabled) {
          final files = await PmtilesFile.db.find(
            session,
            where: (t) => t.groupId.equals(null),
          );
          for (final file in files) {
            if (!_storage.existsForEntry(id: file.id.uuid, name: file.name)) {
              throw StateError(
                'PMTiles file bytes missing on disk: ${file.id.uuid}',
              );
            }
          }
        }

        await PmtilesFile.db.updateWhere(
          session,
          where: (t) => t.groupId.equals(null),
          columnValues: (t) => [t.isActive(enabled)],
        );
      },
      onSuccess: (_) => 'enabled=$enabled',
    );
  }

  Future<UuidValue?> activeFileId(Session session) {
    return loggedCall(
      session,
      _tag,
      'activeFileId',
      () async {
        final enabled = await PmtilesFile.db.find(
          session,
          where: (t) => t.isActive.equals(true),
          orderBy: (t) => t.addedAt,
          orderDescending: true,
          limit: 1,
        );
        return enabled.isEmpty ? null : enabled.first.id;
      },
      onSuccess: (id) => id?.uuid ?? '(none)',
    );
  }

  /// Enables a file on the map without disabling others.
  Future<void> setActiveFile(Session session, UuidValue id) {
    return setFileEnabled(session, id, enabled: true);
  }

  Future<void> setFileEnabled(
    Session session,
    UuidValue id, {
    required bool enabled,
  }) {
    return loggedCall(
      session,
      _tag,
      'setFileEnabled',
      () async {
        final file = await PmtilesFile.db.findById(session, id);
        if (file == null) {
          throw FormatException('PMTiles file not found: ${id.uuid}');
        }
        if (enabled &&
            !_storage.existsForEntry(id: id.uuid, name: file.name)) {
          throw StateError('PMTiles file bytes missing on disk: ${id.uuid}');
        }

        await PmtilesFile.db.updateRow(
          session,
          file.copyWith(isActive: enabled),
        );
      },
      onSuccess: (_) => 'id=${id.uuid} enabled=$enabled',
    );
  }

  Future<void> enableAllFiles(Session session) {
    return loggedCall(
      session,
      _tag,
      'enableAllFiles',
      () async {
        await PmtilesCatalogSync.sync(session);
        final files = await PmtilesFile.db.find(session);
        for (final file in files) {
          if (!file.isActive) {
            await PmtilesFile.db.updateRow(
              session,
              file.copyWith(isActive: true),
            );
          }
        }
      },
      onSuccess: (_) => 'enabled all',
    );
  }

  Future<void> clearActiveFile(Session session) {
    return disableAllFiles(session);
  }

  Future<void> disableAllFiles(Session session) {
    return loggedCall(
      session,
      _tag,
      'disableAllFiles',
      () => PmtilesFile.db.updateWhere(
        session,
        where: (t) => t.isActive.equals(true),
        columnValues: (t) => [t.isActive(false)],
      ),
      onSuccess: (_) => 'disabled all',
    );
  }

  Future<bool> deleteFile(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteFile',
      () async {
        final file = await PmtilesFile.db.findById(session, id);
        if (file == null) {
          return false;
        }

        await _storage.deleteForEntry(id: id.uuid, name: file.name);
        await PmtilesFile.db.deleteRow(session, file);
        return true;
      },
      onSuccess: (deleted) =>
          deleted ? 'deleted id=${id.uuid}' : 'not found id=${id.uuid}',
    );
  }
}
