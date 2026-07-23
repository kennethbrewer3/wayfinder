import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:serverpod/serverpod.dart';

import '../markers/marker_attachment_backup.dart';
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
  final inlineSvgByKey = _extractInlineSvgContentByKey(bundle['markerIcons']);
  final jsonBundle = _stripEmbeddedSvgContent(bundle);

  final storage = MarkerIconStorage();
  if (!await storage.ensureReady()) {
    throw const FormatException('Marker icon storage is unavailable');
  }

  final archive = Archive();
  final svgFiles = await resolveMarkerIconSvgFilesForArchive(
    icons: _readIconMaps(jsonBundle['markerIcons']),
    storage: storage,
    inlineSvgContentByKey: inlineSvgByKey,
  );

  _syncHasCustomSvgFlags(jsonBundle, svgFiles.keys);

  final attachmentFiles = await resolveMarkerAttachmentFilesForArchive(
    session,
  );

  final jsonText = const JsonEncoder.withIndent('  ').convert(jsonBundle);
  final jsonBytes = utf8.encode(jsonText);
  archive.addFile(
    ArchiveFile(mapDataBackupArchiveJsonName, jsonBytes.length, jsonBytes),
  );

  for (final entry in svgFiles.entries) {
    final archivePath = '$mapDataBackupMarkerIconsDirectory/${entry.key}.svg';
    final bytes = entry.value;
    archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
  }

  for (final entry in attachmentFiles.entries) {
    final archivePath = '$mapDataBackupMarkerAttachmentsDirectory/${entry.key}';
    final bytes = entry.value;
    archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
  }

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
  final counts = await restoreMapDataBundle(session, decoded);
  if ((decoded['version'] as int?) != null &&
      (decoded['version'] as int) >= 6) {
    final attachmentCounts = await restoreMarkerAttachmentBackup(
      session,
      decoded,
      archive: archive,
    );
    return MapDataRestoreCounts(
      layers: counts.layers,
      markers: counts.markers,
      zones: counts.zones,
      seasonalOverlays: counts.seasonalOverlays,
      watchLogEntries: counts.watchLogEntries,
      markerIconCategories: counts.markerIconCategories,
      markerIcons: counts.markerIcons,
      markerAttachments: attachmentCounts.attachments,
    );
  }
  return counts;
}

/// Merges `marker-icons/*.svg` files from [archive] into [bundle] for restore.
void mergeArchiveSvgFilesIntoBundle(
  Archive archive,
  Map<String, dynamic> bundle,
) {
  _mergeArchiveSvgFiles(archive, bundle);
}

/// Resolves SVG bytes to store under [mapDataBackupMarkerIconsDirectory].
Future<Map<String, Uint8List>> resolveMarkerIconSvgFilesForArchive({
  required Iterable<Map<String, dynamic>> icons,
  required MarkerIconStorage storage,
  Map<String, String>? inlineSvgContentByKey,
}) async {
  final inline = inlineSvgContentByKey ?? const {};
  final resolved = <String, Uint8List>{};

  for (final icon in icons) {
    final key = icon['key'];
    if (key is! String || !MarkerIconStorage.isValidKey(key)) {
      continue;
    }

    final hasCustomSvg = icon['hasCustomSvg'] == true;
    if (!hasCustomSvg && !storage.exists(key) && !inline.containsKey(key)) {
      continue;
    }

    final bytes = await _readSvgBytesForKey(
      key: key,
      storage: storage,
      inlineSvg: inline[key],
    );
    if (bytes != null && bytes.isNotEmpty) {
      resolved[key] = bytes;
    }
  }

  await _addOrphanSvgFiles(
    storage: storage,
    resolved: resolved,
  );

  return resolved;
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

Map<String, String> _extractInlineSvgContentByKey(Object? icons) {
  if (icons is! List) {
    return const {};
  }

  final inline = <String, String>{};
  for (final raw in icons) {
    if (raw is! Map<String, dynamic>) {
      continue;
    }
    final key = raw['key'];
    final svgRaw = raw[markerIconBackupSvgField];
    if (key is String &&
        svgRaw is String &&
        svgRaw.trim().isNotEmpty &&
        MarkerIconStorage.isValidKey(key)) {
      inline[key] = svgRaw;
    }
  }
  return inline;
}

List<Map<String, dynamic>> _readIconMaps(Object? icons) {
  if (icons is! List) {
    return const [];
  }

  return [
    for (final raw in icons)
      if (raw is Map<String, dynamic>) raw,
  ];
}

void _syncHasCustomSvgFlags(
  Map<String, dynamic> bundle,
  Iterable<String> svgKeys,
) {
  final icons = bundle['markerIcons'];
  if (icons is! List) {
    return;
  }

  final keysWithSvg = svgKeys.toSet();
  bundle['markerIcons'] = [
    for (final raw in icons)
      if (raw is Map<String, dynamic>)
        _syncIconHasCustomSvg(raw, keysWithSvg)
      else
        raw,
  ];
}

Map<String, dynamic> _syncIconHasCustomSvg(
  Map<String, dynamic> icon,
  Set<String> keysWithSvg,
) {
  final key = icon['key'];
  if (key is! String) {
    return icon;
  }

  final copy = Map<String, dynamic>.from(icon);
  copy['hasCustomSvg'] = keysWithSvg.contains(key);
  return copy;
}

Future<Uint8List?> _readSvgBytesForKey({
  required String key,
  required MarkerIconStorage storage,
  String? inlineSvg,
}) async {
  if (storage.exists(key)) {
    return storage.fileFor(key).readAsBytes();
  }

  if (inlineSvg != null && inlineSvg.trim().isNotEmpty) {
    return Uint8List.fromList(utf8.encode(inlineSvg));
  }

  return null;
}

Future<void> _addOrphanSvgFiles({
  required MarkerIconStorage storage,
  required Map<String, Uint8List> resolved,
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
    if (!MarkerIconStorage.isValidKey(key) || resolved.containsKey(key)) {
      continue;
    }

    final bytes = await entity.readAsBytes();
    if (bytes.isNotEmpty) {
      resolved[key] = bytes;
    }
  }
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
