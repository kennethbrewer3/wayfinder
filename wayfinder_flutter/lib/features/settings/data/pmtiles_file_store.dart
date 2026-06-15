import 'dart:typed_data';

/// Stores raw PMTiles bytes on the current platform.
abstract class PmtilesFileStore {
  Future<void> write(String id, Uint8List bytes);
  Future<Uint8List?> read(String id);
  Future<void> delete(String id);
  Future<bool> exists(String id);
  Future<Set<String>> listStoredIds();

  /// Optional key/value metadata persisted alongside tile blobs (web IndexedDB).
  Future<void> writeMeta(String key, String value) async {}
  Future<String?> readMeta(String key) async => null;
  Future<void> deleteMeta(String key) async {}

  /// Returns a local filesystem path when available.
  Future<String?> localPath(String id) async => null;
}
