import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';

class WatchLogRepository {
  WatchLogRepository(this._client);

  final Client _client;

  Future<List<WatchLogEntry>> listEntries() {
    return _client.watchLog.listEntries();
  }

  Future<WatchLogEntry> createEntry(WatchLogEntry entry) {
    return _client.watchLog.createEntry(entry);
  }

  Future<WatchLogEntry> updateEntry(WatchLogEntry entry) {
    return _client.watchLog.updateEntry(entry);
  }

  Future<bool> deleteEntry(UuidValue id) {
    return _client.watchLog.deleteEntry(id);
  }
}

final watchLogRepositoryProvider = Provider<WatchLogRepository>(
  (ref) => WatchLogRepository(ref.watch(serverClientProvider)),
);
