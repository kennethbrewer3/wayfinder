import 'dart:io';
import 'dart:typed_data';

/// Parsed geographic bounds from a PMTiles v3 header (first 127 bytes).
class PmtilesHeaderBounds {
  const PmtilesHeaderBounds({
    required this.minZoom,
    required this.maxZoom,
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
  });

  final int minZoom;
  final int maxZoom;
  final double minLatitude;
  final double minLongitude;
  final double maxLatitude;
  final double maxLongitude;

  /// Reads bounds from the start of a `.pmtiles` file on disk.
  static Future<PmtilesHeaderBounds> readFromFile(File file) async {
    final raf = await file.open();
    try {
      final bytes = await raf.read(127);
      return fromBytes(bytes, source: file.path);
    } finally {
      await raf.close();
    }
  }

  static PmtilesHeaderBounds fromBytes(List<int> bytes, {String? source}) {
    if (bytes.length < 127) {
      throw FormatException(
        'PMTiles header too short${source == null ? '' : ' in $source'}',
      );
    }

    final magic = String.fromCharCodes(bytes.sublist(0, 7));
    if (magic != 'PMTiles') {
      throw FormatException(
        'Invalid PMTiles magic${source == null ? '' : ' in $source'}: "$magic"',
      );
    }

    final version = bytes[0x07];
    if (version != 3) {
      throw FormatException(
        'Unsupported PMTiles version $version${source == null ? '' : ' in $source'}',
      );
    }

    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    return PmtilesHeaderBounds(
      minZoom: bytes[0x64],
      maxZoom: bytes[0x65],
      minLongitude: _readFixedCoordinate(data, 0x66),
      minLatitude: _readFixedCoordinate(data, 0x6A),
      maxLongitude: _readFixedCoordinate(data, 0x6E),
      maxLatitude: _readFixedCoordinate(data, 0x72),
    );
  }

  static double _readFixedCoordinate(ByteData data, int offset) {
    return data.getInt32(offset, Endian.little) / 10000000.0;
  }
}
