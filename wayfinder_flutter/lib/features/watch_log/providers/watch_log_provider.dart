import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../data/watch_log_repository.dart';

enum WatchLogSeverity {
  info,
  notice,
  warning,
  critical;

  static WatchLogSeverity parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'notice' => WatchLogSeverity.notice,
      'warning' => WatchLogSeverity.warning,
      'critical' => WatchLogSeverity.critical,
      _ => WatchLogSeverity.info,
    };
  }

  String get storageValue => name;
}

final watchLogEntriesProvider =
    AsyncNotifierProvider<WatchLogEntriesNotifier, List<WatchLogEntry>>(
      WatchLogEntriesNotifier.new,
    );

class WatchLogEntriesNotifier extends AsyncNotifier<List<WatchLogEntry>> {
  @override
  Future<List<WatchLogEntry>> build() {
    return _load();
  }

  Future<List<WatchLogEntry>> _load() async {
    AppLogger.logMap.debug('📓 Fetching watch log entries');
    final entries = await ref.read(watchLogRepositoryProvider).listEntries();
    AppLogger.logMap.success(
      '📓 Watch log loaded',
      data: 'count=${entries.length}',
    );
    return entries;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<WatchLogEntry> create(WatchLogEntry entry) async {
    final created = await ref
        .read(watchLogRepositoryProvider)
        .createEntry(entry);
    await reload();
    return created;
  }

  Future<WatchLogEntry> updateEntry(WatchLogEntry entry) async {
    final updated = await ref
        .read(watchLogRepositoryProvider)
        .updateEntry(entry);
    await reload();
    return updated;
  }

  Future<void> delete(UuidValue id) async {
    await ref.read(watchLogRepositoryProvider).deleteEntry(id);
    await reload();
  }
}

List<WatchLogEntry> watchLogEntriesForMarker(
  List<WatchLogEntry> entries,
  UuidValue markerId,
) {
  return [
    for (final entry in entries)
      if (entry.markerId == markerId) entry,
  ];
}

List<WatchLogEntry> watchLogEntriesForZone(
  List<WatchLogEntry> entries,
  UuidValue zoneId,
) {
  return [
    for (final entry in entries)
      if (entry.zoneId == zoneId) entry,
  ];
}
