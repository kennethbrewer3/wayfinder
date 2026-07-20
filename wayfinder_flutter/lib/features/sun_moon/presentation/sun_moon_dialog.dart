import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/copy_coordinates.dart';
import '../models/sun_moon_result.dart';
import '../models/sun_moon_timezone.dart';
import '../utils/sun_moon_compute.dart';
import '../utils/sun_moon_timezone.dart';

enum SunMoonAnchor { marker, home, point }

Future<void> showSunMoonDialog({
  required BuildContext context,
  LatLng? selectedMarkerCenter,
  String? selectedMarkerName,
  LatLng? homeCenter,
  LatLng? mapPoint,
  DateTime? initialDate,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return SunMoonDialog(
        selectedMarkerCenter: selectedMarkerCenter,
        selectedMarkerName: selectedMarkerName,
        homeCenter: homeCenter,
        mapPoint: mapPoint,
        initialDate: initialDate,
      );
    },
  );
}

class SunMoonDialog extends StatefulWidget {
  const SunMoonDialog({
    super.key,
    this.selectedMarkerCenter,
    this.selectedMarkerName,
    this.homeCenter,
    this.mapPoint,
    this.initialDate,
  });

  final LatLng? selectedMarkerCenter;
  final String? selectedMarkerName;
  final LatLng? homeCenter;
  final LatLng? mapPoint;
  final DateTime? initialDate;

  @override
  State<SunMoonDialog> createState() => _SunMoonDialogState();
}

class _SunMoonDialogState extends State<SunMoonDialog> {
  late SunMoonAnchor _anchor;
  late DateTime _date;
  late SunMoonTimeBase _timeBase;
  late String _zoneId;
  late SunMoonDstMode _dstMode;

  @override
  void initState() {
    super.initState();
    ensureSunMoonTimeZonesInitialized();
    _anchor = _defaultAnchor();
    final initial = widget.initialDate ?? DateTime.now();
    _date = DateTime(initial.year, initial.month, initial.day);
    _timeBase = SunMoonTimeBase.zone;
    _zoneId = sunMoonLongitudeZoneId;
    _dstMode = SunMoonDstMode.auto;
  }

  SunMoonAnchor _defaultAnchor() {
    if (widget.selectedMarkerCenter != null) {
      return SunMoonAnchor.marker;
    }
    if (widget.mapPoint != null) {
      return SunMoonAnchor.point;
    }
    return SunMoonAnchor.home;
  }

  List<SunMoonAnchor> get _availableAnchors {
    return [
      if (widget.selectedMarkerCenter != null) SunMoonAnchor.marker,
      if (widget.homeCenter != null) SunMoonAnchor.home,
      if (widget.mapPoint != null) SunMoonAnchor.point,
    ];
  }

