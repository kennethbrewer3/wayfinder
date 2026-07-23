import 'dart:io';
import 'dart:typed_data';

import '../core/wayfinder_env.dart';

/// Filesystem storage for marker photo/attachment blobs (`{storageId}`).
class MarkerAttachmentStorage {
  MarkerAttachmentStorage._(this._root);

  static MarkerAttachmentStorage? _instance;

  static MarkerAttachmentStorage get instance {
    _instance ??= MarkerAttachmentStorage._(
      Directory(WayfinderEnv.markerAttachmentStoragePath),
    );
    return _instance!;
  }

  static void configure(String path) {
    _instance = MarkerAttachmentStorage._(Directory(path));
  }

  factory MarkerAttachmentStorage() => instance;

  final Directory _root;

  Directory get root => _root;

  static final RegExp _validStorageId = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isValidStorageId(String id) => _validStorageId.hasMatch(id);

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

  File fileFor(String storageId) {
    if (!isValidStorageId(storageId)) {
      throw FormatException('Invalid attachment storage id: $storageId');
    }
    return File('${_root.path}/$storageId');
  }

  bool exists(String storageId) {
    if (!isValidStorageId(storageId)) {
      return false;
    }
    return fileFor(storageId).existsSync();
  }

  Future<void> writeBytes(String storageId, Uint8List bytes) async {
    await ensureReady();
    await fileFor(storageId).writeAsBytes(bytes, flush: true);
  }

  Future<void> writeStream(String storageId, Stream<List<int>> stream) async {
    await ensureReady();
    final sink = fileFor(storageId).openWrite();
    try {
      await for (final chunk in stream) {
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
  }

  Future<void> delete(String storageId) async {
    if (!isValidStorageId(storageId)) {
      return;
    }
    final file = fileFor(storageId);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> deleteAll() async {
    if (!_root.existsSync()) {
      return;
    }
    for (final entity in _root.listSync()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }
}
