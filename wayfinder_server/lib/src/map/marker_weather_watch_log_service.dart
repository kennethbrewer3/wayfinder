import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../watch_log/watch_log_entry_change_broadcast.dart';
import 'marker_weather_watch_log.dart';

/// Appends a watch-log entry when a weather station's readings change.
///
/// Internal side effect of marker create/update (RPC and REST). Does not
/// require [WayfinderPermission.addWatchLog] — same pattern as tracking zones.
abstract final class MarkerWeatherWatchLogService {
  static Future<void> maybeAppend({
    required Session session,
    required MapMarker? before,
    required MapMarker after,
  }) async {
    if (after.icon != weatherStationMarkerIcon) {
      return;
    }
    if (!weatherReadingsChanged(before?.weatherJson, after.weatherJson)) {
      return;
    }

    final summary = formatWeatherWatchLogSummary(after.weatherJson);
    if (summary == null) {
      return;
    }

    final now = DateTime.now().toUtc();
    final source = weatherSource(after.weatherJson);
    final author =
        source ??
        after.updatedByUsername ??
        after.createdByUsername ??
        'weather';
    final created = await WatchLogEntry.db.insertRow(
      session,
      WatchLogEntry(
        occurredAt: weatherObservedAt(after.weatherJson) ?? now,
        author: author,
        severity: weatherWatchLogSeverity(after.weatherJson),
        text: '${after.name}: $summary',
        markerId: after.id,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await WatchLogEntryChangeBroadcast.created(session, created);
  }
}
