import 'dart:async';
import 'dart:typed_data';

import 'package:pmtiles/pmtiles.dart';

import '../models/pmtiles_source.dart';

/// Reference-counted pool so scoring probes and map layers can share one open
/// archive per source without closing an archive another caller still uses.
class PmtilesArchivePool {
  PmtilesArchivePool._();

  static final PmtilesArchivePool instance = PmtilesArchivePool._();

  final Map<String, _PoolEntry> _entries = {};
  final Map<String, Future<PmTilesArchive>> _opening = {};
  final Map<String, Future<void>> _operationLocks = {};

  Future<PmTilesArchive> acquire(
    PmtilesSource source,
    Future<PmTilesArchive> Function() open,
  ) {
    final key = pmtilesSourceKey(source);
    return _runLocked(key, () async {
      final existing = _entries[key];
      if (existing != null) {
        existing.refCount++;
        return existing.archive;
      }

      final pending = _opening.putIfAbsent(key, () async {
        final archive = await open();
        _entries[key] = _PoolEntry(archive: archive, refCount: 0);
        return archive;
      });

      try {
        await pending;
        _entries[key]!.refCount++;
        return _entries[key]!.archive;
      } finally {
        if (identical(_opening[key], pending)) {
          _opening.remove(key);
        }
      }
    });
  }

  Future<void> release(PmtilesSource source) {
    final key = pmtilesSourceKey(source);
    return _runLocked(key, () async {
      final entry = _entries[key];
      if (entry == null) {
        return;
      }

      entry.refCount--;
      if (entry.refCount > 0) {
        return;
      }

      _entries.remove(key);
      await entry.archive.close();
    });
  }

  Future<T> _runLocked<T>(String key, Future<T> Function() action) async {
    final previous = _operationLocks[key] ?? Future<void>.value();
    final gate = Completer<void>();
    _operationLocks[key] = gate.future;

    await previous.catchError((_) {});
    try {
      return await action();
    } finally {
      gate.complete();
      if (identical(_operationLocks[key], gate.future)) {
        _operationLocks.remove(key);
      }
    }
  }
}

class _PoolEntry {
  _PoolEntry({required this.archive, required this.refCount});

  final PmTilesArchive archive;
  int refCount;
}

String pmtilesSourceKey(PmtilesSource source) {
  return switch (source) {
    PmtilesSourcePath(:final path) => 'path:$path',
    PmtilesSourceUrl(:final url) => 'url:$url',
    PmtilesSourceBytes(:final bytes) =>
      'bytes:${bytes.length}:${_bytesFingerprint(bytes)}',
  };
}

String _bytesFingerprint(Uint8List bytes) {
  if (bytes.isEmpty) {
    return '0';
  }
  final sampleLength = bytes.length < 32 ? bytes.length : 32;
  var hash = 0;
  for (var index = 0; index < sampleLength; index++) {
    hash = 31 * hash + bytes[index];
  }
  return '$hash';
}
