import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';
import 'package:wayfinder_server/src/tides/tide_harmonic_predict.dart';
import 'package:wayfinder_server/src/tides/tide_pack_archive.dart';
import 'package:wayfinder_server/src/tides/tide_storage.dart';

void main() {
  late Directory tempDir;
  late TideStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wayfinder-tide-pack-');
    TideStorage.configure(tempDir.path);
    storage = TideStorage();
    await storage.ensureReady();
  });

  tearDown(() async {
    TideStorage.configure('storage/tides');
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('exportPackArchive / importPackArchive round-trips stations', () async {
    final original = TidePackRecord(
      id: 'test-coast',
      name: 'Test Coast',
      source: 'unit-test',
      datum: 'MLLW',
      units: 'meters',
      stationCount: 1,
      sizeBytes: 0,
      importedAt: DateTime.utc(2026, 1, 2),
      isActive: true,
      minLatitude: 38,
      minLongitude: -77,
      maxLatitude: 39,
      maxLongitude: -76,
      stations: [
        TideStationRecord(
          id: '1234567',
          name: 'Demo Station',
          lat: 38.5,
          lng: -76.5,
          timezone: 'UTC',
          meanLevelMeters: 0.1,
          constituents: const [
            TideConstituent(
              name: 'M2',
              amplitudeMeters: 0.5,
              phaseGmtDeg: 10,
              speedDegPerHour: 28.984104,
            ),
          ],
        ),
      ],
    );
    await storage.savePack(original);

    final bytes = await exportTidePackArchive(storage, original.id);
    expect(bytes, isNotEmpty);

    final archive = ZipDecoder().decodeBytes(bytes);
    final names = archive.files.map((f) => f.name).toSet();
    expect(names, contains(wayfinderTideEnvelopeName));
    expect(names, contains(wayfinderTideManifestName));
    expect(names, contains(wayfinderTideStationsName));

    await storage.deletePack(original.id);
    expect(await storage.loadPack(original.id), isNull);

    final imported = await importTidePackArchive(storage, bytes);
    expect(imported.id, original.id);
    expect(imported.name, original.name);
    expect(imported.stations, hasLength(1));
    expect(imported.stations.first.id, '1234567');
    expect(imported.stations.first.constituents.first.name, 'M2');
    expect(imported.isActive, isTrue);

    ArchiveFile? envelope;
    for (final file in archive.files) {
      if (file.name == wayfinderTideEnvelopeName) {
        envelope = file;
        break;
      }
    }
    expect(envelope, isNotNull);
    final envelopeJson =
        jsonDecode(
              utf8.decode(Uint8List.fromList(envelope!.content as List<int>)),
            )
            as Map<String, dynamic>;
    expect(envelopeJson['format'], wayfinderTideFormat);
  });
}
