import 'dart:io';

import '../core/wayfinder_env.dart';

/// Filesystem storage for PMTiles archives.
///
/// Uploaded files are stored as `{uuid}` (no extension). Pre-existing archives
/// in [root] keep their path relative to [root] (including subfolders); the
/// catalog sync registers them by that relative path.
class PmtilesStorage {
  PmtilesStorage._(this._root);

  static PmtilesStorage? _instance;

  static PmtilesStorage get instance {
    _instance ??= PmtilesStorage._(
      Directory(WayfinderEnv.pmtilesStoragePath),
    );
    return _instance!;
  }

  static void configure(String path) {
    _instance = PmtilesStorage._(Directory(path));
  }

  factory PmtilesStorage() => instance;

  final Directory _root;

  Directory get root => _root;

  /// Ensures the storage directory exists when it can be created locally.
  ///
  /// Returns `false` when the path is missing (for example an unmounted
  /// external drive at `/Volumes/...`) so the server can still start.
  Future<bool> ensureReady() async {
    if (_root.existsSync()) {
      return true;
    }

    try {
      await _root.create(recursive: true);
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Lists `.pmtiles` files under [root], including subdirectories.
  List<File> discoverNamedArchives() {
    if (!_root.existsSync()) {
      return const [];
    }

    final results = <File>[];
    _scanDirectory(_root, results);
    return results;
  }

  void _scanDirectory(Directory directory, List<File> results) {
    Iterable<FileSystemEntity> entries;
    try {
      entries = directory.listSync(followLinks: false);
    } on FileSystemException {
      return;
    }

    for (final entity in entries) {
      if (entity is Link) {
        _scanLinkedEntity(entity, results);
        continue;
      }
      if (entity is File) {
        if (_isPmtilesArchive(entity.path)) {
          results.add(entity);
        }
        continue;
      }
      if (entity is Directory) {
        if (_basename(entity.path).startsWith('.')) {
          continue;
        }
        _scanDirectory(entity, results);
      }
    }
  }

  void _scanLinkedEntity(Link link, List<File> results) {
    if (_basename(link.path).startsWith('.')) {
      return;
    }

    FileSystemEntityType type;
    try {
      type = FileSystemEntity.typeSync(link.path, followLinks: true);
    } on FileSystemException {
      return;
    }

    switch (type) {
      case FileSystemEntityType.file:
        if (_isPmtilesArchive(link.path)) {
          results.add(File(link.path));
        }
      case FileSystemEntityType.directory:
        _scanDirectory(Directory(link.path), results);
      case FileSystemEntityType.unixDomainSock:
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.link:
      case FileSystemEntityType.notFound:
        return;
    }
  }

  bool _isPmtilesArchive(String path) {
    return _basename(path).toLowerCase().endsWith('.pmtiles');
  }

  /// Catalog name for a discovered archive (path relative to [root]).
  String relativeCatalogName(File file) {
    final rootPath = _normalizedPath(_root.absolute.path);
    final filePath = _normalizedPath(file.absolute.path);
    if (!filePath.startsWith('$rootPath/')) {
      return _basename(filePath);
    }
    return filePath.substring(rootPath.length + 1);
  }

  File fileForId(String id) => File('${_root.path}/$id');

  File fileForName(String name) => File('${_root.path}/$name');

  File resolveFileForEntry({required String id, required String name}) {
    final byId = fileForId(id);
    if (byId.existsSync()) {
      return byId;
    }

    final byName = fileForName(name);
    if (byName.existsSync()) {
      return byName;
    }

    return byId;
  }

  bool existsForEntry({required String id, required String name}) {
    return fileForId(id).existsSync() || fileForName(name).existsSync();
  }

  Future<void> writeStream(String id, Stream<List<int>> bytes) async {
    await ensureReady();
    final file = fileForId(id);
    final sink = file.openWrite();
    try {
      await for (final chunk in bytes) {
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
  }

  Future<void> deleteForEntry({
    required String id,
    required String name,
  }) async {
    final file = resolveFileForEntry(id: id, name: name);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  // Backwards-compatible helpers used by upload cleanup.
  File fileFor(String id) => fileForId(id);

  bool exists(String id) => fileForId(id).existsSync();

  Future<void> delete(String id) async {
    final file = fileForId(id);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static String _basename(String path) {
    final normalized = _normalizedPath(path);
    return normalized.substring(normalized.lastIndexOf('/') + 1);
  }

  static String _normalizedPath(String path) {
    return path.replaceAll('\\', '/');
  }
}
