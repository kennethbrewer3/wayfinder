import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/comms_plan/models/comms_card_of_the_day.dart';

void main() {
  group('CommsCardOfTheDay', () {
    test('normalizes and validates digit keys', () {
      expect(isValidDigitKey('BLACKHORSE'), isTrue);
      expect(isValidDigitKey('black horse'), isTrue);
      expect(normalizeDigitKeyLetters('black horse'), 'BLACKHORSE');
      expect(isValidDigitKey('AAAAABBBBB'), isFalse);
      expect(isValidDigitKey('SHORT'), isFalse);
      expect(isValidDigitKey('TOOLONGWORDX'), isFalse);
    });

    test('generateDigitKeyForTest has 10 unique letters', () {
      final key = generateDigitKeyForTest(random: Random(42));
      expect(key, hasLength(10));
      expect(key.split('').toSet(), hasLength(10));
      expect(isValidDigitKey(key), isTrue);
    });

    test('round-trips a list of cards', () {
      final cards = [
        createCommsCardOfTheDay(
          label: 'Card of the day 1',
          date: DateTime.utc(2026, 8, 5),
          digitKey: 'BLACKHORSE',
        ).copyWith(
          places: const [
            CommsCardOfTheDayEntry(item: 'LZ Alpha', codeWord: 'THUNDER'),
          ],
          people: const [
            CommsCardOfTheDayEntry(item: 'Medic', codeWord: 'NEEDLE'),
          ],
        ),
        createCommsCardOfTheDay(
          label: 'Card of the day 2',
          date: DateTime.utc(2026, 8, 6),
        ),
      ];
      final decoded = decodeCommsCardsOfTheDay(encodeCommsCardsOfTheDay(cards));
      expect(decoded, hasLength(2));
      expect(decoded[0].digitKey, 'BLACKHORSE');
      expect(decoded[0].places.single.codeWord, 'THUNDER');
      expect(decoded[0].date, DateTime.utc(2026, 8, 5));
      expect(decoded[1].label, 'Card of the day 2');
      expect(decoded[0].letterForDigit(0), 'B');
      expect(decoded[0].letterForDigit(9), 'E');
    });

    test('encode empty list clears storage', () {
      expect(encodeCommsCardsOfTheDay(const []), isNull);
    });

    test('nextCardOfTheDayLabel increments', () {
      expect(nextCardOfTheDayLabel(const []), 'Card of the day 1');
      expect(
        nextCardOfTheDayLabel([createCommsCardOfTheDay()]),
        'Card of the day 2',
      );
    });

    test('dateOnly keeps local calendar day and display does not shift', () {
      final localEvening = DateTime(2026, 8, 5, 20, 30);
      final stored = dateOnly(localEvening);
      expect(stored, DateTime.utc(2026, 8, 5));
      expect(cardOfTheDayDisplayDate(stored), DateTime(2026, 8, 5));
      expect(dateOnlyIso(stored), '2026-08-05');

      // Stored civil UTC midnight must not move when formatted for display.
      final fromIso = parseDateOnly('2026-08-05')!;
      expect(
        cardOfTheDayDisplayDate(fromIso).day,
        5,
      );
      expect(dateOnlyIso(fromIso), '2026-08-05');
    });
  });
}
