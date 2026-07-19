import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../lines/models/distance_input_unit.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../providers/slope_provider.dart';

class SlopeBanner extends ConsumerStatefulWidget {
  const SlopeBanner({
    super.key,
    required this.onCancel,
  });

  final VoidCallback onCancel;

  @override
  ConsumerState<SlopeBanner> createState() => _SlopeBannerState();
}

class _SlopeBannerState extends ConsumerState<SlopeBanner> {
  late final TextEditingController _rangeController;
  DistanceInputUnit _rangeUnit = DistanceInputUnit.meters;

  @override
  void initState() {
    super.initState();
    final state = ref.read(slopeProvider);
    final units = ref.read(measurementUnitsProvider);
    _rangeUnit = defaultDistanceInputUnit(state.rangeMeters, units);
    _rangeController = TextEditingController(
      text: formatDistanceInputFieldValue(state.rangeMeters, _rangeUnit),
    );
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }

  void _applyRange(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null || value <= 0) {
      return;
    }
    final meters = distanceInputValueToMeters(value, _rangeUnit);
    ref.read(slopeProvider.notifier).setRangeMeters(meters);
  }

  String _statusText(AppLocalizations l10n, SlopeState state) {
    return switch (state.status) {
      SlopeStatus.computing => l10n.slopeStatusComputing(
        (state.progress * 100).round(),
      ),
      SlopeStatus.ready => l10n.slopeStatusReady,
      SlopeStatus.missingDem => l10n.slopeStatusMissingDem,
      SlopeStatus.readyToCompute => l10n.slopeStatusReadyToCompute,
      SlopeStatus.error => state.errorMessage ?? l10n.slopeStatusError,
      SlopeStatus.idle => l10n.slopeTitle,
    };
  }

  InputDecoration _fieldDecoration(ThemeData theme, String label) {
    final onInverse = theme.colorScheme.onInverseSurface;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: onInverse.withValues(alpha: 0.8),
        fontSize: 12,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: onInverse.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: onInverse.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.inversePrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(slopeProvider);
    final units = ref.watch(measurementUnitsProvider);
    final onInverse = theme.colorScheme.onInverseSurface;
    final computing = state.status == SlopeStatus.computing;

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
                  Icon(Icons.terrain, color: onInverse),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.slopeTitle} · ${_statusText(l10n, state)}',
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
              if (state.meanSlopeDegrees != null &&
                  state.maxSlopeDegrees != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.slopeStats(
                    state.meanSlopeDegrees!.toStringAsFixed(1),
                    state.maxSlopeDegrees!.toStringAsFixed(1),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: onInverse),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _rangeController,
                      enabled: !computing,
                      decoration: _fieldDecoration(theme, l10n.slopeRangeLabel),
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
                            final meters = distanceInputValueToMeters(
                              double.tryParse(_rangeController.text) ??
                                  state.rangeMeters,
                              _rangeUnit,
                            );
                            setState(() => _rangeUnit = unit);
                            _rangeController.text =
                                formatDistanceInputFieldValue(meters, unit);
                            ref
                                .read(slopeProvider.notifier)
                                .setRangeMeters(meters);
                          },
                  ),
                  SegmentedButton<SlopeColorMode>(
                    segments: [
                      ButtonSegment(
                        value: SlopeColorMode.cost,
                        label: Text(l10n.slopeModeCost),
                      ),
                      ButtonSegment(
                        value: SlopeColorMode.slope,
                        label: Text(l10n.slopeModeSlope),
                      ),
                    ],
                    selected: {state.colorMode},
                    onSelectionChanged: computing
                        ? null
                        : (value) {
                            ref
                                .read(slopeProvider.notifier)
                                .setColorMode(value.first);
                            unawaited(
                              ref.read(slopeProvider.notifier).compute(),
                            );
                          },
                  ),
                  SizedBox(
                    width: 140,
                    child: Row(
                      children: [
                        Text(
                          l10n.slopeOpacityLabel,
                          style: TextStyle(color: onInverse, fontSize: 12),
                        ),
                        Expanded(
                          child: Slider(
                            value: state.opacity,
                            min: 0.2,
                            max: 0.85,
                            onChanged: computing
                                ? null
                                : (value) {
                                    ref
                                        .read(slopeProvider.notifier)
                                        .setOpacity(value);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: computing
                        ? null
                        : () {
                            _applyRange(_rangeController.text);
                            unawaited(
                              ref.read(slopeProvider.notifier).compute(),
                            );
                          },
                    child: Text(l10n.slopeComputeAction),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.slopeLegendHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onInverse.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
