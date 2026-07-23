import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'marker_attachment_storage.dart';

/// Metadata + disk helpers for marker photo attachments.
abstract final class MarkerAttachmentService {
  static const maxBytesPerFile = 15 * 1024 * 1024;
  static const maxAttachmentsPerMarker = 20;

  static const allowedContentTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  static Future<List<MarkerAttachment>> listForMarker(
    Session session,
    UuidValue markerId,
  ) {
    return MarkerAttachment.db.find(
      session,
      where: (t) => t.markerId.equals(markerId),
      orderByList: (t) => [
        Order(column: t.sortOrder),
        Order(column: t.addedAt),
      ],
    );
  }

  static Future<int> countForMarker(Session session, UuidValue markerId) async {
    return MarkerAttachment.db.count(
      session,
      where: (t) => t.markerId.equals(markerId),
    );
  }

  static String normalizeContentType(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value == 'image/jpg') {
      return 'image/jpeg';
    }
    return value;
  }

  static String sanitizeFileName(String? raw, {required String contentType}) {
    var name = (raw ?? '').trim().replaceAll(RegExp(r'[/\\]'), '_');
    if (name.isEmpty) {
      name = switch (contentType) {
        'image/png' => 'photo.png',
        'image/webp' => 'photo.webp',
        _ => 'photo.jpg',
      };
    }
    if (name.length > 180) {
      name = name.substring(name.length - 180);
    }
    return name;
  }

  static Future<MarkerAttachment> createFromBytes(
    Session session, {
    required UuidValue markerId,
    required String fileName,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final marker = await MapMarker.db.findById(session, markerId);
    if (marker == null) {
      throw FormatException('Marker not found: ${markerId.uuid}');
    }

    final normalizedType = normalizeContentType(contentType);
    if (!allowedContentTypes.contains(normalizedType)) {
      throw FormatException(
        'Unsupported content type "$contentType". '
        'Allowed: ${allowedContentTypes.join(', ')}',
      );
    }
    if (bytes.isEmpty) {
      throw const FormatException('Attachment body is empty');
    }
    if (bytes.length > maxBytesPerFile) {
      throw FormatException(
        'Attachment exceeds ${maxBytesPerFile ~/ (1024 * 1024)} MB limit',
      );
    }

    final count = await countForMarker(session, markerId);
    if (count >= maxAttachmentsPerMarker) {
      throw FormatException(
        'Marker already has $maxAttachmentsPerMarker attachments',
      );
    }

    final storage = MarkerAttachmentStorage();
    if (!await storage.ensureReady()) {
      throw const FormatException('Marker attachment storage is unavailable');
    }

    final id = const Uuid().v4obj();
    final storageId = id.uuid;
    await storage.writeBytes(storageId, bytes);

    final existing = await listForMarker(session, markerId);
    final nextSort = existing.isEmpty
        ? 0
        : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final entry = MarkerAttachment(
      id: id,
      markerId: markerId,
      fileName: sanitizeFileName(fileName, contentType: normalizedType),
      contentType: normalizedType,
      sizeBytes: bytes.length,
      storageId: storageId,
      addedAt: DateTime.now().toUtc(),
      sortOrder: nextSort,
    );
    await MarkerAttachment.db.insertRow(session, entry);
    return entry;
  }

  static Future<bool> deleteAttachment(
    Session session,
    UuidValue attachmentId,
  ) async {
    final entry = await MarkerAttachment.db.findById(session, attachmentId);
    if (entry == null) {
      return false;
    }
    await MarkerAttachment.db.deleteRow(session, entry);
    await MarkerAttachmentStorage().delete(entry.storageId);
    return true;
  }

  static Future<void> deleteAllForMarker(
    Session session,
    UuidValue markerId,
  ) async {
    final entries = await listForMarker(session, markerId);
    if (entries.isEmpty) {
      return;
    }
    await MarkerAttachment.db.delete(session, entries);
    final storage = MarkerAttachmentStorage();
    for (final entry in entries) {
      await storage.delete(entry.storageId);
    }
  }

  static Future<void> deleteAll(Session session) async {
    final entries = await MarkerAttachment.db.find(session);
    if (entries.isNotEmpty) {
      await MarkerAttachment.db.delete(session, entries);
    }
    await MarkerAttachmentStorage().deleteAll();
  }
}
