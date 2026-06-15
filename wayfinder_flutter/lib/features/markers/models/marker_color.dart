import 'package:flutter/material.dart';

Color parseMarkerColor(String value) {
  final hex = value.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return const Color(0xFF1B4965);
}

String formatMarkerColorHex(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
