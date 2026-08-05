import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/comms_plan/models/comms_one_time_pad.dart';

void main() {
  group('CommsOneTimePad', () {
    test('generates 29x4 groups of five letters', () {
      final pad = generateCommsOneTimePadForTest(
        random: Random(42),
        label: 'OTP pad 1',
      );
      expect(pad.groups, hasLength(29));
      expect(pad.label, 'OTP pad 1');
      expect(pad.id, isNotEmpty);
      expect(pad.flatKey, hasLength(29 * 4 * 5));
      for (final row in pad.groups) {
        expect(row, hasLength(4));
        for (final group in row) {
          expect(group, matches(RegExp(r'^[A-Z]{5}$')));
        }
      }
      expect(pad.isValid, isTrue);
    });

    test('round-trips a list of pads', () {
      final pads = [
        generateCommsOneTimePadForTest(
          random: Random(1),
          label: 'OTP pad 1',
        ),
        generateCommsOneTimePadForTest(
          random: Random(2),
          label: 'OTP pad 2',
        ),
      ];
      final decoded = decodeCommsOneTimePads(encodeCommsOneTimePads(pads));
      expect(decoded, hasLength(2));
      expect(decoded[0].label, 'OTP pad 1');
      expect(decoded[1].label, 'OTP pad 2');
      expect(decoded[0].groups, pads[0].groups);
      expect(decoded[1].id, pads[1].id);
    });

    test('nextOneTimePadLabel increments', () {
      expect(nextOneTimePadLabel(const []), 'OTP pad 1');
      expect(
        nextOneTimePadLabel([
          generateCommsOneTimePadForTest(random: Random(1)),
        ]),
        'OTP pad 2',
      );
    });

    test('encode empty list clears storage', () {
      expect(encodeCommsOneTimePads(const []), isNull);
    });
  });
}
