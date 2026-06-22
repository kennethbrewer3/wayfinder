import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Many-to-many membership between [PmtilesFile] rows and [PmtilesGroup] rows.
abstract final class PmtilesFileGroups {
  static Future<List<PmtilesFile>> withGroupIds(
    Session session,
    List<PmtilesFile> files,
  ) async {
    if (files.isEmpty) {
      return files;
    }

    final byFileId = await groupIdsByFileId(session);
    return [
      for (final file in files)
        file.copyWith(
          groupIds: byFileId[file.id.uuid] ?? const [],
        ),
    ];
  }

  static Future<Map<String, List<UuidValue>>> groupIdsByFileId(
    Session session,
  ) async {
    final links = await PmtilesFileGroupLink.db.find(session);
    final result = <String, List<UuidValue>>{};
    for (final link in links) {
      result.putIfAbsent(link.fileId.uuid, () => []).add(link.groupId);
    }
    return result;
  }

  static Future<List<PmtilesFile>> filesInGroup(
    Session session,
    UuidValue groupId,
  ) async {
    final links = await PmtilesFileGroupLink.db.find(
      session,
      where: (t) => t.groupId.equals(groupId),
    );
    if (links.isEmpty) {
      return const [];
    }

    final files = <PmtilesFile>[];
    for (final link in links) {
      final file = await PmtilesFile.db.findById(session, link.fileId);
      if (file != null) {
        files.add(file);
      }
    }
    return files;
  }

  static Future<Set<UuidValue>> ungroupedFileIds(Session session) async {
    final files = await PmtilesFile.db.find(session);
    final links = await PmtilesFileGroupLink.db.find(session);
    final grouped = {for (final link in links) link.fileId};
    return {
      for (final file in files)
        if (!grouped.contains(file.id)) file.id,
    };
  }

  static Future<void> addFileToGroup(
    Session session,
    UuidValue fileId,
    UuidValue groupId,
  ) async {
    final existing = await PmtilesFileGroupLink.db.findFirstRow(
      session,
      where: (t) => t.fileId.equals(fileId) & t.groupId.equals(groupId),
    );
    if (existing != null) {
      return;
    }

    await PmtilesFileGroupLink.db.insertRow(
      session,
      PmtilesFileGroupLink(fileId: fileId, groupId: groupId),
    );
  }

  static Future<void> removeFileFromGroup(
    Session session,
    UuidValue fileId,
    UuidValue groupId,
  ) async {
    await PmtilesFileGroupLink.db.deleteWhere(
      session,
      where: (t) => t.fileId.equals(fileId) & t.groupId.equals(groupId),
    );
  }

  static Future<void> removeAllForFile(
    Session session,
    UuidValue fileId,
  ) async {
    await PmtilesFileGroupLink.db.deleteWhere(
      session,
      where: (t) => t.fileId.equals(fileId),
    );
  }

  static Future<void> removeAllForGroup(
    Session session,
    UuidValue groupId,
  ) async {
    await PmtilesFileGroupLink.db.deleteWhere(
      session,
      where: (t) => t.groupId.equals(groupId),
    );
  }

  /// Keeps grouped files' [PmtilesFile.isActive] aligned with whether any
  /// linked group has [PmtilesGroup.showOnMap]. Ungrouped files are unchanged.
  static Future<void> syncFileActiveFromGroups(
    Session session,
    UuidValue fileId,
  ) async {
    final links = await PmtilesFileGroupLink.db.find(
      session,
      where: (t) => t.fileId.equals(fileId),
    );
    if (links.isEmpty) {
      return;
    }

    var shouldBeActive = false;
    for (final link in links) {
      final group = await PmtilesGroup.db.findById(session, link.groupId);
      if (group?.showOnMap ?? false) {
        shouldBeActive = true;
        break;
      }
    }

    final file = await PmtilesFile.db.findById(session, fileId);
    if (file == null || file.isActive == shouldBeActive) {
      return;
    }

    await PmtilesFile.db.updateRow(
      session,
      file.copyWith(isActive: shouldBeActive),
    );
  }

  static Future<void> syncGroupFilesActiveFromGroups(
    Session session,
    UuidValue groupId,
  ) async {
    final files = await filesInGroup(session, groupId);
    for (final file in files) {
      await syncFileActiveFromGroups(session, file.id);
    }
  }
}
