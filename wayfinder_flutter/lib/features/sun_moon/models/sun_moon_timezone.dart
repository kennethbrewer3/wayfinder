/// How event times are converted from UTC for display.
enum SunMoonTimeBase {
  /// Use the selected IANA / fixed-offset zone.
  zone,

  /// Use this device’s local timezone.
  device,

  /// Leave times in UTC.
  utc,
}

/// How daylight saving is applied when [SunMoonTimeBase.zone] is selected.
enum SunMoonDstMode {
  /// Use IANA rules for each event instant (or no DST for fixed offsets).
  auto,

  /// Always use the zone’s standard (winter) offset.
  standard,

  /// Always use the zone’s daylight offset (standard + DST delta when present).
  daylight,
}

/// A selectable timezone preset for sun/moon display.
class SunMoonZoneOption {
  const SunMoonZoneOption({
    required this.id,
    required this.ianaName,
  });

  /// Stable id used in UI selection (usually same as [ianaName]).
  final String id;

  /// IANA location name, e.g. `America/New_York` or `Etc/GMT+5`.
  final String ianaName;
}

/// Common civil zones plus a longitude-based fixed offset option.
const sunMoonNamedZones = <SunMoonZoneOption>[
  SunMoonZoneOption(id: 'UTC', ianaName: 'UTC'),
  SunMoonZoneOption(id: 'America/New_York', ianaName: 'America/New_York'),
  SunMoonZoneOption(id: 'America/Chicago', ianaName: 'America/Chicago'),
  SunMoonZoneOption(id: 'America/Denver', ianaName: 'America/Denver'),
  SunMoonZoneOption(id: 'America/Phoenix', ianaName: 'America/Phoenix'),
  SunMoonZoneOption(id: 'America/Los_Angeles', ianaName: 'America/Los_Angeles'),
  SunMoonZoneOption(id: 'America/Anchorage', ianaName: 'America/Anchorage'),
  SunMoonZoneOption(id: 'Pacific/Honolulu', ianaName: 'Pacific/Honolulu'),
  SunMoonZoneOption(id: 'America/Puerto_Rico', ianaName: 'America/Puerto_Rico'),
  SunMoonZoneOption(id: 'Europe/London', ianaName: 'Europe/London'),
  SunMoonZoneOption(id: 'Europe/Paris', ianaName: 'Europe/Paris'),
  SunMoonZoneOption(id: 'Europe/Berlin', ianaName: 'Europe/Berlin'),
  SunMoonZoneOption(id: 'Asia/Tokyo', ianaName: 'Asia/Tokyo'),
  SunMoonZoneOption(id: 'Australia/Sydney', ianaName: 'Australia/Sydney'),
];

/// Id for the synthetic “from longitude” fixed-offset zone.
const sunMoonLongitudeZoneId = 'longitude';
