import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_radio.dart';

void main() {
  group('MarkerRadioContact', () {
    test('round-trips through JSON storage', () {
      const contact = MarkerRadioContact(
        callsign: 'w1aw',
        frequencyMHz: 146.52,
        mode: MarkerRadioMode.fm,
        toneHz: 100,
        offsetMHz: -0.6,
        role: MarkerRadioRole.repeater,
        netName: 'County ARES',
        notes: 'Mon 20:00',
      );

      final restored = MarkerRadioContact.fromMarkerRadioJson(
        contact.toStorageJson(),
      );

      expect(restored.callsign, 'W1AW');
      expect(restored.frequencyMHz, 146.52);
      expect(restored.mode, MarkerRadioMode.fm);
      expect(restored.toneHz, 100);
      expect(restored.offsetMHz, -0.6);
      expect(restored.role, MarkerRadioRole.repeater);
      expect(restored.netName, 'County ARES');
      expect(restored.notes, 'Mon 20:00');
    });

    test('empty contact serializes to null', () {
      expect(const MarkerRadioContact().toStorageJson(), isNull);
      expect(
        MarkerRadioContact.fromMarkerRadioJson(null).isEmpty,
        isTrue,
      );
    });

    test('role alone does not persist', () {
      expect(
        const MarkerRadioContact(
          role: MarkerRadioRole.shack,
        ).toStorageJson(),
        isNull,
      );
    });
  });

  group('radio helpers', () {
    test('recognizes ham/repeater icons', () {
      expect(isRadioContactMarkerIcon('ham_shack'), isTrue);
      expect(isRadioContactMarkerIcon('radio_repeater'), isTrue);
      expect(isRadioContactMarkerIcon('radio_station'), isTrue);
      expect(isRadioContactMarkerIcon('mesh_network_node'), isTrue);
      expect(isRadioContactMarkerIcon('cache'), isFalse);
    });

    test('formats frequency without trailing zeros', () {
      expect(formatRadioFrequencyMHz(146.52), '146.52');
      expect(formatRadioFrequencyMHz(14.0), '14');
      expect(formatRadioFrequencyMHz(null), '');
    });
  });
}
