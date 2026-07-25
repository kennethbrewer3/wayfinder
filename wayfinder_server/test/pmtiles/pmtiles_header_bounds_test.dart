import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:wayfinder_server/src/pmtiles/pmtiles_header_bounds.dart';

Uint8List _header({
  required int minZoom,
  required int maxZoom,
  required double minLon,
  required double minLat,
  required double maxLon,
  required double maxLat,
  int version = 3,
  String magic = 'PMTiles',
}) {
  final bytes = Uint8List(127);
  final magicBytes = magic.codeUnits;
  for (var i = 0; i < magicBytes.length && i < 7; i++) {
    bytes[i] = magicBytes[i];
  }
  bytes[0x07] = version;
  bytes[0x64] = minZoom;
  bytes[0x65] = maxZoom;
  final data = ByteData.sublistView(bytes);
  data.setInt32(0x66, (minLon * 1e7).round(), Endian.little);
  data.setInt32(0x6A, (minLat * 1e7).round(), Endian.little);
  data.setInt32(0x6E, (maxLon * 1e7).round(), Endian.little);
  data.setInt32(0x72, (maxLat * 1e7).round(), Endian.little);
  return bytes;
}

void main() {
  group('PmtilesHeaderBounds.fromBytes', () {
    test('parses v3 header coordinates and zooms', () {
      final bounds = PmtilesHeaderBounds.fromBytes(
        _header(
          minZoom: 4,
          maxZoom: 14,
          minLon: -106.7,
          minLat: 35.0,
          maxLon: -106.4,
          maxLat: 35.2,
        ),
      );
      expect(bounds.minZoom, 4);
      expect(bounds.maxZoom, 14);
      expect(bounds.minLongitude, closeTo(-106.7, 1e-6));
      expect(bounds.minLatitude, closeTo(35.0, 1e-6));
      expect(bounds.maxLongitude, closeTo(-106.4, 1e-6));
      expect(bounds.maxLatitude, closeTo(35.2, 1e-6));
    });

    test('rejects short buffers', () {
      expect(
        () => PmtilesHeaderBounds.fromBytes(Uint8List(10)),
        throwsFormatException,
      );
    });

    test('rejects bad magic and version', () {
      expect(
        () => PmtilesHeaderBounds.fromBytes(
          _header(
            minZoom: 0,
            maxZoom: 1,
            minLon: 0,
            minLat: 0,
            maxLon: 1,
            maxLat: 1,
            magic: 'XXXXXXX',
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => PmtilesHeaderBounds.fromBytes(
          _header(
            minZoom: 0,
            maxZoom: 1,
            minLon: 0,
            minLat: 0,
            maxLon: 1,
            maxLat: 1,
            version: 2,
          ),
        ),
        throwsFormatException,
      );
    });
  });
}
