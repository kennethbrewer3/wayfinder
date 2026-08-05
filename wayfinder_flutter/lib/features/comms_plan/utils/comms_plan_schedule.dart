import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/comms_plan_channel.dart';

bool _timeZonesReady = false;

void ensureCommsPlanTimeZonesInitialized() {
  if (_timeZonesReady) {
    return;
  }
  tzdata.initializeTimeZones();
  _timeZonesReady = true;
}

tz.Location? locationForCommsTimezone(String? iana) {
  ensureCommsPlanTimeZonesInitialized();
  final name = (iana == null || iana.trim().isEmpty) ? 'UTC' : iana.trim();
  try {
    return tz.getLocation(name);
  } catch (_) {
    try {
      return tz.getLocation('UTC');
    } catch (_) {
      return null;
    }
  }
}

(int hour, int minute)? parseLocalHhMm(String? raw) {
  if (raw == null) {
    return null;
  }
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw.trim());
  if (match == null) {
    return null;
  }
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null) {
    return null;
  }
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }
  return (hour, minute);
}

/// Next scheduled start for [channel] in [timezoneIana], or null if unscheduled.
DateTime? nextNetStartUtc(
  CommsPlanChannel channel, {
  required String timezoneIana,
  DateTime? nowUtc,
}) {
  final parsed = parseLocalHhMm(channel.startLocalTime);
  if (parsed == null) {
    return null;
  }
  final location = locationForCommsTimezone(timezoneIana);
  if (location == null) {
    return null;
  }

  final now = tz.TZDateTime.from(nowUtc ?? DateTime.now().toUtc(), location);
  final days =
      channel.daysOfWeek.isEmpty
            ? const [1, 2, 3, 4, 5, 6, 7]
            : {...channel.daysOfWeek}.toList()
        ..sort();

  for (var offset = 0; offset < 14; offset++) {
    final day = now.add(Duration(days: offset));
    final weekday = day.weekday; // 1=Mon … 7=Sun
    if (!days.contains(weekday)) {
      continue;
    }
    final candidate = tz.TZDateTime(
      location,
      day.year,
      day.month,
      day.day,
      parsed.$1,
      parsed.$2,
    );
    if (candidate.isAfter(now) || candidate.isAtSameMomentAs(now)) {
      return candidate.toUtc();
    }
  }
  return null;
}

/// Channels sorted by soonest upcoming net (unscheduled last).
List<CommsPlanChannel> channelsByNextNet(
  List<CommsPlanChannel> channels, {
  required String timezoneIana,
  DateTime? nowUtc,
}) {
  final ranked = [...channels];
  ranked.sort((a, b) {
    final aNext = nextNetStartUtc(
      a,
      timezoneIana: timezoneIana,
      nowUtc: nowUtc,
    );
    final bNext = nextNetStartUtc(
      b,
      timezoneIana: timezoneIana,
      nowUtc: nowUtc,
    );
    if (aNext == null && bNext == null) {
      return a.label.compareTo(b.label);
    }
    if (aNext == null) {
      return 1;
    }
    if (bNext == null) {
      return -1;
    }
    final byTime = aNext.compareTo(bNext);
    if (byTime != 0) {
      return byTime;
    }
    return a.label.compareTo(b.label);
  });
  return ranked;
}
