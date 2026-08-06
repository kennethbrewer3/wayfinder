import 'dart:convert';
import 'dart:typed_data';

import 'radio_uuid_bytes.dart';

/// Big-endian writer for radio-sync payloads.
class RadioBinaryWriter {
  RadioBinaryWriter([int initialCapacity = 64])
    : _buffer = BytesBuilder(copy: false);

  final BytesBuilder _buffer;

  void u8(int value) => _buffer.addByte(value & 0xff);

  void u16(int value) {
    _buffer.addByte((value >> 8) & 0xff);
    _buffer.addByte(value & 0xff);
  }

  void u32(int value) {
    _buffer.addByte((value >> 24) & 0xff);
    _buffer.addByte((value >> 16) & 0xff);
    _buffer.addByte((value >> 8) & 0xff);
    _buffer.addByte(value & 0xff);
  }

  void i16(int value) => u16(value & 0xffff);

  void i32(int value) => u32(value & 0xffffffff);

  void bytes(Uint8List data) => _buffer.add(data);

  void uuid(String id) => bytes(uuidStringToBytes(id));

  /// Length-prefixed UTF-8 string (`uint8` length). Truncates to [maxChars].
  /// Returns whether truncation occurred.
  bool utf8u8(String value, {required int maxChars}) {
    var truncated = false;
    var text = value;
    if (text.length > maxChars) {
      text = text.substring(0, maxChars);
      truncated = true;
    }
    final encoded = utf8.encode(text);
    if (encoded.length > 255) {
      throw ArgumentError('UTF-8 payload exceeds uint8 length');
    }
    u8(encoded.length);
    _buffer.add(encoded);
    return truncated;
  }

  Uint8List toBytes() => _buffer.toBytes();
}

/// Big-endian reader for radio-sync payloads.
class RadioBinaryReader {
  RadioBinaryReader(this.data, [this.offset = 0]);

  final Uint8List data;
  int offset;

  int get remaining => data.length - offset;

  void _need(int n) {
    if (remaining < n) {
      throw FormatException(
        'Radio payload truncated (need $n, have $remaining)',
      );
    }
  }

  int u8() {
    _need(1);
    return data[offset++];
  }

  int u16() {
    _need(2);
    final value = (data[offset] << 8) | data[offset + 1];
    offset += 2;
    return value;
  }

  int u32() {
    _need(4);
    final value =
        (data[offset] << 24) |
        (data[offset + 1] << 16) |
        (data[offset + 2] << 8) |
        data[offset + 3];
    offset += 4;
    return value & 0xffffffff;
  }

  int i16() {
    final value = u16();
    return value >= 0x8000 ? value - 0x10000 : value;
  }

  int i32() {
    final value = u32();
    return value >= 0x80000000 ? value - 0x100000000 : value;
  }

  Uint8List bytes(int length) {
    _need(length);
    final slice = Uint8List.sublistView(data, offset, offset + length);
    offset += length;
    return Uint8List.fromList(slice);
  }

  String uuid() => uuidBytesToString(bytes(16));

  String utf8u8() {
    final length = u8();
    if (length == 0) {
      return '';
    }
    return utf8.decode(bytes(length));
  }
}
