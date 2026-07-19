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
      setState(() {
        _stats = buildPathProfileStats(
          samplePoints: stations,
          elevations: elevations,
        );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = ref.watch(measurementUnitsProvider);
    final theme = Theme.of(context);

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
            ? Text(_error.toString())
            : _stats == null || _stats!.isEmpty
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
                    '${formatLineDistance(_stats!.lengthMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileMin}: '
                    '${formatElevationMeters(_stats!.minElevationMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileMax}: '
                    '${formatElevationMeters(_stats!.maxElevationMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileGain}: '
                    '${formatElevationMeters(_stats!.gainMeters, units)}',
                  ),
                  Text(
                    '${l10n.elevationProfileLoss}: '
                    '${formatElevationMeters(_stats!.lossMeters, units)}',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: CustomPaint(
                      painter: _ProfileChartPainter(
                        samples: _stats!.samples,
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
    final elevSpan = (maxE - minE).abs() < 1 ? 1.0 : (maxE - minE);

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
          size.height -
          ((samples[i].elevationMeters - minE) / elevSpan) * size.height;
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
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileChartPainter oldDelegate) {
    return oldDelegate.samples != samples || oldDelegate.lineColor != lineColor;
  }
}
