import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../../comms/comms_plan_change_broadcast.dart';
import '../../layers/map_layer_change_broadcast.dart';
import '../../map/field_pack_archive.dart';
import '../../map/map_marker_change_broadcast.dart';
import '../../seasonal_overlays/seasonal_overlay_change_broadcast.dart';
import '../../watch_log/watch_log_entry_change_broadcast.dart';
import '../../zones/map_zone_change_broadcast.dart';
import 'rest_json.dart';

abstract final class FieldPackRestHandlers {
  /// POST JSON `{ "pmtilesIds": ["uuid", ...] }` → `.wayfinder-field` zip.
  static Future<Result> export(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final ids = _parsePmtilesIds(body['pmtilesIds']);
      final bytes = await buildFieldPackArchive(session, pmtilesIds: ids);
      return Response.ok(
        body: Body.fromData(
          bytes,
          mimeType: MimeType.parse('application/zip'),
        ),
      );
    });
  }

  /// POST raw zip body → restore map + PMTiles.
  static Future<Result> restore(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final bytes = await _readRequestBytes(request);
      final summary = await restoreFieldPackArchive(session, bytes);
      await MapLayerChangeBroadcast.bulk(session);
      await MapMarkerChangeBroadcast.bulk(session);
      await MapZoneChangeBroadcast.bulk(session);
      await SeasonalOverlayChangeBroadcast.bulk(session);
      await WatchLogEntryChangeBroadcast.bulk(session);
      await CommsPlanChangeBroadcast.bulk(session);
      return RestJson.ok({'restored': summary.toJson()});
    });
  }

  static List<UuidValue> _parsePmtilesIds(Object? raw) {
    if (raw == null) {
      return const [];
    }
    if (raw is! List) {
      throw const FormatException('Field "pmtilesIds" must be an array');
    }

    final ids = <UuidValue>[];
    final seen = <String>{};
    for (final item in raw) {
      final text = item?.toString().trim() ?? '';
      if (text.isEmpty) {
        continue;
      }
      if (!seen.add(text)) {
        continue;
      }
      ids.add(RestJson.parseUuid(text, label: 'pmtilesIds'));
    }
    return ids;
  }

  static Future<Uint8List> _readRequestBytes(Request request) async {
    final chunks = await request.read().fold<List<int>>(
      <int>[],
      (previous, chunk) => previous..addAll(chunk),
    );
    return Uint8List.fromList(chunks);
  }
}
