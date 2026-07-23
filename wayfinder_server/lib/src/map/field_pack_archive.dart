import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../pmtiles/pmtiles_storage.dart';
import 'map_data_backup_archive.dart';
import 'map_data_service.dart';

/// Spare-server / spare-laptop transfer pack (map objects + icons + PMTiles).
const wayfinderFieldFormat = 'wayfinder-field';
const wayfinderFieldFormatVersion = 1;
const wayfinderFieldEnvelopeName = 'wayfinder-field.json';
const fieldPackMapDirectory = 'map';
const fieldPackPmtilesDirectory = 'pmtiles';
const fieldPackPmtilesCatalogName = 'pmtiles/catalog.json';

class FieldPackRestoreSummary {
  const FieldPackRestoreSummary({
    required this.map,
    required this.pmtiles,
  });

  final MapDataRestoreCounts map;
  final int pmtiles;

  Map<String, dynamic> toJson() => {
    'map': map.toJson(),
    'pmtiles': pmtiles,
  };
}

/// Builds a `.wayfinder-field` zip: map backup + selected PMTiles archives.
Future<Uint8List> buildFieldPackArchive(
  Session session, {
  required List<UuidValue> pmtilesIds,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'wayfinder-field-pack-',
  );
  try {
    final outFile = File('${tempDir.path}/pack.wayfinder-field');
    final encoder = ZipFileEncoder();
    encoder.create(outFile.path, level: ZipFileEncoder.store);

    final envelope = utf8.encode(
      const JsonEncoder.withIndent('  ').convert({
        'format': wayfinderFieldFormat,
        'version': wayfinderFieldFormatVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'pmtilesCount': pmtilesIds.length,
      }),
    );
    encoder.addArchiveFile(
      ArchiveFile(wayfinderFieldEnvelopeName, envelope.length, envelope),
    );

    final mapBytes = await buildMapDataBackupArchive(session);
    final mapArchive = ZipDecoder().decodeBytes(mapBytes);
    for (final file in mapArchive.files) {
      if (!file.isFile) {
        continue;
      }
      final normalized = file.name.replaceAll('\\', '/');
      final bytes = file.content;
      encoder.addArchiveFile(
        ArchiveFile(
          '$fieldPackMapDirectory/$normalized',
          bytes.length,
          bytes,
        ),
      );
    }

    final storage = PmtilesStorage();
    final catalogFiles = <Map<String, dynamic>>[];
    for (final id in pmtilesIds) {
      final entry = await PmtilesFile.db.findById(session, id);
      if (entry == null) {
        throw FormatException('PMTiles file not found: ${id.uuid}');
      }
      final diskFile = storage.resolveFileForEntry(
        id: id.uuid,
        name: entry.name,
      );
      if (!diskFile.existsSync()) {
        throw FormatException(
          'PMTiles bytes missing on disk for ${entry.name} (${id.uuid})',
        );
      }

      final archiveName = '${id.uuid}.pmtiles';
      await encoder.addFile(
        diskFile,
        '$fieldPackPmtilesDirectory/$archiveName',
        ZipFileEncoder.store,
      );

      catalogFiles.add({
        'id': id.uuid,
        'name': entry.name,
        'sizeBytes': entry.sizeBytes,
        'isActive': entry.isActive,
        'addedAt': entry.addedAt.toUtc().toIso8601String(),
        'minZoom': entry.minZoom,
        'maxZoom': entry.maxZoom,
        'minLatitude': entry.minLatitude,
        'minLongitude': entry.minLongitude,
        'maxLatitude': entry.maxLatitude,
        'maxLongitude': entry.maxLongitude,
        'archiveName': archiveName,
      });
    }

    final catalogBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert({'files': catalogFiles}),
    );
    encoder.addArchiveFile(
      ArchiveFile(
        fieldPackPmtilesCatalogName,
        catalogBytes.length,
        catalogBytes,
      ),
    );

    await encoder.close();
    return outFile.readAsBytes();
  } finally {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}

/// Restores map data and PMTiles from a field pack archive.
Future<FieldPackRestoreSummary> restoreFieldPackArchive(
  Session session,
  Uint8List zipBytes,
) async {
  if (zipBytes.isEmpty) {
    throw const FormatException('Field pack archive is empty');
  }

  final archive = ZipDecoder().decodeBytes(zipBytes);
  _validateEnvelope(archive);

  final mapCounts = await _restoreMapSection(session, archive);
  final pmtilesCount = await _restorePmtilesSection(session, archive);

  return FieldPackRestoreSummary(map: mapCounts, pmtiles: pmtilesCount);
}

