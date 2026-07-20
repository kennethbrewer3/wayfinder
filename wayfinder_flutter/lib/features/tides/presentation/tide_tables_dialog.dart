import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/copy_coordinates.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../providers/tides_providers.dart';
import '../utils/tide_format.dart';

enum TideAnchor { marker, home, point }

Future<void> showTideTablesDialog({
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
      return TideTablesDialog(
        selectedMarkerCenter: selectedMarkerCenter,
        selectedMarkerName: selectedMarkerName,
        homeCenter: homeCenter,
        mapPoint: mapPoint,
        initialDate: initialDate,
      );
    },
  );
}

class TideTablesDialog extends ConsumerStatefulWidget {
  const TideTablesDialog({
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
  ConsumerState<TideTablesDialog> createState() => _TideTablesDialogState();
}

class _TideTablesDialogState extends ConsumerState<TideTablesDialog> {
  late TideAnchor _anchor;
  late DateTime _date;
  TideQueryResult? _result;
  Object? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _anchor = _defaultAnchor();
    final initial = widget.initialDate ?? DateTime.now();
    _date = DateTime(initial.year, initial.month, initial.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_reload());
    });
  }

  TideAnchor _defaultAnchor() {
    if (widget.selectedMarkerCenter != null) {
      return TideAnchor.marker;
    }
    if (widget.mapPoint != null) {
      return TideAnchor.point;
    }
    return TideAnchor.home;
  }

  List<TideAnchor> get _availableAnchors => [
    if (widget.selectedMarkerCenter != null) TideAnchor.marker,
    if (widget.homeCenter != null) TideAnchor.home,
    if (widget.mapPoint != null) TideAnchor.point,
  ];

  LatLng? get _center => switch (_anchor) {
    TideAnchor.marker => widget.selectedMarkerCenter,
    TideAnchor.home => widget.homeCenter,
    TideAnchor.point => widget.mapPoint,
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _date = DateTime(picked.year, picked.month, picked.day);
    });
    await _reload();
  }

  Future<void> _reload() async {
    final center = _center;
    if (center == null) {
      setState(() {
        _result = null;
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(tidesRepositoryProvider).queryAt(
        lat: center.latitude,
        lng: center.longitude,
        date: _date.toUtc(),
        hours: 24,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _result = null;
        _error = error;
        _loading = false;
      });
    }
  }

  String _anchorLabel(TideAnchor anchor, AppLocalizations l10n) {
    return switch (anchor) {
      TideAnchor.marker => l10n.tidesAnchorMarker,
      TideAnchor.home => l10n.tidesAnchorHome,
      TideAnchor.point => l10n.tidesAnchorMapPoint,
    };
  }

  String _extremeLabel(String type, AppLocalizations l10n) {
    return switch (type.toLowerCase()) {
      'high' => l10n.tidesExtremeHigh,
      'low' => l10n.tidesExtremeLow,
      _ => type,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final units = ref.watch(measurementUnitsProvider);
    final anchors = _availableAnchors;
    final center = _center;
    final result = _result;

    return AlertDialog(
      title: Text(l10n.tidesTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.tidesSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (anchors.length > 1) ...[
                Text(l10n.tidesLocationLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<TideAnchor>(
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
                    unawaited(_reload());
                  },
                ),
                const SizedBox(height: 12),
              ],
              if (center != null) ...[
                Text(formatLatLng(center), style: theme.textTheme.bodyMedium),
                if (_anchor == TideAnchor.marker &&
                    widget.selectedMarkerName?.trim().isNotEmpty == true)
                  Text(
                    widget.selectedMarkerName!.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tidesDateLabel),
                subtitle: Text(DateFormat.yMMMEd().format(_date)),
                trailing: IconButton(
                  tooltip: l10n.tidesPickDate,
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _InfoBanner(
                  text: l10n.tidesQueryFailed(_error.toString()),
                  error: true,
                )
              else if (result == null)
                Text(l10n.tidesMissingLocation)
              else ...[
                if (result.approximate)
                  _InfoBanner(text: l10n.tidesApproximateBanner),
                if (result.message != null && result.message!.isNotEmpty)
                  _InfoBanner(text: result.message!),
                Text(
                  l10n.tidesStationHeading(
                    result.station.name,
                    result.station.id,
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tidesStationMeta(
                    formatTideDistanceMeters(
                      result.station.distanceMeters,
                      units,
                      l10n,
                    ),
                    result.datum,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.tidesExtremesSection,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (result.extremes.isEmpty)
                  Text(l10n.tidesNoExtremes)
                else
                  for (final extreme in result.extremes)
                    _TideRow(
                      label: _extremeLabel(extreme.type, l10n),
                      time: DateFormat.Hm().format(extreme.time.toLocal()),
                      height: formatTideHeightMeters(
                        extreme.heightMeters,
                        units,
                        l10n,
                      ),
                    ),
                const SizedBox(height: 16),
                Text(
                  l10n.tidesCurveSection,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _TideCurveChart(samples: result.samples, units: units),
                const SizedBox(height: 8),
                Text(
                  l10n.tidesCrossingHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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

class _TideRow extends StatelessWidget {
  const _TideRow({
    required this.label,
    required this.time,
    required this.height,
  });

  final String label;
  final String time;
  final String height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label)),
          SizedBox(
            width: 64,
            child: Text(
              time,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Text(
              height,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TideCurveChart extends StatelessWidget {
  const _TideCurveChart({required this.samples, required this.units});

  final List<TideSample> samples;
  final MeasurementUnits units;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (samples.length < 2) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _TideCurvePainter(
          samples: samples,
          lineColor: theme.colorScheme.primary,
          gridColor: theme.colorScheme.outlineVariant,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TideCurvePainter extends CustomPainter {
  _TideCurvePainter({
    required this.samples,
    required this.lineColor,
    required this.gridColor,
  });

  final List<TideSample> samples;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minH = samples
        .map((s) => s.heightMeters)
        .reduce((a, b) => a < b ? a : b);
    final maxH = samples
        .map((s) => s.heightMeters)
        .reduce((a, b) => a > b ? a : b);
    final span = (maxH - minH).abs() < 1e-6 ? 1.0 : maxH - minH;
    final pad = span * 0.1;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );

    final path = ui.Path();
    for (var i = 0; i < samples.length; i++) {
      final x = size.width * i / (samples.length - 1);
      final y =
          size.height -
          ((samples[i].heightMeters - (minH - pad)) / (span + 2 * pad)) *
              size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TideCurvePainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = error
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;
    final fg = error
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSecondaryContainer;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(color: fg)),
    );
  }
}
