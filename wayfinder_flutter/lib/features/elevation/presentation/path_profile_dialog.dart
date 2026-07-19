import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../providers/elevation_providers.dart';
import '../utils/elevation_format.dart';
import '../utils/path_profile.dart';

Future<void> showPathProfileDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required List<LatLng> pathPoints,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PathProfileDialog(
      title: title,
      pathPoints: pathPoints,
    ),
  );
}

class _PathProfileDialog extends ConsumerStatefulWidget {
  const _PathProfileDialog({
    required this.title,
    required this.pathPoints,
  });

  final String title;
  final List<LatLng> pathPoints;

  @override
  ConsumerState<_PathProfileDialog> createState() => _PathProfileDialogState();
}

class _PathProfileDialogState extends ConsumerState<_PathProfileDialog> {
  PathProfileStats? _stats;
  Object? _error;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final sampler = await ref.read(elevationSamplerProvider.future);
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      if (!sampler.hasDem) {
        setState(() {
          _loading = false;
          _error = l10n.elevationNoDemAvailable;
        });
        return;
      }

      final stations = samplePointsAlongPath(widget.pathPoints);
      final elevations = await sampler.elevationsAlong(stations);
      if (!mounted) {
        return;
      }
      final stats = buildPathProfileStats(
        samplePoints: stations,
        elevations: elevations,
      );
      setState(() {
        _stats = stats;
        _loading = false;
        if (stats.isEmpty) {
          _error = l10n.elevationProfileEmpty;
        }
      });
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.elevationProfileFailed(error.toString());
        _loading = false;
      });
      assert(() {
        // ignore: avoid_print
        print('Elevation profile failed: $error\n$stackTrace');
        return true;
      }());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = ref.watch(measurementUnitsProvider);
    final theme = Theme.of(context);
    final stats = _stats;
    final flatPath =
        stats != null &&
        !stats.isEmpty &&
        (stats.maxElevationMeters - stats.minElevationMeters).abs() < 0.5;

    return AlertDialog(
      title: Text(l10n.elevationProfileTitle),
      content: SizedBox(
        width: 480,
        child: _loading
            ? const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
            ? Text(
                _error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            : stats == null || stats.isEmpty
            ? Text(l10n.elevationProfileEmpty)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.mapObjectDetailLength}: '
                    '${formatLineDistance(stats.lengthMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileMin}: '
                    '${formatElevationMeters(stats.minElevationMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileMax}: '
                    '${formatElevationMeters(stats.maxElevationMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileGain}: '
                    '${formatElevationMeters(stats.gainMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileLoss}: '
                    '${formatElevationMeters(stats.lossMeters, units)}',
                  ),
                  if (flatPath) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.elevationProfileFlatHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: CustomPaint(
                      painter: _ProfileChartPainter(
                        samples: stats.samples,
                        lineColor: theme.colorScheme.primary,
                        gridColor: theme.colorScheme.outlineVariant,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
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

class _ProfileChartPainter extends CustomPainter {
  _ProfileChartPainter({
    required this.samples,
    required this.lineColor,
    required this.gridColor,
  });

  final List<PathProfileSample> samples;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) {
      return;
    }
    final minE = samples
        .map((s) => s.elevationMeters)
        .reduce((a, b) => a < b ? a : b);
    final maxE = samples
        .map((s) => s.elevationMeters)
        .reduce((a, b) => a > b ? a : b);
    final maxD = samples.last.distanceMeters;
    // Keep a minimum vertical span so flat paths draw as a centered line.
    final elevSpan = math.max(1.0, (maxE - minE).abs());
    final pad = size.height * 0.15;
    final plotHeight = size.height - pad * 2;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = ui.Path();
    for (var i = 0; i < samples.length; i++) {
      final x = maxD <= 0 ? 0.0 : samples[i].distanceMeters / maxD * size.width;
      final y =
          pad +
          plotHeight -
          ((samples[i].elevationMeters - minE) / elevSpan) * plotHeight;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileChartPainter oldDelegate) {
    return oldDelegate.samples != samples || oldDelegate.lineColor != lineColor;
  }
}
