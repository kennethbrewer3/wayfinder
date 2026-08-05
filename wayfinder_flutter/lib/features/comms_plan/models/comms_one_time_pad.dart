import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// One cryptographic one-time pad sheet for field message encryption.
///
/// Layout is fixed: [rowCount] rows × [columnCount] groups of [groupLength]
/// letters (A–Z). Pads are meant to be burned (deleted) after use.
class CommsOneTimePad {
  const CommsOneTimePad({
    required this.id,
    required this.label,
    required this.version,
    required this.generatedAt,
    required this.groups,
    this.note,
  });

  static const currentVersion = 1;
  static const rowCount = 29;
  static const columnCount = 4;
  static const groupLength = 5;

  final String id;
  final String label;
  final int version;
  final DateTime generatedAt;

  /// [row][column] five-letter groups; always [rowCount] × [columnCount].
  final List<List<String>> groups;
  final String? note;

  CommsOneTimePad copyWith({
    String? id,
    String? label,
    Object? note = _unset,
  }) {
    return CommsOneTimePad(
      id: id ?? this.id,
      label: label ?? this.label,
      version: version,
      generatedAt: generatedAt,
      groups: groups,
      note: identical(note, _unset) ? this.note : note as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'version': version,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'rowCount': rowCount,
    'columnCount': columnCount,
    'groupLength': groupLength,
    'groups': groups,
    if (note != null && note!.trim().isNotEmpty) 'note': note,
  };

  factory CommsOneTimePad.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groups'];
    final groups = <List<String>>[];
    if (rawGroups is List) {
      for (final row in rawGroups) {
        if (row is! List) {
          continue;
        }
        groups.add([for (final cell in row) cell.toString()]);
      }
    }
    final generatedRaw = json['generatedAt'] as String?;
    final id = (json['id'] as String?)?.trim();
    final label = (json['label'] as String?)?.trim();
    return CommsOneTimePad(
      id: (id == null || id.isEmpty) ? const Uuid().v4() : id,
      label: (label == null || label.isEmpty) ? 'OTP pad' : label,
      version: (json['version'] as num?)?.toInt() ?? currentVersion,
      generatedAt: generatedRaw == null
          ? DateTime.now().toUtc()
          : DateTime.parse(generatedRaw).toUtc(),
      groups: groups,
      note: (json['note'] as String?)?.trim(),
    );
  }

  bool get isValid {
    if (groups.length != rowCount) {
      return false;
    }
    for (final row in groups) {
      if (row.length != columnCount) {
        return false;
      }
      for (final group in row) {
        if (group.length != groupLength || !_groupPattern.hasMatch(group)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Flat character stream in row-major order (580 letters).
  String get flatKey => groups.expand((row) => row).join();
}

final _groupPattern = RegExp(r'^[A-Z]{5}$');
const _unset = Object();

/// Decode the plan's `oneTimePadJson` into zero or more pads.
List<CommsOneTimePad> decodeCommsOneTimePads(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return [
        for (final entry in decoded)
          if (entry is Map<String, dynamic>) CommsOneTimePad.fromJson(entry),
      ].where((pad) => pad.isValid).toList();
    }
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['pads'];
      if (nested is List) {
        return [
          for (final entry in nested)
            if (entry is Map<String, dynamic>) CommsOneTimePad.fromJson(entry),
        ].where((pad) => pad.isValid).toList();
      }
      final pad = CommsOneTimePad.fromJson(decoded);
      return pad.isValid ? [pad] : const [];
    }
    return const [];
  } catch (_) {
    return const [];
  }
}

/// Encode pads for persistence on [CommsPlan.oneTimePadJson].
String? encodeCommsOneTimePads(List<CommsOneTimePad> pads) {
  if (pads.isEmpty) {
    return null;
  }
  return jsonEncode({
    'version': 1,
    'pads': [for (final pad in pads) pad.toJson()],
  });
}

/// Alphabet for pad groups (classic A–Z Vernam key material).
const _padAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// Generates a fresh 29×4 pad of five-letter groups.
///
/// Characters are drawn with [Random.secure] (platform CSPRNG).
CommsOneTimePad generateCommsOneTimePad({
  DateTime? generatedAt,
  String? label,
  String? note,
  String? id,
}) {
  return _generateCommsOneTimePad(
    rng: Random.secure(),
    generatedAt: generatedAt,
    label: label,
    note: note,
    id: id,
  );
}

/// Test-only generator that accepts an injectable [Random] (may be seeded).
@visibleForTesting
CommsOneTimePad generateCommsOneTimePadForTest({
  required Random random,
  DateTime? generatedAt,
  String? label,
  String? note,
  String? id,
}) {
  return _generateCommsOneTimePad(
    rng: random,
    generatedAt: generatedAt,
    label: label,
    note: note,
    id: id,
  );
}

CommsOneTimePad _generateCommsOneTimePad({
  required Random rng,
  DateTime? generatedAt,
  String? label,
  String? note,
  String? id,
}) {
  final groups = <List<String>>[];
  for (var r = 0; r < CommsOneTimePad.rowCount; r++) {
    final row = <String>[];
    for (var c = 0; c < CommsOneTimePad.columnCount; c++) {
      final buffer = StringBuffer();
      for (var i = 0; i < CommsOneTimePad.groupLength; i++) {
        buffer.write(_padAlphabet[rng.nextInt(_padAlphabet.length)]);
      }
      row.add(buffer.toString());
    }
    groups.add(row);
  }
  return CommsOneTimePad(
    id: id ?? const Uuid().v4(),
    label: (label == null || label.trim().isEmpty) ? 'OTP pad' : label.trim(),
    version: CommsOneTimePad.currentVersion,
    generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
    groups: groups,
    note: note,
  );
}

String nextOneTimePadLabel(List<CommsOneTimePad> existing) {
  return 'OTP pad ${existing.length + 1}';
}
