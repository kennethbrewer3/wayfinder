import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../web/rest/rest_json.dart';
import 'marker_attachment_service.dart';
import 'marker_attachment_storage.dart';

const mapDataBackupMarkerAttachmentsDirectory = 'marker-attachments';
const mapDataBackupMarkerAttachmentsField = 'markerAttachments';

class MarkerAttachmentRestoreCounts {
  const MarkerAttachmentRestoreCounts({required this.attachments});

  final int attachments;
}

Future<Map<String, dynamic>> exportMarkerAttachmentBackup(
  Session session,
) async {
  final entries = await MarkerAttachment.db.find(
    session,
    orderByList: (t) => [
      Order(column: t.markerId),
      Order(column: t.sortOrder),
      Order(column: t.addedAt),
    ],
  );
  return {
    mapDataBackupMarkerAttachmentsField: RestJson.encodeModels(entries),
  };
}

Future<Map<String, Uint8List>> resolveMarkerAttachmentFilesForArchive(
  Session session,
) async {
  final storage = MarkerAttachmentStorage();
  if (!await storage.ensureReady()) {
    throw const FormatException('Marker attachment storage is unavailable');
  }

  final entries = await MarkerAttachment.db.find(session);
  final files = <String, Uint8List>{};
  for (final entry in entries) {
    if (!storage.exists(entry.storageId)) {
      continue;
    }
    files[entry.storageId] = await storage
        .fileFor(entry.storageId)
        .readAsBytes();
  }
  return files;
}

/// Writes attachment files from [archive] into storage and restores DB rows.
Future<MarkerAttachmentRestoreCounts> restoreMarkerAttachmentBackup(
  Session session,
  Map<String, dynamic> body, {
  Archive? archive,
}) async {
  final raw = body[mapDataBackupMarkerAttachmentsField];
  if (raw is! List) {
    return const MarkerAttachmentRestoreCounts(attachments: 0);
  }

  await MarkerAttachmentService.deleteAll(session);

  final storage = MarkerAttachmentStorage();
  if (!await storage.ensureReady()) {
    throw const FormatException('Marker attachment storage is unavailable');
  }

  final markerIds = {
    for (final marker in await MapMarker.db.find(session)) marker.id,
  };

  var restored = 0;
  for (final item in raw) {
    if (item is! Map<String, dynamic>) {
      continue;
    }
    final entry = MarkerAttachment.fromJson(item);
    if (!markerIds.contains(entry.markerId)) {
      continue;
    }

    Uint8List? bytes;
    if (archive != null) {
      bytes = _readArchiveBytes(
        archive,
        '$mapDataBackupMarkerAttachmentsDirectory/${entry.storageId}',
      );
    }
    if (bytes == null || bytes.isEmpty) {
      continue;
    }

    await storage.writeBytes(entry.storageId, bytes);
    await MarkerAttachment.db.insertRow(session, entry);
    restored += 1;
  }

  return MarkerAttachmentRestoreCounts(attachments: restored);
}

Uint8List? _readArchiveBytes(Archive archive, String name) {
  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final normalized = file.name.replaceAll('\\', '/');
    if (normalized != name) {
      continue;
    }
    return file.content;
  }
  return null;
}
