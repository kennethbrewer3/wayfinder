import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/seasonal_overlays/models/seasonal_date_window.dart';

void main() {
  group('absolute windows', () {
    test('contains inclusive date range', () {
      final window = SeasonalDateWindow.absolute(
        startDate: DateTime(2026, 11, 15),
        endDate: DateTime(2026, 12, 7),
      );
      expect(window.contains(DateTime(2026, 11, 15)), isTrue);
      expect(window.contains(DateTime(2026, 12, 1)), isTrue);
      expect(window.contains(DateTime(2026, 12, 7)), isTrue);
      expect(window.contains(DateTime(2026, 11, 14)), isFalse);
      expect(window.contains(DateTime(2026, 12, 8)), isFalse);
    });
  });

  group('recurring windows', () {
    test('handles same-year ranges', () {
      const window = SeasonalDateWindow.recurring(
        startMonth: 6,
        startDay: 1,
        endMonth: 8,
        endDay: 31,
      );
      expect(window.contains(DateTime(2026, 7, 4)), isTrue);
      expect(window.contains(DateTime(2026, 5, 31)), isFalse);
    });

    test('handles year-wrapping ranges', () {
      const window = SeasonalDateWindow.recurring(
        startMonth: 11,
        startDay: 15,
        endMonth: 1,
        endDay: 15,
      );
      expect(window.contains(DateTime(2026, 12, 1)), isTrue);
      expect(window.contains(DateTime(2026, 1, 10)), isTrue);
      expect(window.contains(DateTime(2026, 2, 1)), isFalse);
      expect(window.contains(DateTime(2026, 10, 1)), isFalse);
    });
  });

  test('schedule encodes and parses absolute windows', () {
    final schedule = SeasonalSchedule(
      dateMode: seasonalDateModeAbsolute,
      windows: [
        SeasonalDateWindow.absolute(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        ),
      ],
    );
    final parsed = SeasonalSchedule.parse(
      dateMode: seasonalDateModeAbsolute,
      dateWindowsJson: schedule.encode(),
    );
    expect(parsed.windows, hasLength(1));
    expect(parsed.isActiveOn(DateTime(2026, 1, 15)), isTrue);
    expect(parsed.isActiveOn(DateTime(2026, 2, 1)), isFalse);
  });
}
