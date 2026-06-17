import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'map_data_service.dart';

class MapDataEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapData';

  Future<String> exportMapData(Session session) {
    return loggedCall(
      session,
      _tag,
      'exportMapData',
      () async {
        final data = await exportMapDataBundle(session);
        return jsonEncode(data);
      },
      onSuccess: (json) => 'bytes=${json.length}',
    );
  }

  Future<MapDataRestoreSummary> restoreMapData(
    Session session,
    String backupJson,
  ) {
    return loggedCall(
      session,
      _tag,
      'restoreMapData',
      () async {
        final decoded = jsonDecode(backupJson);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Backup must be a JSON object');
        }
        final counts = await restoreMapDataBundle(session, decoded);
        return MapDataRestoreSummary(
          layers: counts.layers,
          markers: counts.markers,
          zones: counts.zones,
        );
      },
      onSuccess: (summary) =>
          'layers=${summary.layers} markers=${summary.markers} zones=${summary.zones}',
    );
  }
}
