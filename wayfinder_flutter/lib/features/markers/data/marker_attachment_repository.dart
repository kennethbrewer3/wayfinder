import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/rest_api_headers.dart';
import '../../../core/serverpod_client.dart';

class MarkerAttachmentRepository {
  MarkerAttachmentRepository({required Client client}) : _client = client;

  final Client _client;
  static final _log = AppLogger.logMarkers;

  String get _webServerUrl =>
      appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');

  Future<List<MarkerAttachment>> listForMarker(UuidValue markerId) {
    return _client.markerAttachment.listForMarker(markerId);
  }

  String fileUrl(String storageId) =>
      '$_webServerUrl/marker-attachments/files/$storageId';

  Future<MarkerAttachment> upload({
    required UuidValue markerId,
    required String fileName,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final uri = Uri.parse('$_webServerUrl/marker-attachments/upload').replace(
      queryParameters: {
        'markerId': markerId.uuid,
        'fileName': fileName,
        'contentType': contentType,
      },
    );
    _log.info(
      '🖼️ Uploading marker attachment',
      data: 'marker=${markerId.uuid} file=$fileName bytes=${bytes.length}',
    );

    final response = await http
        .post(
          uri,
          headers: {
            ...(await RestApiHeaders.readOnly()),
            'Content-Type': contentType,
          },
          body: bytes,
        )
        .timeout(const Duration(minutes: 10));

    if (response.statusCode != 200) {
      final message =
          _readError(response.body) ??
          'Upload failed: ${response.statusCode} ${response.body}';
      throw StateError(message);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final entry = MarkerAttachment.fromJson(decoded);
    _log.success(
      '🖼️ Marker attachment uploaded',
      data: 'id=${entry.id.uuid} size=${entry.sizeBytes}',
    );
    return entry;
  }

  Future<MarkerAttachment> uploadPickedFile({
    required UuidValue markerId,
    required PlatformFile file,
  }) async {
    final bytes = await _readFileBytes(file);
    if (bytes.isEmpty) {
      throw const FormatException('Selected photo is empty');
    }
    final contentType = _contentTypeForFileName(file.name);
    return upload(
      markerId: markerId,
      fileName: file.name,
      contentType: contentType,
      bytes: bytes,
    );
  }

  Future<Uint8List> _readFileBytes(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Uint8List.fromList(bytes);
    }
    final readStream = file.readStream;
    if (readStream != null) {
      final collected = await readStream.fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );
      return Uint8List.fromList(collected);
    }
    throw const FormatException('Could not read photo file bytes');
  }

  Future<bool> delete(UuidValue id) {
    return _client.markerAttachment.deleteAttachment(id);
  }

  String _contentTypeForFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return 'image/jpeg';
  }

  String? _readError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is String && error.isNotEmpty) {
          return error;
        }
      }
    } on Object {
      return null;
    }
    return null;
  }
}

final markerAttachmentRepositoryProvider = Provider<MarkerAttachmentRepository>(
  (ref) => MarkerAttachmentRepository(
    client: ref.watch(serverClientProvider),
  ),
);
