import 'dart:typed_data';

/// Encode a UUID string (`8-4-4-4-12` or 32 hex chars) as 16 raw bytes.
Uint8List uuidStringToBytes(String raw) {
  final hex = raw.replaceAll('-', '').trim().toLowerCase();
  if (hex.length != 32 || !RegExp(r'^[0-9a-f]{32}$').hasMatch(hex)) {
    throw FormatException('Expected UUID, got "$raw"');
  }
  final out = Uint8List(16);
  for (var i = 0; i < 16; i++) {
    out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

/// Decode 16 raw bytes to a canonical lowercase UUID string.
String uuidBytesToString(Uint8List bytes, [int offset = 0]) {
  if (bytes.length < offset + 16) {
    throw FormatException('UUID bytes truncated');
  }
  final hex = StringBuffer();
  for (var i = 0; i < 16; i++) {
    hex.write(bytes[offset + i].toRadixString(16).padLeft(2, '0'));
  }
  final s = hex.toString();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-'
      '${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}
