import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'pmtiles_storage.dart';

class PmtilesEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'pmtiles';

  PmtilesStorage get _storage => PmtilesStorage();

  String _storageId(UuidValue id) => id.uuid;

  Future<List<PmtilesFile>> listFiles(Session session) {
    return loggedCall(
      session,
      _tag,
      'listFiles',
      () => PmtilesFile.db.find(
        session,
        orderBy: (t) => t.addedAt,
        orderDescending: true,
      ),
      onSuccess: (files) => 'count=${files.length}',
    );
  }

  Future<UuidValue?> activeFileId(Session session) {
    return loggedCall(
      session,
      _tag,
      'activeFileId',
      () async {
        final active = await PmtilesFile.db.findFirstRow(
          session,
          where: (t) => t.isActive.equals(true),
        );
        return active?.id;
      },
      onSuccess: (id) => id?.uuid ?? '(none)',
    );
  }

  Future<void> setActiveFile(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'setActiveFile',
      () async {
        final file = await PmtilesFile.db.findById(session, id);
        if (file == null) {
          throw FormatException('PMTiles file not found: ${id.uuid}');
        }
        if (!_storage.exists(_storageId(id))) {
          throw StateError('PMTiles file bytes missing on disk: ${id.uuid}');
        }

        await PmtilesFile.db.updateWhere(
          session,
          where: (t) => t.isActive.equals(true),
          columnValues: (t) => [t.isActive(false)],
        );
        await PmtilesFile.db.updateRow(
          session,
          file.copyWith(isActive: true),
        );
      },
      onSuccess: (_) => 'activeId=${id.uuid}',
    );
  }

  Future<void> clearActiveFile(Session session) {
    return loggedCall(
      session,
      _tag,
      'clearActiveFile',
      () => PmtilesFile.db.updateWhere(
        session,
        where: (t) => t.isActive.equals(true),
        columnValues: (t) => [t.isActive(false)],
      ),
      onSuccess: (_) => 'cleared',
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

        await _storage.delete(_storageId(id));
        await PmtilesFile.db.deleteRow(session, file);

        if (file.isActive) {
          final remaining = await PmtilesFile.db.find(
            session,
            orderBy: (t) => t.addedAt,
            orderDescending: true,
            limit: 1,
          );
          if (remaining.isNotEmpty) {
            await setActiveFile(session, remaining.first.id);
          }
        }

        return true;
      },
      onSuccess: (deleted) =>
          deleted ? 'deleted id=${id.uuid}' : 'not found id=${id.uuid}',
    );
  }
}
