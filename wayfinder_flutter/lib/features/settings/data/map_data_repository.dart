import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/app_globals.dart';
import '../../../core/rest_api_headers.dart';

const mapDataBackupVersion = 3;

class MapDataRestoreResult {
  const MapDataRestoreResult({
    required this.layers,
    required this.markers,
    required this.zones,
    this.markerIconCategories = 0,
    this.markerIcons = 0,
  });

  final int layers;
  final int markers;
  final int zones;
  final int markerIconCategories;
  final int markerIcons;
}

class MapDataRepository {
  MapDataRepository({required Client client}) : _client = client;

  final Client _client;

  Uri get _exportUri {
    final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base/api/map-data');
  }

  Uri get _exportArchiveUri {
    final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base/api/map-data/backup.zip');
  }

  Uri get _restoreUri {
    final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base/api/map-data/restore');
  }

  Uri get _restoreArchiveUri => _exportArchiveUri;

  Future<Uint8List> fetchBackupArchive() async {
    try {
      final archive = await _client.mapData.exportMapDataArchive();
      return archive.buffer.asUint8List(
        archive.offsetInBytes,
        archive.lengthInBytes,
      );
    } on Object catch (rpcError) {
      if (!kIsWeb && _isMapDataEndpointUnavailable(rpcError)) {
        return _fetchBackupArchiveViaRest();
      }
      throw Exception(_exportUnavailableMessage(rpcError));
    }
  }

  Future<Uint8List> _fetchBackupArchiveViaRest() async {
    final response = await http.get(
      _exportArchiveUri,
      headers: await RestApiHeaders.readOnly(),
    );
    if (response.statusCode != 200) {
      final message = _readErrorMessage(response.body);
      throw Exception(
        message ?? 'Export failed: ${response.statusCode} ${response.body}',
      );
    }
    return Uint8List.fromList(response.bodyBytes);
  }

  Future<String> fetchBackupJson() async {
    try {
      final jsonText = await _client.mapData.exportMapData();
      return _prettyPrintJson(jsonText);
    } on Object catch (rpcError) {
      if (!kIsWeb && _isMapDataEndpointUnavailable(rpcError)) {
        return _fetchBackupJsonViaRest();
      }
      throw Exception(_exportUnavailableMessage(rpcError));
    }
  }

  Future<String> _fetchBackupJsonViaRest() async {
    final response = await http.get(
      _exportUri,
      headers: await RestApiHeaders.readOnly(),
    );
    if (response.statusCode != 200) {
      final message = _readErrorMessage(response.body);
      throw Exception(
        message ?? 'Export failed: ${response.statusCode} ${response.body}',
      );
    }
    return _prettyPrintJson(response.body);
  }

  Future<MapDataRestoreResult> restoreFromArchive(
    Uint8List archiveBytes,
  ) async {
    if (archiveBytes.isEmpty) {
      throw const FormatException('Backup archive is empty');
    }

    try {
      final summary = await _client.mapData.restoreMapDataArchive(
        ByteData.sublistView(archiveBytes),
      );
      return MapDataRestoreResult(
        layers: summary.layers,
        markers: summary.markers,
        zones: summary.zones,
        markerIconCategories: summary.markerIconCategories,
        markerIcons: summary.markerIcons,
      );
    } on Object catch (rpcError) {
      if (!kIsWeb && _isMapDataEndpointUnavailable(rpcError)) {
        return _restoreFromArchiveViaRest(archiveBytes);
      }
      throw Exception(_restoreUnavailableMessage(rpcError));
    }
  }

  Future<MapDataRestoreResult> _restoreFromArchiveViaRest(
    Uint8List archiveBytes,
  ) async {
    final response = await http.post(
      _restoreArchiveUri,
      headers: {
        ...(await RestApiHeaders.readOnly()),
        'Content-Type': 'application/zip',
      },
      body: archiveBytes,
    );

    if (response.statusCode != 200) {
      final message = _readErrorMessage(response.body);
      throw Exception(
        message ?? 'Restore failed: ${response.statusCode} ${response.body}',
      );
    }

    return _parseRestoreResponse(response.body);
  }

  Future<MapDataRestoreResult> restoreFromJson(String jsonText) async {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup file must contain a JSON object');
    }

    try {
      final summary = await _client.mapData.restoreMapData(jsonText);
      return MapDataRestoreResult(
        layers: summary.layers,
        markers: summary.markers,
        zones: summary.zones,
        markerIconCategories: summary.markerIconCategories,
        markerIcons: summary.markerIcons,
      );
    } on Object catch (rpcError) {
      if (!kIsWeb && _isMapDataEndpointUnavailable(rpcError)) {
        return _restoreFromJsonViaRest(decoded);
      }
      throw Exception(_restoreUnavailableMessage(rpcError));
    }
  }

  Future<MapDataRestoreResult> _restoreFromJsonViaRest(
    Map<String, dynamic> decoded,
  ) async {
    final response = await http.post(
      _restoreUri,
      headers: await RestApiHeaders.json(),
      body: jsonEncode(decoded),
    );

    if (response.statusCode != 200) {
      final message = _readErrorMessage(response.body);
      throw Exception(
        message ?? 'Restore failed: ${response.statusCode} ${response.body}',
      );
    }

    return _parseRestoreResponse(response.body);
  }

  MapDataRestoreResult _parseRestoreResponse(String bodyText) {
    final body = jsonDecode(bodyText) as Map<String, dynamic>;
    final restored = body['restored'];
    if (restored is! Map<String, dynamic>) {
      throw FormatException('Unexpected restore response: $bodyText');
    }

    return MapDataRestoreResult(
      layers: restored['layers'] as int? ?? 0,
      markers: restored['markers'] as int? ?? 0,
      zones: restored['zones'] as int? ?? 0,
      markerIconCategories: restored['markerIconCategories'] as int? ?? 0,
      markerIcons: restored['markerIcons'] as int? ?? 0,
    );
  }

  bool _isMapDataEndpointUnavailable(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('serverpodclientnotfound') ||
        text.contains('statuscode = 404') ||
        text.contains('method not found') ||
        text.contains('endpoint not found') ||
        text.contains('get /api/map-data returned 404');
  }

  String _exportUnavailableMessage(Object error) {
    if (_isMapDataEndpointUnavailable(error)) {
      return 'Export requires an updated Wayfinder server. '
          'Restart the server from the latest code, then try again.';
    }
    return error.toString();
  }

  String _restoreUnavailableMessage(Object error) {
    if (_isMapDataEndpointUnavailable(error)) {
      return 'Restore requires an updated Wayfinder server. '
          'Restart the server from the latest code, then try again.';
    }
    return error.toString();
  }

  String _prettyPrintJson(String jsonText) {
    final decoded = jsonDecode(jsonText);
    return const JsonEncoder.withIndent('  ').convert(decoded);
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
