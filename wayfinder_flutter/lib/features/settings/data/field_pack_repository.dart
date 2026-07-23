import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/app_globals.dart';
import '../../../core/rest_api_headers.dart';
import 'map_data_repository.dart';

class FieldPackRestoreResult {
  const FieldPackRestoreResult({
    required this.map,
    required this.pmtiles,
  });

  final MapDataRestoreResult map;
  final int pmtiles;
}

class FieldPackRepository {
  Uri get _exportUri {
    final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base/api/field-pack/export');
  }

  Uri get _restoreUri {
    final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base/api/field-pack');
  }

  Future<Uint8List> exportFieldPack({
    required List<String> pmtilesIds,
  }) async {
    final response = await http
        .post(
          _exportUri,
          headers: await RestApiHeaders.json(),
          body: jsonEncode({'pmtilesIds': pmtilesIds}),
        )
        .timeout(const Duration(hours: 6));

    if (response.statusCode != 200) {
      final message = _readErrorMessage(response.body);
      throw Exception(
        message ??
            'Field pack export failed: '
                '${response.statusCode} ${response.body}',
      );
    }
    return Uint8List.fromList(response.bodyBytes);
  }

  Future<FieldPackRestoreResult> restoreFieldPack(
    Uint8List archiveBytes,
  ) async {
    if (archiveBytes.isEmpty) {
      throw const FormatException('Field pack archive is empty');
    }

    final response = await http
        .post(
          _restoreUri,
          headers: {
            ...(await RestApiHeaders.readOnly()),
            'Content-Type': 'application/zip',
          },
          body: archiveBytes,
        )
        .timeout(const Duration(hours: 6));

    if (response.statusCode != 200) {
      final message = _readErrorMessage(response.body);
      throw Exception(
        message ??
            'Field pack restore failed: '
                '${response.statusCode} ${response.body}',
      );
    }

    return _parseRestoreResponse(response.body);
  }

  FieldPackRestoreResult _parseRestoreResponse(String bodyText) {
    final body = jsonDecode(bodyText) as Map<String, dynamic>;
    final restored = body['restored'];
    if (restored is! Map<String, dynamic>) {
      throw FormatException(
        'Unexpected field pack restore response: $bodyText',
      );
    }

    final mapRaw = restored['map'];
    if (mapRaw is! Map<String, dynamic>) {
      throw FormatException('Unexpected field pack map summary: $bodyText');
    }

    return FieldPackRestoreResult(
      map: MapDataRestoreResult(
        layers: mapRaw['layers'] as int? ?? 0,
        markers: mapRaw['markers'] as int? ?? 0,
        zones: mapRaw['zones'] as int? ?? 0,
        seasonalOverlays: mapRaw['seasonalOverlays'] as int? ?? 0,
        watchLogEntries: mapRaw['watchLogEntries'] as int? ?? 0,
        markerIconCategories: mapRaw['markerIconCategories'] as int? ?? 0,
        markerIcons: mapRaw['markerIcons'] as int? ?? 0,
      ),
      pmtiles: restored['pmtiles'] as int? ?? 0,
    );
  }

  String? _readErrorMessage(String body) {
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
