import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../lines/models/distance_input_unit.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../providers/viewshed_provider.dart';

class ViewshedBanner extends ConsumerStatefulWidget {
  const ViewshedBanner({
    super.key,
    required this.onCancel,
  });

  final VoidCallback onCancel;

  @override
  ConsumerState<ViewshedBanner> createState() => _ViewshedBannerState();
}

class _ViewshedBannerState extends ConsumerState<ViewshedBanner> {
  late final TextEditingController _antennaController;
  late final TextEditingController _rangeController;
  late final TextEditingController _targetHeightController;
  DistanceInputUnit _rangeUnit = DistanceInputUnit.meters;

  @override
  void initState() {
    super.initState();
    final state = ref.read(viewshedProvider);
    final units = ref.read(measurementUnitsProvider);
    _rangeUnit = defaultDistanceInputUnit(state.rangeMeters, units);
    _antennaController = TextEditingController(
      text: _trimNumber(state.antennaHeightMeters),
    );
    _rangeController = TextEditingController(
      text: formatDistanceInputFieldValue(state.rangeMeters, _rangeUnit),
    );
    _targetHeightController = TextEditingController(
      text: _trimNumber(state.targetHeightAglMeters),
    );
  }

  @override
  void dispose() {
    _antennaController.dispose();
    _rangeController.dispose();
    _targetHeightController.dispose();
    super.dispose();
  }

  String _trimNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  void _applyAntenna(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null || value < 0) {
      return;
    }
    ref.read(viewshedProvider.notifier).setAntennaHeightMeters(value);
  }

  void _applyRange(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null || value <= 0) {
      return;
    }
    final meters = distanceInputValueToMeters(value, _rangeUnit);
    ref.read(viewshedProvider.notifier).setRangeMeters(meters);
  }

  void _applyTargetHeight(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null || value < 0) {
      return;
    }
    ref.read(viewshedProvider.notifier).setTargetHeightAglMeters(value);
  }

  String _statusText(AppLocalizations l10n, ViewshedState state) {
    return switch (state.status) {
      ViewshedStatus.computing => l10n.viewshedStatusComputing(
        (state.progress * 100).round(),
      ),
      ViewshedStatus.ready => l10n.viewshedStatusReady,
      ViewshedStatus.missingDem => l10n.viewshedStatusMissingDem,
      ViewshedStatus.missingElevation => l10n.viewshedStatusMissingElevation,
      ViewshedStatus.readyToCompute => l10n.viewshedStatusReadyToCompute,
      ViewshedStatus.error => state.errorMessage ?? l10n.viewshedStatusError,
      ViewshedStatus.idle => l10n.viewshedTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(viewshedProvider);
    final units = ref.watch(measurementUnitsProvider);
    final onInverse = theme.colorScheme.onInverseSurface;
    final computing = state.status == ViewshedStatus.computing;

    return Material(
      elevation: 2,
      color: theme.colorScheme.inverseSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility, color: onInverse),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.viewshedTitle} · ${_statusText(l10n, state)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      l10n.actionCancel,
                      style: TextStyle(
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 88,
                    child: TextField(
                      controller: _antennaController,
                      enabled: !computing,
                      decoration: _fieldDecoration(
                        theme,
                        l10n.viewshedAntennaHeightLabel,
                      ),
                      style: TextStyle(color: onInverse, fontSize: 13),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onSubmitted: _applyAntenna,
                      onEditingComplete: () =>
                          _applyAntenna(_antennaController.text),
                    ),
                  ),
                  SizedBox(
                    width: 88,
                    child: TextField(
                      controller: _targetHeightController,
                      enabled: !computing,
                      decoration: _fieldDecoration(
                        theme,
                        l10n.viewshedTargetHeightLabel,
                      ),
                      style: TextStyle(color: onInverse, fontSize: 13),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onSubmitted: _applyTargetHeight,
                      onEditingComplete: () =>
                          _applyTargetHeight(_targetHeightController.text),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _rangeController,
                      enabled: !computing,
                      decoration: _fieldDecoration(
                        theme,
                        l10n.viewshedRangeLabel,
                      ),
                      style: TextStyle(color: onInverse, fontSize: 13),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onSubmitted: _applyRange,
                      onEditingComplete: () =>
                          _applyRange(_rangeController.text),
                    ),
                  ),
                  DropdownButton<DistanceInputUnit>(
                    value: _rangeUnit,
                    dropdownColor: theme.colorScheme.inverseSurface,
                    style: TextStyle(color: onInverse, fontSize: 13),
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final unit in distanceInputUnitsFor(units))
                        DropdownMenuItem(
                          value: unit,
                          child: Text(unit.shortLabel),
                        ),
                    ],
                    onChanged: computing
                        ? null
                        : (unit) {
                            if (unit == null) {
                              return;
                            }
                            setState(() {
                              _rangeUnit = unit;
                              _rangeController.text =
                                  formatDistanceInputFieldValue(
                                    state.rangeMeters,
                                    unit,
                                  );
                            });
                          },
                  ),
                  FilledButton(
                    onPressed: computing
                        ? null
                        : () {
                            _applyAntenna(_antennaController.text);
                            _applyTargetHeight(_targetHeightController.text);
                            _applyRange(_rangeController.text);
                            ref.read(viewshedProvider.notifier).compute();
                          },
                    child: Text(l10n.viewshedComputeAction),
                  ),
                ],
              ),
              if (computing) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: state.progress),
              ],
              if (state.observerGroundMeters != null) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.viewshedObserverElevation(
                    state.observerGroundMeters!.round().toString(),
                    (state.observerEyeMeters ?? 0).round().toString(),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: onInverse.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(ThemeData theme, String label) {
    final onInverse = theme.colorScheme.onInverseSurface;
    return InputDecoration(
      isDense: true,
      labelText: label,
      labelStyle: TextStyle(
        color: onInverse.withValues(alpha: 0.8),
        fontSize: 11,
      ),
      filled: true,
      fillColor: theme.colorScheme.surface.withValues(alpha: 0.15),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}
