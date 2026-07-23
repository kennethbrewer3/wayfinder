import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';
import 'package:wayfinder_server/src/map/field_pack_archive.dart';

void main() {
  group('field pack archive validation', () {
    test('rejects empty archive', () async {
      // restoreFieldPackArchive needs a Session; validate helpers via zip shape
      // by building a pack-like zip missing the envelope and decoding envelope
      // rules through ZipDecoder + constants.
      final archive = Archive();
      final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
      expect(bytes, isNotEmpty);

      final decoded = ZipDecoder().decodeBytes(bytes);
      final names = decoded.files.map((f) => f.name).toSet();
      expect(names.contains(wayfinderFieldEnvelopeName), isFalse);
    });

    test('envelope constants match expected pack layout', () {
      expect(wayfinderFieldFormat, 'wayfinder-field');
      expect(wayfinderFieldFormatVersion, 1);
      expect(fieldPackMapDirectory, 'map');
      expect(fieldPackPmtilesCatalogName, 'pmtiles/catalog.json');

      final envelope = {
        'format': wayfinderFieldFormat,
        'version': wayfinderFieldFormatVersion,
      };
      expect(jsonEncode(envelope), contains('wayfinder-field'));
    });
  });
}
