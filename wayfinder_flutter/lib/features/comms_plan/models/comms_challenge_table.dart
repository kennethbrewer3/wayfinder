import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// One radio challenge / authentication matrix sheet.
///
/// Challenger picks a row letter and column digit (e.g. `B-7`); the station
/// replies with the digraph in that cell. Sheets are meant to be burned
/// (deleted) after use.
class CommsChallengeTable {
  const CommsChallengeTable({
    required this.id,
    required this.label,
    required this.version,
    required this.generatedAt,
    required this.rowLabels,
    required this.columnLabels,
    required this.cells,
    this.note,
  });

  static const currentVersion = 1;

  final String id;
  final String label;
  final int version;
  final DateTime generatedAt;
  final List<String> rowLabels;
  final List<String> columnLabels;

  /// [row][column] digraphs; dimensions match [rowLabels] × [columnLabels].
  final List<List<String>> cells;
  final String? note;

  int get rowCount => rowLabels.length;
  int get columnCount => columnLabels.length;

  String? cellAt({required String row, required String column}) {
    final r = rowLabels.indexOf(row);
    final c = columnLabels.indexOf(column);
    if (r < 0 || c < 0) {
      return null;
    }
    return cells[r][c];
  }

  CommsChallengeTable copyWith({
    String? id,
    String? label,
    Object? note = _unset,
  }) {
    return CommsChallengeTable(
      id: id ?? this.id,
      label: label ?? this.label,
      version: version,
      generatedAt: generatedAt,
      rowLabels: rowLabels,
      columnLabels: columnLabels,
      cells: cells,
      note: identical(note, _unset) ? this.note : note as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'version': version,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'rowLabels': rowLabels,
    'columnLabels': columnLabels,
    'cells': cells,
    if (note != null && note!.trim().isNotEmpty) 'note': note,
  };

  factory CommsChallengeTable.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rowLabels'];
    final rawCols = json['columnLabels'];
    final rawCells = json['cells'];
    final rowLabels = rawRows is List
        ? [for (final row in rawRows) row.toString()]
        : const <String>[];
    final columnLabels = rawCols is List
        ? [for (final col in rawCols) col.toString()]
        : const <String>[];
    final cells = <List<String>>[];
    if (rawCells is List) {
      for (final row in rawCells) {
        if (row is! List) {
          continue;
        }
        cells.add([for (final cell in row) cell.toString()]);
      }
    }
    final generatedRaw = json['generatedAt'] as String?;
    final id = (json['id'] as String?)?.trim();
    final label = (json['label'] as String?)?.trim();
    return CommsChallengeTable(
      id: (id == null || id.isEmpty) ? const Uuid().v4() : id,
      label: (label == null || label.isEmpty) ? 'Auth sheet' : label,
      version: (json['version'] as num?)?.toInt() ?? currentVersion,
      generatedAt: generatedRaw == null
          ? DateTime.now().toUtc()
          : DateTime.parse(generatedRaw).toUtc(),
      rowLabels: rowLabels,
      columnLabels: columnLabels,
      cells: cells,
      note: (json['note'] as String?)?.trim(),
    );
  }

  bool get isValid {
    if (rowCount == 0 || columnCount == 0 || cells.length != rowCount) {
      return false;
    }
    for (final row in cells) {
      if (row.length != columnCount) {
        return false;
      }
    }
    return true;
  }
}

const _unset = Object();

/// Decode the plan's `challengeTableJson` into zero or more sheets.
///
/// Supports the current list envelope and a legacy single-table object.
List<CommsChallengeTable> decodeCommsChallengeTables(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return [
        for (final entry in decoded)
          if (entry is Map<String, dynamic>)
            CommsChallengeTable.fromJson(entry),
      ].where((table) => table.isValid).toList();
    }
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['tables'];
      if (nested is List) {
        return [
          for (final entry in nested)
            if (entry is Map<String, dynamic>)
              CommsChallengeTable.fromJson(entry),
        ].where((table) => table.isValid).toList();
      }
      // Legacy single-table document.
      final table = CommsChallengeTable.fromJson(decoded);
      return table.isValid ? [table] : const [];
    }
    return const [];
  } catch (_) {
    return const [];
  }
}

/// Encode sheets for persistence on [CommsPlan.challengeTableJson].
String? encodeCommsChallengeTables(List<CommsChallengeTable> tables) {
  if (tables.isEmpty) {
    return null;
  }
  return jsonEncode({
    'version': 2,
    'tables': [for (final table in tables) table.toJson()],
  });
}

/// Alphabet used for digraph cells (excludes easily confused I/O/0/1).
const _digraphAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ';

/// Generates a fresh 10×10 digraph authentication matrix (rows A–J, cols 0–9).
///
/// Digraphs are drawn with [Random.secure] (platform CSPRNG: e.g. SecureRandom
/// / SecRandomCopyBytes / getrandom), not a seeded PRNG.
CommsChallengeTable generateCommsChallengeTable({
  DateTime? generatedAt,
  String? label,
  String? note,
  String? id,
}) {
  return _generateCommsChallengeTable(
    rng: Random.secure(),
    generatedAt: generatedAt,
    label: label,
    note: note,
    id: id,
  );
}

/// Test-only generator that accepts an injectable [Random] (may be seeded).
@visibleForTesting
CommsChallengeTable generateCommsChallengeTableForTest({
  required Random random,
  DateTime? generatedAt,
  String? label,
  String? note,
  String? id,
}) {
  return _generateCommsChallengeTable(
    rng: random,
    generatedAt: generatedAt,
    label: label,
    note: note,
    id: id,
  );
}

CommsChallengeTable _generateCommsChallengeTable({
  required Random rng,
  DateTime? generatedAt,
  String? label,
  String? note,
  String? id,
}) {
  const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  const cols = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final used = <String>{};
  final cells = <List<String>>[];
  for (var r = 0; r < rows.length; r++) {
    final row = <String>[];
    for (var c = 0; c < cols.length; c++) {
      row.add(_uniqueDigraph(rng, used));
    }
    cells.add(row);
  }
  return CommsChallengeTable(
    id: id ?? const Uuid().v4(),
    label: (label == null || label.trim().isEmpty)
        ? 'Auth sheet'
        : label.trim(),
    version: CommsChallengeTable.currentVersion,
    generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
    rowLabels: rows,
    columnLabels: cols,
    cells: cells,
    note: note,
  );
}

String nextChallengeTableLabel(List<CommsChallengeTable> existing) {
  return 'Auth sheet ${existing.length + 1}';
}

String _uniqueDigraph(Random rng, Set<String> used) {
  for (var attempt = 0; attempt < 500; attempt++) {
    final a = _digraphAlphabet[rng.nextInt(_digraphAlphabet.length)];
    final b = _digraphAlphabet[rng.nextInt(_digraphAlphabet.length)];
    final digraph = '$a$b';
    if (used.add(digraph)) {
      return digraph;
    }
  }
  // Extremely unlikely fallback if the set fills.
  return '${_digraphAlphabet[rng.nextInt(_digraphAlphabet.length)]}'
      '${used.length % 10}';
}