  LatLng? get _center => switch (_anchor) {
    SunMoonAnchor.marker => widget.selectedMarkerCenter,
    SunMoonAnchor.home => widget.homeCenter,
    SunMoonAnchor.point => widget.mapPoint,
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  String _formatEvent(DateTime? utc, AppLocalizations l10n) {
    if (utc == null) {
      return l10n.sunMoonNotApplicable;
    }
    switch (_timeBase) {
      case SunMoonTimeBase.utc:
        return l10n.sunMoonTimeUtc(DateFormat.Hm().format(utc.toUtc()));
      case SunMoonTimeBase.device:
        return DateFormat.Hm().format(utc.toLocal());
      case SunMoonTimeBase.zone:
        final location = locationForZoneId(
          zoneId: _zoneId,
          location: _center,
        );
        final converted = convertUtcToZone(
          utc: utc,
          location: location,
          dstMode: _dstMode,
        );
        return DateFormat.Hm().format(converted.wallClock);
    }
  }

  String? _timezoneSummary(AppLocalizations l10n) {
    final center = _center;
    if (center == null) {
      return null;
    }
    switch (_timeBase) {
      case SunMoonTimeBase.utc:
        return l10n.sunMoonTzSummaryUtc;
      case SunMoonTimeBase.device:
        final offset = DateTime.now().timeZoneOffset;
        final name = DateTime.now().timeZoneName;
        return l10n.sunMoonTzSummaryDevice(name, formatUtcOffset(offset));
      case SunMoonTimeBase.zone:
        final location = locationForZoneId(
          zoneId: _zoneId,
          location: center,
        );
        final sampleUtc = DateTime.utc(_date.year, _date.month, _date.day, 16);
        final converted = convertUtcToZone(
          utc: sampleUtc,
          location: location,
          dstMode: _dstMode,
        );
        final dstLabel = switch (_dstMode) {
          SunMoonDstMode.auto =>
            converted.isDst ? l10n.sunMoonDstDaylight : l10n.sunMoonDstStandard,
          SunMoonDstMode.standard => l10n.sunMoonDstStandard,
          SunMoonDstMode.daylight => l10n.sunMoonDstDaylight,
        };
        final iana = resolveZoneIanaName(zoneId: _zoneId, location: center);
        return l10n.sunMoonTzSummaryZone(
          iana,
          converted.abbreviation,
          formatUtcOffset(converted.offset),
          dstLabel,
        );
    }
  }

  String _phaseLabel(MoonPhaseName phase, AppLocalizations l10n) {
    return switch (phase) {
      MoonPhaseName.newMoon => l10n.sunMoonPhaseNew,
      MoonPhaseName.waxingCrescent => l10n.sunMoonPhaseWaxingCrescent,
      MoonPhaseName.firstQuarter => l10n.sunMoonPhaseFirstQuarter,
      MoonPhaseName.waxingGibbous => l10n.sunMoonPhaseWaxingGibbous,
      MoonPhaseName.fullMoon => l10n.sunMoonPhaseFull,
      MoonPhaseName.waningGibbous => l10n.sunMoonPhaseWaningGibbous,
      MoonPhaseName.lastQuarter => l10n.sunMoonPhaseLastQuarter,
      MoonPhaseName.waningCrescent => l10n.sunMoonPhaseWaningCrescent,
    };
  }

  String _anchorLabel(SunMoonAnchor anchor, AppLocalizations l10n) {
    return switch (anchor) {
      SunMoonAnchor.marker => l10n.sunMoonAnchorMarker,
      SunMoonAnchor.home => l10n.sunMoonAnchorHome,
      SunMoonAnchor.point => l10n.sunMoonAnchorMapPoint,
    };
  }

  String _zoneMenuLabel(String zoneId, AppLocalizations l10n) {
    if (zoneId == sunMoonLongitudeZoneId) {
      final iana = resolveZoneIanaName(zoneId: zoneId, location: _center);
      return l10n.sunMoonZoneLongitude(iana);
    }
    return zoneId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final anchors = _availableAnchors;
    final center = _center;
    final result = center == null
        ? null
        : computeSunMoon(location: center, date: _date);
    final tzSummary = _timezoneSummary(l10n);
    final zoneLocation = center == null
        ? null
        : locationForZoneId(zoneId: _zoneId, location: center);
    final observesDst = zoneLocation == null
        ? false
        : zoneOffsetsForYear(zoneLocation, _date.year).observesDst;

    return AlertDialog(
      title: Text(l10n.sunMoonTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.sunMoonSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (anchors.length > 1) ...[
                Text(
                  l10n.sunMoonLocationLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<SunMoonAnchor>(
                  segments: [
                    for (final anchor in anchors)
                      ButtonSegment(
                        value: anchor,
                        label: Text(_anchorLabel(anchor, l10n)),
                      ),
                  ],
                  selected: {_anchor},
                  onSelectionChanged: (value) {
                    setState(() => _anchor = value.first);
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (center != null) ...[
                Text(
                  formatLatLng(center),
                  style: theme.textTheme.bodyMedium,
                ),
                if (_anchor == SunMoonAnchor.marker &&
                    widget.selectedMarkerName?.trim().isNotEmpty == true)
                  Text(
                    widget.selectedMarkerName!.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.sunMoonDateLabel),
                subtitle: Text(DateFormat.yMMMEd().format(_date)),
                trailing: IconButton(
                  tooltip: l10n.sunMoonPickDate,
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
              ),
              _TimezoneOverlay(
                timeBase: _timeBase,
                zoneId: _zoneId,
                dstMode: _dstMode,
                observesDst: observesDst,
                summary: tzSummary,
                zoneLabelBuilder: (id) => _zoneMenuLabel(id, l10n),
                onTimeBaseChanged: (value) {
                  setState(() => _timeBase = value);
                },
                onZoneIdChanged: (value) {
                  setState(() => _zoneId = value);
                },
                onDstModeChanged: (value) {
                  setState(() => _dstMode = value);
                },
                l10n: l10n,
              ),
              const SizedBox(height: 8),
              if (result == null)
                Text(l10n.sunMoonMissingLocation)
              else ...[
                if (result.polarDay)
                  _InfoBanner(text: l10n.sunMoonPolarDay)
                else if (result.polarNight)
                  _InfoBanner(text: l10n.sunMoonPolarNight),
                _SectionTitle(l10n.sunMoonSunSection),
                _EventRow(
                  label: l10n.sunMoonSunrise,
                  value: _formatEvent(result.sunrise, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonSolarNoon,
                  value: _formatEvent(result.solarNoon, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonSunset,
                  value: _formatEvent(result.sunset, l10n),
                ),
                _SectionTitle(l10n.sunMoonTwilightSection),
                _EventRow(
                  label: l10n.sunMoonCivilDawn,
                  value: _formatEvent(result.civilDawn, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonCivilDusk,
                  value: _formatEvent(result.civilDusk, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonNauticalDawn,
                  value: _formatEvent(result.nauticalDawn, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonNauticalDusk,
                  value: _formatEvent(result.nauticalDusk, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonAstronomicalDawn,
                  value: _formatEvent(result.astronomicalDawn, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonAstronomicalDusk,
                  value: _formatEvent(result.astronomicalDusk, l10n),
                ),
                _SectionTitle(l10n.sunMoonNightOpsSection),
                Text(
                  l10n.sunMoonNightOpsHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                _EventRow(
                  label: l10n.sunMoonNightOpsStart,
                  value: _formatEvent(result.nightOpsStart, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonNightOpsEnd,
                  value: _formatEvent(result.nightOpsEnd, l10n),
                ),
                _SectionTitle(l10n.sunMoonMoonSection),
                _EventRow(
                  label: l10n.sunMoonPhaseLabel,
                  value: _phaseLabel(result.moonPhase, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonIlluminationLabel,
                  value: l10n.sunMoonIlluminationValue(
                    (result.moonIllumination * 100).round(),
                  ),
                ),
                _EventRow(
                  label: l10n.sunMoonAgeLabel,
                  value: l10n.sunMoonAgeValue(
                    result.moonAgeDays.toStringAsFixed(1),
                  ),
                ),
                _EventRow(
                  label: l10n.sunMoonMoonrise,
                  value: _formatEvent(result.moonrise, l10n),
                ),
                _EventRow(
                  label: l10n.sunMoonMoonset,
                  value: _formatEvent(result.moonset, l10n),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }
}

class _TimezoneOverlay extends StatelessWidget {
  const _TimezoneOverlay({
    required this.timeBase,
    required this.zoneId,
    required this.dstMode,
    required this.observesDst,
    required this.summary,
    required this.zoneLabelBuilder,
    required this.onTimeBaseChanged,
    required this.onZoneIdChanged,
    required this.onDstModeChanged,
    required this.l10n,
  });

  final SunMoonTimeBase timeBase;
  final String zoneId;
  final SunMoonDstMode dstMode;
  final bool observesDst;
  final String? summary;
  final String Function(String zoneId) zoneLabelBuilder;
  final ValueChanged<SunMoonTimeBase> onTimeBaseChanged;
  final ValueChanged<String> onZoneIdChanged;
  final ValueChanged<SunMoonDstMode> onDstModeChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sunMoonTimezoneSection,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.sunMoonTimezoneHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.sunMoonTimeBaseLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<SunMoonTimeBase>(
              segments: [
                ButtonSegment(
                  value: SunMoonTimeBase.zone,
                  label: Text(l10n.sunMoonTimeBaseZone),
                  tooltip: l10n.sunMoonTimeBaseZone,
                ),
                ButtonSegment(
                  value: SunMoonTimeBase.device,
                  label: Text(l10n.sunMoonTimeBaseDevice),
                  tooltip: l10n.sunMoonTimeBaseDevice,
                ),
                ButtonSegment(
                  value: SunMoonTimeBase.utc,
                  label: Text(l10n.sunMoonTimeBaseUtc),
                  tooltip: l10n.sunMoonTimeBaseUtc,
                ),
              ],
              selected: {timeBase},
              onSelectionChanged: (value) => onTimeBaseChanged(value.first),
            ),
            if (timeBase == SunMoonTimeBase.zone) ...[
              const SizedBox(height: 12),
              DropdownMenu<String>(
                key: ValueKey(zoneId),
                initialSelection: zoneId,
                label: Text(l10n.sunMoonZoneLabel),
                expandedInsets: EdgeInsets.zero,
                onSelected: (value) {
                  if (value != null) {
                    onZoneIdChanged(value);
                  }
                },
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: sunMoonLongitudeZoneId,
                    label: zoneLabelBuilder(sunMoonLongitudeZoneId),
                  ),
                  for (final zone in sunMoonNamedZones)
                    DropdownMenuEntry(
                      value: zone.id,
                      label: zoneLabelBuilder(zone.id),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.sunMoonDstLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<SunMoonDstMode>(
                segments: [
                  ButtonSegment(
                    value: SunMoonDstMode.auto,
                    label: Text(l10n.sunMoonDstAuto),
                    tooltip: l10n.sunMoonDstAutoHint,
                  ),
                  ButtonSegment(
                    value: SunMoonDstMode.standard,
                    label: Text(l10n.sunMoonDstStandard),
                    tooltip: l10n.sunMoonDstStandardHint,
                  ),
                  ButtonSegment(
                    value: SunMoonDstMode.daylight,
                    label: Text(l10n.sunMoonDstDaylight),
                    tooltip: observesDst
                        ? l10n.sunMoonDstDaylightHint
                        : l10n.sunMoonDstNoDstHint,
                  ),
                ],
                selected: {dstMode},
                onSelectionChanged: (value) => onDstModeChanged(value.first),
              ),
              if (!observesDst) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.sunMoonDstNoDstHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            if (summary != null) ...[
              const SizedBox(height: 12),
              Text(
                summary!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
