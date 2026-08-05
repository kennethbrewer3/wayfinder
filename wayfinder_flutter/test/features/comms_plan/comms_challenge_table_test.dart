import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/comms_plan/models/comms_challenge_table.dart';

void main() {
  group('CommsChallengeTable', () {
    test('generates a unique 10x10 digraph matrix', () {
      final table = generateCommsChallengeTableForTest(
        random: Random(42),
        label: 'Auth sheet 1',
      );
      expect(table.rowCount, 10);
      expect(table.columnCount, 10);
      expect(table.label, 'Auth sheet 1');
      expect(table.id, isNotEmpty);
      expect(table.rowLabels, [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
      ]);
      final digraphs = <String>{};
      for (final row in table.cells) {
        expect(row, hasLength(10));
        for (final cell in row) {
          expect(cell, matches(RegExp(r'^[A-Z]{2}$')));
          expect(digraphs.add(cell), isTrue, reason: 'duplicate $cell');
        }
      }
      expect(table.cellAt(row: 'B', column: '7'), isNotNull);
    });

    test('round-trips a list of sheets', () {
      final tables = [
        generateCommsChallengeTableForTest(
          random: Random(1),
          label: 'Auth sheet 1',
        ),
        generateCommsChallengeTableForTest(
          random: Random(2),
          label: 'Auth sheet 2',
        ),
      ];
      final decoded = decodeCommsChallengeTables(
        encodeCommsChallengeTables(tables),
      );
      expect(decoded, hasLength(2));
      expect(decoded[0].label, 'Auth sheet 1');
      expect(decoded[1].label, 'Auth sheet 2');
      expect(decoded[0].cells, tables[0].cells);
      expect(decoded[1].id, tables[1].id);
    });

    test('decodes legacy single-table JSON', () {
      final legacy = generateCommsChallengeTableForTest(random: Random(3));
      final bareJson = jsonEncode({
        'version': 1,
        'generatedAt': legacy.generatedAt.toIso8601String(),
        'rowLabels': legacy.rowLabels,
        'columnLabels': legacy.columnLabels,
        'cells': legacy.cells,
      });
      final decoded = decodeCommsChallengeTables(bareJson);
      expect(decoded, hasLength(1));
      expect(decoded.single.cells, legacy.cells);
      expect(encodeCommsChallengeTables(decoded), contains('"tables"'));
    });

    test('nextChallengeTableLabel increments', () {
      expect(nextChallengeTableLabel(const []), 'Auth sheet 1');
      expect(
        nextChallengeTableLabel([
          generateCommsChallengeTableForTest(random: Random(1)),
        ]),
        'Auth sheet 2',
      );
    });

    test('encode empty list clears storage', () {
      expect(encodeCommsChallengeTables(const []), isNull);
    });
  });
}