void _validateEnvelope(Archive archive) {
  final envelopeBytes = _readArchiveFile(archive, wayfinderFieldEnvelopeName);
  if (envelopeBytes == null) {
    throw const FormatException(
      'Field pack archive must contain wayfinder-field.json',
    );
  }

  final decoded = jsonDecode(utf8.decode(envelopeBytes));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('wayfinder-field.json must be an object');
  }

  final format = decoded['format']?.toString();
  if (format != null && format != wayfinderFieldFormat) {
    throw FormatException('Unsupported field pack format: $format');
  }

  final version = decoded['version'];
  if (version is int && version > wayfinderFieldFormatVersion) {
    throw FormatException(
      'Unsupported field pack version: $version '
      '(max $wayfinderFieldFormatVersion)',
    );
  }
}

Future<MapDataRestoreCounts> _restoreMapSection(
  Session session,
  Archive archive,
) async {
  final mapArchive = Archive();
  final prefix = '$fieldPackMapDirectory/';
  var found = false;
  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final normalized = file.name.replaceAll('\\', '/');
    if (!normalized.startsWith(prefix)) {
      continue;
    }
    found = true;
    final relative = normalized.substring(prefix.length);
    final bytes = file.content;
    mapArchive.addFile(ArchiveFile(relative, bytes.length, bytes));
  }

  if (!found) {
    throw const FormatException(
      'Field pack archive is missing map/ backup contents',
    );
  }

  final mapZip = Uint8List.fromList(ZipEncoder().encode(mapArchive));
  return restoreMapDataFromArchive(session, mapZip);
}

Future<int> _restorePmtilesSection(Session session, Archive archive) async {
  final catalogBytes = _readArchiveFile(archive, fieldPackPmtilesCatalogName);
  if (catalogBytes == null) {
    return 0;
  }

  final decoded = jsonDecode(utf8.decode(catalogBytes));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('pmtiles/catalog.json must be an object');
  }

  final files = decoded['files'];
  if (files is! List) {
    throw const FormatException('pmtiles/catalog.json must include "files"');
  }

  final storage = PmtilesStorage();
  if (!await storage.ensureReady()) {
    throw const FormatException('PMTiles storage is unavailable');
  }

  var restored = 0;
  for (final raw in files) {
    if (raw is! Map<String, dynamic>) {
      continue;
    }
    final idRaw = raw['id']?.toString();
    final name = raw['name']?.toString();
    final archiveName = raw['archiveName']?.toString();
    if (idRaw == null ||
        idRaw.isEmpty ||
        name == null ||
        name.isEmpty ||
        archiveName == null ||
        archiveName.isEmpty) {
      throw const FormatException(
        'Each PMTiles catalog entry needs id, name, and archiveName',
      );
    }

    final id = UuidValue.fromString(idRaw);
    final archivePath = '$fieldPackPmtilesDirectory/$archiveName';
    final fileBytes = _readArchiveFile(archive, archivePath);
    if (fileBytes == null || fileBytes.isEmpty) {
      throw FormatException('Missing PMTiles archive entry: $archivePath');
    }

    await storage.writeStream(id.uuid, Stream.value(fileBytes));
    final sizeBytes = fileBytes.length;
    final isActive = raw['isActive'] == true;
    final addedAt = _parseDateTime(raw['addedAt']) ?? DateTime.now().toUtc();

    final existing = await PmtilesFile.db.findById(session, id);
    final entry = PmtilesFile(
      id: id,
      name: name,
      sizeBytes: sizeBytes,
      isActive: isActive,
      addedAt: addedAt,
      minZoom: raw['minZoom'] as int?,
      maxZoom: raw['maxZoom'] as int?,
      minLatitude: (raw['minLatitude'] as num?)?.toDouble(),
      minLongitude: (raw['minLongitude'] as num?)?.toDouble(),
      maxLatitude: (raw['maxLatitude'] as num?)?.toDouble(),
      maxLongitude: (raw['maxLongitude'] as num?)?.toDouble(),
    );

    if (existing == null) {
      await PmtilesFile.db.insertRow(session, entry);
    } else {
      await PmtilesFile.db.updateRow(session, entry);
    }
    restored += 1;
  }

  return restored;
}

DateTime? _parseDateTime(Object? raw) {
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw)?.toUtc();
  }
  return null;
}

Uint8List? _readArchiveFile(Archive archive, String name) {
  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final normalized = file.name.replaceAll('\\', '/');
    if (normalized != name) {
      continue;
    }
    return file.content;
  }
  return null;
}
