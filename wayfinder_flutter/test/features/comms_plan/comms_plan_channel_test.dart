import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/comms_plan/models/comms_plan_channel.dart';
import 'package:wayfinder_flutter/features/comms_plan/utils/comms_plan_schedule.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_radio.dart';

void main() {
  group('CommsPlanChannel JSON', () {
    test('round-trips channel fields', () {
      const channel = CommsPlanChannel(
        id: 'ch-1',
        label: 'Primary VHF',
        netName: 'Ops Net',
        role: CommsChannelRole.primary,
        frequencyMHz: 146.52,
        mode: MarkerRadioMode.fm,
        toneHz: 123.0,
        callsign: 'W1AW',
        daysOfWeek: [1, 3, 5],
        startLocalTime: '19:00',
        durationMinutes: 30,
        availability: CommsChannelAvailability.go,
        statusNote: 'Clear',
        markerId: 'marker-1',
        notes: 'Simplex',
      );

      final encoded = encodeCommsPlanChannels([channel]);
      final decoded = decodeCommsPlanChannels(encoded);
      expect(decoded, hasLength(1));
      final roundTrip = decoded.single;
      expect(roundTrip.id, 'ch-1');
      expect(roundTrip.label, 'Primary VHF');
      expect(roundTrip.netName, 'Ops Net');
      expect(roundTrip.role, CommsChannelRole.primary);
      expect(roundTrip.frequencyMHz, 146.52);
      expect(roundTrip.mode, MarkerRadioMode.fm);
      expect(roundTrip.toneHz, 123.0);
      expect(roundTrip.callsign, 'W1AW');
      expect(roundTrip.daysOfWeek, [1, 3, 5]);
      expect(roundTrip.startLocalTime, '19:00');
      expect(roundTrip.durationMinutes, 30);
      expect(roundTrip.availability, CommsChannelAvailability.go);
      expect(roundTrip.statusNote, 'Clear');
      expect(roundTrip.markerId, 'marker-1');
      expect(roundTrip.notes, 'Simplex');
    });

    test('parses availability aliases', () {
      expect(
        CommsChannelAvailability.parse('no-go'),
        CommsChannelAvailability.noGo,
      );
      expect(
        CommsChannelAvailability.parse('amber'),
        CommsChannelAvailability.conditional,
      );
    });
  });

  group('nextNetStartUtc', () {
    test('finds next weekday occurrence in plan timezone', () {
      // Wednesday 2026-07-22 12:00 UTC = 08:00 America/New_York (EDT).
      final nowUtc = DateTime.utc(2026, 7, 22, 12);
      const channel = CommsPlanChannel(
        id: 'ch',
        label: 'Evening net',
        daysOfWeek: [3], // Wednesday
        startLocalTime: '19:00',
      );

      final next = nextNetStartUtc(
        channel,
        timezoneIana: 'America/New_York',
        nowUtc: nowUtc,
      );
      expect(next, isNotNull);
      // 19:00 EDT = 23:00 UTC same day.
      expect(next, DateTime.utc(2026, 7, 22, 23));
    });

    test('returns null when unscheduled', () {
      const channel = CommsPlanChannel(id: 'ch', label: 'Ad hoc');
      expect(
        nextNetStartUtc(channel, timezoneIana: 'UTC'),
        isNull,
      );
    });
  });
}
