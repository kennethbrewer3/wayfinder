import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:serverpod/serverpod.dart';

import '../markers/marker_icon_backup.dart';
import '../markers/marker_icon_storage.dart';
import 'map_data_service.dart';

/// JSON document inside a backup zip archive.
const mapDataBackupArchiveJsonName = 'backup.json';

/// Directory inside the zip that holds `{key}.svg` marker icon files.
const mapDataBackupMarkerIconsDirectory = 'marker-icons';

/// Builds a zip containing [mapDataBackupArchiveJsonName] and custom SVG files.
Future<Uint8List> buildMapDataBackupArchive(Session session) async {
  final bundle = await exportMapDataBundle(session);
  final jsonBundle = _stripEmbeddedSvgContent(bundle);

  final storage = MarkerIconStorage();
  await storage.ensureReady();

  final archive = Archive();
  final jsonText = const JsonEncoder.withIndent('  ').convert(jsonBundle);
  final jsonBytes = utf8.encode(jsonText);
  archive.addFile(
    ArchiveFile(mapDataBackupArchiveJsonName, jsonBytes.length, jsonBytes),
  );

  final addedSvgPaths = <String>{};
  await _addSvgFilesFromCatalog(
    archive: archive,
    storage: storage,
    icons: jsonBundle['markerIcons'],
    addedPaths: addedSvgPaths,
  );
  await _addOrphanSvgFiles(
    archive: archive,
    storage: storage,
    addedPaths: addedSvgPaths,
  );

  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// Restores map data from a zip produced by [buildMapDataBackupArchive].
Future<MapDataRestoreCounts> restoreMapDataFromArchive(
  Session session,
  Uint8List zipBytes,
) async {
  if (zipBytes.isEmpty) {
    throw const FormatException('Backup archive is empty');
  }

  final archive = ZipDecoder().decodeBytes(zipBytes);
  final jsonFile = _findBackupJsonFile(archive);
  if (jsonFile == null) {
    throw FormatException(
      'Backup archive is missing "$mapDataBackupArchiveJsonName"',
    );
  }

  final decoded = jsonDecode(utf8.decode(jsonFile.content));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Backup JSON must be an object');
  }

  _mergeArchiveSvgFiles(archive, decoded);
  return restoreMapDataBundle(session, decoded);
}

/// Merges `marker-icons/*.svg` files from [archive] into [bundle] for restore.
void mergeArchiveSvgFilesIntoBundle(
  Archive archive,
  Map<String, dynamic> bundle,
) {
  _mergeArchiveSvgFiles(archive, bundle);
}

Map<String, dynamic> _stripEmbeddedSvgContent(Map<String, dynamic> bundle) {
  final copy = Map<String, dynamic>.from(bundle);
  final icons = copy['markerIcons'];
  if (icons is! List) {
    return copy;
  }

  copy['markerIcons'] = [
    for (final raw in icons)
      if (raw is Map<String, dynamic>)
        (Map<String, dynamic>.from(raw)..remove(markerIconBackupSvgField))
      else
        raw,
  ];
  return copy;
}

Future<void> _addSvgFilesFromCatalog({
  required Archive archive,
  required MarkerIconStorage storage,
  required Object? icons,
  required Set<String> addedPaths,
}) async {
  if (icons is! List) {
    return;
  }

  for (final raw in icons) {
    if (raw is! Map<String, dynamic>) {
      continue;
    }
    final key = raw['key'];
    if (key is! String || !storage.exists(key)) {
      continue;
    }
    await _addSvgFile(
      archive: archive,
      storage: storage,
      key: key,
      addedPaths: addedPaths,
    );
  }
}

Future<void> _addOrphanSvgFiles({
  required Archive archive,
  required MarkerIconStorage storage,
  required Set<String> addedPaths,
}) async {
  final root = storage.root;
  if (!root.existsSync()) {
    return;
  }

  for (final entity in root.listSync()) {
    if (entity is! File) {
      continue;
    }
    final fileName = entity.uri.pathSegments.last;
    if (!fileName.toLowerCase().endsWith('.svg')) {
      continue;
    }
    final key = fileName.substring(0, fileName.length - 4);
    if (!MarkerIconStorage.isValidKey(key)) {
      continue;
    }
    await _addSvgFile(
      archive: archive,
      storage: storage,
      key: key,
      addedPaths: addedPaths,
    );
  }
}

Future<void> _addSvgFile({
  required Archive archive,
  required MarkerIconStorage storage,
  required String key,
  required Set<String> addedPaths,
}) async {
  final archivePath = '$mapDataBackupMarkerIconsDirectory/$key.svg';
  if (!addedPaths.add(archivePath)) {
    return;
  }

  final bytes = await storage.fileFor(key).readAsBytes();
  archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
}

ArchiveFile? _findBackupJsonFile(Archive archive) {
  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final normalized = file.name.replaceAll('\\', '/');
    if (normalized == mapDataBackupArchiveJsonName) {
      return file;
    }
  }

  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final normalized = file.name.replaceAll('\\', '/');
    if (normalized.endsWith('.json') && !normalized.contains('/')) {
      return file;
    }
  }

  return null;
}

void _mergeArchiveSvgFiles(Archive archive, Map<String, dynamic> bundle) {
  final icons = bundle['markerIcons'];
  if (icons is! List) {
    return;
  }

  final svgByKey = <String, String>{};
  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final normalized = file.name.replaceAll('\\', '/');
    final prefix = '$mapDataBackupMarkerIconsDirectory/';
    if (!normalized.startsWith(prefix) || !normalized.endsWith('.svg')) {
      continue;
    }
    final key = normalized.substring(
      prefix.length,
      normalized.length - '.svg'.length,
    );
    if (!MarkerIconStorage.isValidKey(key)) {
      continue;
    }
    svgByKey[key] = utf8.decode(file.content, allowMalformed: true);
  }

  if (svgByKey.isEmpty) {
    return;
  }

  final mergedIcons = <Object?>[];
  for (final raw in icons) {
    if (raw is! Map<String, dynamic>) {
      mergedIcons.add(raw);
      continue;
    }
    final key = raw['key'];
    if (key is! String) {
      mergedIcons.add(raw);
      continue;
    }
    final svgContent = svgByKey[key];
    if (svgContent == null || svgContent.trim().isEmpty) {
      mergedIcons.add(raw);
      continue;
    }
    mergedIcons.add({...raw, markerIconBackupSvgField: svgContent});
  }

  bundle['markerIcons'] = mergedIcons;
}
