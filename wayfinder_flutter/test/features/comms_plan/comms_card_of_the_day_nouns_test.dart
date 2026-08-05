import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/comms_plan/utils/comms_card_of_the_day_nouns.dart';

void main() {
  group('pickRandomCardOfTheDayNoun', () {
    test('avoids nouns already used on the card', () {
      const nouns = ['APPLE', 'BEAVER', 'CEDAR'];
      final picked = pickRandomCardOfTheDayNounForTest(
        usedOnCard: const ['apple', 'Beaver'],
        random: Random(1),
        nouns: nouns,
      );
      expect(picked, 'CEDAR');
    });

    test('returns null when the noun pool is exhausted', () {
      const nouns = ['APPLE', 'BEAVER'];
      final picked = pickRandomCardOfTheDayNounForTest(
        usedOnCard: nouns,
        random: Random(1),
        nouns: nouns,
      );
      expect(picked, isNull);
    });

    test('noun list has unique uppercase words', () {
      expect(cardOfTheDayNouns, isNotEmpty);
      final normalized = [
        for (final noun in cardOfTheDayNouns) noun.toUpperCase(),
      ];
      expect(normalized.toSet(), hasLength(normalized.length));
      for (final noun in normalized) {
        expect(noun, matches(RegExp(r'^[A-Z]+$')));
      }
    });
  });
}
