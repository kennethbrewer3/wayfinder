import 'package:timezone/timezone.dart' as tz;

import '../../sun_moon/models/sun_moon_timezone.dart';
import 'comms_plan_schedule.dart';

/// Common civil zones shown first in the comms-plan timezone picker.
List<String> get _preferredCommsTimezones => [
  for (final zone in sunMoonNamedZones) zone.ianaName,
];

/// Sorted IANA timezone names for the plan editor dropdown.
///
/// Preferred zones are listed first; the rest follow alphabetically.
/// [current] is included even when it is not in the timezone database.
List<String> commsPlanTimezoneOptions({String? current}) {
  ensureCommsPlanTimeZonesInitialized();

  final all = tz.timeZoneDatabase.locations.keys.toList()..sort();
  final preferred = <String>[];
  final seen = <String>{};

  void add(String name) {
    if (seen.add(name)) {
      preferred.add(name);
    }
  }

  for (final name in _preferredCommsTimezones) {
    if (name == 'UTC' || all.contains(name)) {
      add(name);
    }
  }

  final currentName = current?.trim();
  if (currentName != null && currentName.isNotEmpty) {
    add(currentName);
  }

  return [
    ...preferred,
    for (final name in all)
      if (seen.add(name)) name,
  ];
}
