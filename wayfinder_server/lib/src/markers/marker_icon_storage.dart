import 'dart:io';
import 'dart:typed_data';

import '../core/wayfinder_env.dart';

/// Filesystem storage for marker icon SVG files (`{key}.svg`).
class MarkerIconStorage {
  MarkerIconStorage._(this._root);

  static MarkerIconStorage? _instance;

  static MarkerIconStorage get instance {
    _instance ??= MarkerIconStorage._(
      Directory(WayfinderEnv.markerIconStoragePath),
    );
    return _instance!;
  }

  static void configure(String path) {
    _instance = MarkerIconStorage._(Directory(path));
  }

  factory MarkerIconStorage() => instance;

  final Directory _root;

  Directory get root => _root;

  static final RegExp _validKey = RegExp(r'^[a-z0-9_]{1,64}$');

  static bool isValidKey(String key) => _validKey.hasMatch(key);

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

  File fileFor(String key) {
    _requireValidKey(key);
    return File('${_root.path}/$key.svg');
  }

  bool exists(String key) {
    if (!isValidKey(key)) {
      return false;
    }
    return fileFor(key).existsSync();
  }

  Future<void> writeStream(String key, Stream<List<int>> stream) async {
    await ensureReady();
    final file = fileFor(key);
    final sink = file.openWrite();
    try {
      await stream.forEach(sink.add);
    } finally {
      await sink.close();
    }
  }

  Future<void> writeBytes(String key, Uint8List bytes) async {
    await ensureReady();
    await fileFor(key).writeAsBytes(bytes, flush: true);
  }

  Future<void> delete(String key) async {
    if (!isValidKey(key)) {
      return;
    }
    final file = fileFor(key);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  void _requireValidKey(String key) {
    if (!isValidKey(key)) {
      throw FormatException(
        'Invalid marker icon key "$key". Use lowercase letters, digits, and underscores.',
      );
    }
  }
}
