import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/comms_plan/models/comms_plan_channel.dart';
import 'package:wayfinder_flutter/features/comms_plan/models/comms_radio_service.dart';
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
        radioService: CommsRadioService.ham,
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
      expect(roundTrip.radioService, CommsRadioService.ham);
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

    test('round-trips GMRS permitted channel', () {
      const channel = CommsPlanChannel(
        id: 'gmrs-1',
        label: 'Neighborhood',
        radioService: CommsRadioService.gmrs,
        serviceChannelId: '20',
        frequencyMHz: 462.675,
        mode: MarkerRadioMode.fm,
      );
      final decoded = decodeCommsPlanChannels(
        encodeCommsPlanChannels([channel]),
      ).single;
      expect(decoded.radioService, CommsRadioService.gmrs);
      expect(decoded.serviceChannelId, '20');
      expect(decoded.frequencyMHz, 462.675);
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

  group('permitted channels', () {
    test('FRS has 22 channels and no repeater pairs', () {
      expect(frsPermittedChannels, hasLength(22));
      expect(frsPermittedChannels.any((c) => c.isRepeater), isFalse);
      expect(findPermittedChannel(CommsRadioService.frs, '23'), isNull);
    });

    test('GMRS includes repeater pairs 15R-22R', () {
      expect(gmrsPermittedChannels, hasLength(30));
      final repeater = findPermittedChannel(CommsRadioService.gmrs, '15R');
      expect(repeater, isNotNull);
      expect(repeater!.isRepeater, isTrue);
      expect(repeater.defaultOffsetMHz, 5.0);
      expect(findPermittedChannel(CommsRadioService.frs, '15R'), isNull);
    });

    test('CB has 40 channels defaulting to AM', () {
      expect(cbPermittedChannels, hasLength(40));
      expect(
        findPermittedChannel(CommsRadioService.cb, '9')?.frequencyMHz,
        27.065,
      );
      expect(
        findPermittedChannel(CommsRadioService.cb, '19')?.defaultMode,
        MarkerRadioMode.am,
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
