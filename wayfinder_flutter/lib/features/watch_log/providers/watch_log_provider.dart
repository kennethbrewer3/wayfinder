import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../offline_packs/providers/offline_pack_controller.dart';
import '../../offline_packs/providers/offline_snapshot_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
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
    ref.watch(offlineModeActiveProvider);
    ref.watch(offlineSnapshotProvider);
    return _load();
  }

  Future<List<WatchLogEntry>> _load() async {
    if (ref.read(offlineModeActiveProvider)) {
      final snapshot = await ref.read(offlineSnapshotProvider.future);
      final entries = snapshot?.watchLogEntries ?? const <WatchLogEntry>[];
      AppLogger.logMap.info(
        '📓 Watch log from offline pack',
        data: 'count=${entries.length}',
      );
      return entries;
    }
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
    if (ref.read(offlineModeActiveProvider)) {
      await ref.read(offlinePackControllerProvider).enqueueWatchLog(entry);
      await reload();
      return entry;
    }
    final created = await ref
        .read(watchLogRepositoryProvider)
        .createEntry(entry);
    await reload();
    return created;
  }

  Future<WatchLogEntry> updateEntry(WatchLogEntry entry) async {
    if (ref.read(offlineModeActiveProvider)) {
      throw StateError('Watch log edits are not available offline.');
    }
    final updated = await ref
        .read(watchLogRepositoryProvider)
        .updateEntry(entry);
    await reload();
    return updated;
  }

  Future<void> delete(UuidValue id) async {
    if (ref.read(offlineModeActiveProvider)) {
      throw StateError('Watch log deletes are not available offline.');
    }
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
