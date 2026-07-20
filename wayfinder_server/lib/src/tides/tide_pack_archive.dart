import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'tide_storage.dart';

const wayfinderTideFormat = 'wayfinder-tide';
const wayfinderTideFormatVersion = 1;
const wayfinderTideEnvelopeName = 'wayfinder-tide.json';
const wayfinderTideManifestName = 'manifest.json';
const wayfinderTideStationsName = 'stations.json';

/// Builds a `.wayfinder-tide` zip for offline transfer (not part of map backup).
Future<Uint8List> exportTidePackArchive(
  TideStorage storage,
  String packId,
) async {
  final pack = await storage.loadPack(packId.trim());
  if (pack == null) {
    throw FormatException('Tide pack not found: $packId');
  }

  final archive = Archive();
  final envelope = utf8.encode(
    const JsonEncoder.withIndent('  ').convert({
      'format': wayfinderTideFormat,
      'version': wayfinderTideFormatVersion,
      'packId': pack.id,
    }),
  );
  final manifest = utf8.encode(
    const JsonEncoder.withIndent('  ').convert(pack.toManifestJson()),
  );
  final stations = utf8.encode(
    const JsonEncoder.withIndent('  ').convert({
      'stations': pack.stations.map((s) => s.toJson()).toList(),
    }),
  );

  archive.addFile(
    ArchiveFile(wayfinderTideEnvelopeName, envelope.length, envelope),
  );
  archive.addFile(
    ArchiveFile(wayfinderTideManifestName, manifest.length, manifest),
  );
  archive.addFile(
    ArchiveFile(wayfinderTideStationsName, stations.length, stations),
  );

  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// Restores a pack from a `.wayfinder-tide` / zip archive.
Future<TidePackRecord> importTidePackArchive(
  TideStorage storage,
  Uint8List zipBytes,
) async {
  if (zipBytes.isEmpty) {
    throw const FormatException('Tide pack archive is empty');
  }

  final archive = ZipDecoder().decodeBytes(zipBytes);
  final manifestBytes = _readArchiveFile(archive, wayfinderTideManifestName);
  final stationsBytes = _readArchiveFile(archive, wayfinderTideStationsName);
  if (manifestBytes == null || stationsBytes == null) {
    throw const FormatException(
      'Tide pack archive must contain manifest.json and stations.json',
    );
  }

  final envelopeBytes = _readArchiveFile(archive, wayfinderTideEnvelopeName);
  if (envelopeBytes != null) {
    final envelope = jsonDecode(utf8.decode(envelopeBytes));
    if (envelope is Map<String, dynamic>) {
      final format = envelope['format']?.toString();
      final version = envelope['version'];
      if (format != null && format != wayfinderTideFormat) {
        throw FormatException('Unsupported tide pack format: $format');
      }
      if (version is int && version > wayfinderTideFormatVersion) {
        throw FormatException(
          'Unsupported tide pack version: $version '
          '(max $wayfinderTideFormatVersion)',
        );
      }
    }
  }

  final manifestJson =
      jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
  final stationsJson = jsonDecode(utf8.decode(stationsBytes));
  final stationsList = stationsJson is List
      ? stationsJson
      : (stationsJson as Map<String, dynamic>)['stations'] as List<dynamic>;
  final stations = stationsList
      .cast<Map<String, dynamic>>()
      .map(TideStationRecord.fromJson)
      .toList();
  if (stations.isEmpty) {
    throw const FormatException('Tide pack archive has no stations');
  }

  final parsed = TidePackRecord.fromManifestJson(
    manifestJson,
    stations: stations,
    sizeBytes: 0,
  );
  if (!TideStorage.isValidPackId(parsed.id)) {
    throw FormatException('Invalid tide pack id in archive: ${parsed.id}');
  }

  final existing = await storage.listPacks();
  final prior = await storage.loadPack(parsed.id);
  final isFirstPack = existing.isEmpty;
  final pack = TidePackRecord(
    id: parsed.id,
    name: parsed.name,
    source: parsed.source,
    datum: parsed.datum,
    units: parsed.units,
    stationCount: stations.length,
    sizeBytes: 0,
    importedAt: DateTime.now().toUtc(),
    isActive: prior?.isActive ?? isFirstPack,
    minLatitude: parsed.minLatitude,
    minLongitude: parsed.minLongitude,
    maxLatitude: parsed.maxLatitude,
    maxLongitude: parsed.maxLongitude,
    stations: stations,
  );
  return storage.savePack(pack);
}

Uint8List? _readArchiveFile(Archive archive, String fileName) {
  for (final file in archive.files) {
    if (!file.isFile) {
      continue;
    }
    final name = file.name.replaceAll('\\', '/');
    final base = name.split('/').last;
    if (base == fileName || name == fileName) {
      return Uint8List.fromList(file.content);
    }
  }
  return null;
}
