import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/app_globals.dart';
import '../../../core/rest_api_headers.dart';

const mapDataBackupVersion = 1;

class MapDataRestoreResult {
  const MapDataRestoreResult({
    required this.layers,
    required this.markers,
    required this.zones,
  });

  final int layers;
  final int markers;
  final int zones;
}

class MapDataRepository {
  MapDataRepository({required Client client}) : _client = client;

  final Client _client;

  Uri get _restoreUri {
    final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base/api/map-data/restore');
  }

  /// Builds backup JSON from existing list endpoints (works without mapData RPC).
  Future<String> fetchBackupJson() async {
    final layers = await _client.mapLayer.listLayers();
    final markers = await _client.mapMarker.listMarkers();
    final zones = await _client.mapZone.listZones();

    final payload = {
      'version': mapDataBackupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'layers': layers.map(_encodeModel).toList(),
      'markers': markers.map(_encodeModel).toList(),
      'zones': zones.map(_encodeModel).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
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

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final restored = body['restored'];
    if (restored is! Map<String, dynamic>) {
      throw FormatException('Unexpected restore response: ${response.body}');
    }

    return MapDataRestoreResult(
      layers: restored['layers'] as int? ?? 0,
      markers: restored['markers'] as int? ?? 0,
      zones: restored['zones'] as int? ?? 0,
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

  String _restoreUnavailableMessage(Object error) {
    if (_isMapDataEndpointUnavailable(error)) {
      return 'Restore requires an updated Wayfinder server. '
          'Restart the server from the latest code, then try again.';
    }
    return error.toString();
  }

  Map<String, dynamic> _encodeModel(dynamic model) {
    final json = Map<String, dynamic>.from(model.toJson() as Map);
    json.remove('__className__');
    return json;
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
