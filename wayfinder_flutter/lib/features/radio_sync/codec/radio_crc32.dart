import 'dart:typed_data';

/// IEEE CRC-32 (polynomial 0xEDB88320), as used by the radio-sync frame trailer.
int radioCrc32(Uint8List data, [int start = 0, int? end]) {
  final stop = end ?? data.length;
  var crc = 0xffffffff;
  for (var i = start; i < stop; i++) {
    crc ^= data[i];
    for (var bit = 0; bit < 8; bit++) {
      final mask = -(crc & 1);
      crc = (crc >> 1) ^ (0xedb88320 & mask);
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}
