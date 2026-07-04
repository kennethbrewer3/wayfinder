import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';

import 'package:wayfinder_server/src/map/map_data_backup_archive.dart';
import 'package:wayfinder_server/src/markers/marker_icon_backup.dart';

void main() {
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
      Uint8List.fromList(ZipEncoder().encode(archive)!),
    );
    final restoredBundle =
        jsonDecode(jsonEncode(bundle)) as Map<String, dynamic>;

    mergeArchiveSvgFilesIntoBundle(decodedArchive, restoredBundle);

    final icons = restoredBundle['markerIcons'] as List;
    final icon = icons.single as Map<String, dynamic>;
    expect(icon[markerIconBackupSvgField], svg);
  });
}
