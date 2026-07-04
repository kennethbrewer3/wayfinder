import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';

import 'package:wayfinder_server/src/map/map_data_backup_archive.dart';
import 'package:wayfinder_server/src/markers/marker_icon_backup.dart';
import 'package:wayfinder_server/src/markers/marker_icon_storage.dart';

void main() {
  group('resolveMarkerIconSvgFilesForArchive', () {
    late Directory tempDir;
    late MarkerIconStorage storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('wayfinder-icon-backup-');
      MarkerIconStorage.configure(tempDir.path);
      storage = MarkerIconStorage();
      await storage.ensureReady();
    });

    tearDown(() async {
      MarkerIconStorage.configure('storage/marker-icons');
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('includes SVG files from disk for catalog icons', () async {
      const svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>';
      await storage.writeBytes(
        'ambulance',
        Uint8List.fromList(utf8.encode(svg)),
      );

      final resolved = await resolveMarkerIconSvgFilesForArchive(
        icons: [
          {
            'key': 'ambulance',
            'label': 'Ambulance',
            'hasCustomSvg': true,
          },
        ],
        storage: storage,
      );

      expect(resolved.keys, ['ambulance']);
      expect(utf8.decode(resolved['ambulance']!), svg);
    });

    test('falls back to inline svgContent when disk file is missing', () async {
      const svg = '<svg xmlns="http://www.w3.org/2000/svg"><circle/></svg>';

      final resolved = await resolveMarkerIconSvgFilesForArchive(
        icons: [
          {
            'key': 'ambulance',
            'label': 'Ambulance',
            'hasCustomSvg': true,
          },
        ],
        storage: storage,
        inlineSvgContentByKey: const {'ambulance': svg},
      );

      expect(resolved.keys, ['ambulance']);
      expect(utf8.decode(resolved['ambulance']!), svg);
    });

    test('includes orphan SVG files not listed in the catalog', () async {
      const svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>';
      await storage.writeBytes(
        'custom_unit',
        Uint8List.fromList(utf8.encode(svg)),
      );

      final resolved = await resolveMarkerIconSvgFilesForArchive(
        icons: const [],
        storage: storage,
      );

      expect(resolved.keys, ['custom_unit']);
      expect(utf8.decode(resolved['custom_unit']!), svg);
    });
  });

  test('zip archive merges marker-icons SVG files into backup JSON', () {
    const svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>';
    final bundle = {
      'version': 2,
      'markerIcons': [
        {
          'key': 'ambulance',
          'label': 'Ambulance',
          'hasCustomSvg': true,
        },
      ],
    };

    final archive = Archive()
      ..addFile(
        ArchiveFile(
          mapDataBackupArchiveJsonName,
          utf8.encode(jsonEncode(bundle)).length,
          utf8.encode(jsonEncode(bundle)),
        ),
      )
      ..addFile(
        ArchiveFile(
          '$mapDataBackupMarkerIconsDirectory/ambulance.svg',
          utf8.encode(svg).length,
          utf8.encode(svg),
        ),
      );

    final decodedArchive = ZipDecoder().decodeBytes(
      Uint8List.fromList(ZipEncoder().encode(archive)),
    );
    final restoredBundle =
        jsonDecode(jsonEncode(bundle)) as Map<String, dynamic>;

    mergeArchiveSvgFilesIntoBundle(decodedArchive, restoredBundle);

    final icons = restoredBundle['markerIcons'] as List;
    final icon = icons.single as Map<String, dynamic>;
    expect(icon[markerIconBackupSvgField], svg);
  });
}
