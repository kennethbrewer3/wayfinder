import 'dart:io';

/// Filesystem storage for uploaded PMTiles archives.
class PmtilesStorage {
  PmtilesStorage({String? rootDirectory})
      : _root = Directory(rootDirectory ?? 'storage/pmtiles');

  final Directory _root;

  Directory get root => _root;

  Future<void> ensureReady() async {
    if (!_root.existsSync()) {
      await _root.create(recursive: true);
    }
  }

  File fileFor(String id) => File('${_root.path}/$id');

  Future<void> writeStream(String id, Stream<List<int>> bytes) async {
    await ensureReady();
    final file = fileFor(id);
    final sink = file.openWrite();
    try {
      await for (final chunk in bytes) {
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
  }

  Future<void> delete(String id) async {
    final file = fileFor(id);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  bool exists(String id) => fileFor(id).existsSync();
}
