import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../map/utils/magnetic_declination.dart';
import '../models/bearing_reference.dart';
import '../models/distance_input_unit.dart';
import '../models/measurement_units.dart';
import '../providers/dead_reckoning_provider.dart';
import '../providers/measurement_units_provider.dart';
import '../providers/pace_length_provider.dart';

class DeadReckoningBanner extends ConsumerStatefulWidget {
  const DeadReckoningBanner({
    super.key,
    required this.bearingReference,
    required this.declinationDegrees,
    required this.onPlaceMarker,
    required this.onCreateLine,
    required this.onCancel,
  });

  final BearingReference bearingReference;
  final double declinationDegrees;
  final VoidCallback onPlaceMarker;
  final VoidCallback onCreateLine;
  final VoidCallback onCancel;

  @override
  ConsumerState<DeadReckoningBanner> createState() =>
      _DeadReckoningBannerState();
}

class _DeadReckoningBannerState extends ConsumerState<DeadReckoningBanner> {
  late final TextEditingController _headingController;
  late final TextEditingController _pacesController;
  late final TextEditingController _paceLengthController;
  late final TextEditingController _distanceController;
  DistanceInputUnit _distanceUnit = DistanceInputUnit.meters;

  @override
  void initState() {
    super.initState();
    final state = ref.read(deadReckoningProvider);
    final units = ref.read(measurementUnitsProvider);
    _distanceUnit = defaultDistanceInputUnit(state.distanceMeters, units);
    _headingController = TextEditingController(
      text: _displayHeading(state.headingTrueDegrees).toStringAsFixed(0),
    );
    _pacesController = TextEditingController(
      text: _trimNumber(state.paceCount),
    );
    _paceLengthController = TextEditingController(
      text: _trimNumber(state.paceLengthMeters),
    );
    _distanceController = TextEditingController(
      text: formatDistanceInputFieldValue(state.distanceMeters, _distanceUnit),
    );
  }

  @override
  void dispose() {
    _headingController.dispose();
    _pacesController.dispose();
    _paceLengthController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  double _displayHeading(double trueBearing) {
    return displayBearingFromTrue(
      trueBearingDegrees: trueBearing,
      reference: widget.bearingReference,
      declinationDegrees: widget.declinationDegrees,
    );
  }

  String _trimNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _applyHeading(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null) {
      return;
    }
    final trueBearing = switch (widget.bearingReference) {
      BearingReference.trueNorth => value,
      BearingReference.magnetic => magneticBearingToTrue(
        magneticBearingDegrees: value,
        declinationDegrees: widget.declinationDegrees,
      ),
    };
    ref.read(deadReckoningProvider.notifier).setHeadingTrue(trueBearing);
  }

  void _applyPaces(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null) {
      return;
    }
    ref.read(deadReckoningProvider.notifier).setPaceCount(value);
  }

  void _applyPaceLength(String raw) {
    final value = double.tryParse(raw.trim());
    if (value == null || value <= 0) {
      return;
    }
    ref.read(deadReckoningProvider.notifier).setPaceLengthMeters(value);
    unawaited(ref.read(paceLengthProvider.notifier).setPaceLengthMeters(value));
  }

  void _applyDistance(String raw) {
    final meters = parseDistanceInputFieldValue(raw, _distanceUnit);
    if (meters == null || meters < 0) {
      return;
    }
    ref.read(deadReckoningProvider.notifier).setDistanceMeters(meters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(deadReckoningProvider);
    final units = ref.watch(measurementUnitsProvider);
    final onInverse = theme.colorScheme.onInverseSurface;
    final bearingSuffix = switch (widget.bearingReference) {
      BearingReference.trueNorth => '°T',
      BearingReference.magnetic => '°M',
    };
    final distanceLabel = formatLineDistance(
      state.effectiveDistanceMeters,
      units,
    );
    final canPlace = state.previewEnd != null;

    InputDecoration fieldDecoration(String label) {
      return InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(color: onInverse.withValues(alpha: 0.8), fontSize: 11),
        filled: true,
        fillColor: theme.colorScheme.surface.withValues(alpha: 0.15),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );
    }

    final fieldStyle = TextStyle(color: onInverse, fontSize: 13);

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
                  Icon(Icons.directions_walk, color: onInverse),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.mapDeadReckoningTitle} · $distanceLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SegmentedButton<DeadReckoningDistanceMode>(
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: WidgetStatePropertyAll(onInverse),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: onInverse.withValues(alpha: 0.4)),
                      ),
                    ),
                    segments: [
                      ButtonSegment(
                        value: DeadReckoningDistanceMode.paces,
                        label: Text(l10n.mapDeadReckoningModePaces),
                      ),
                      ButtonSegment(
                        value: DeadReckoningDistanceMode.distance,
                        label: Text(l10n.mapDeadReckoningModeDistance),
                      ),
                    ],
                    selected: {state.distanceMode},
                    onSelectionChanged: (selected) {
                      ref
                          .read(deadReckoningProvider.notifier)
                          .setDistanceMode(selected.first);
                    },
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
                      controller: _headingController,
                      decoration: fieldDecoration(
                        '${l10n.mapDeadReckoningHeadingLabel}$bearingSuffix',
                      ),
                      style: fieldStyle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      textInputAction: TextInputAction.next,
                      onChanged: _applyHeading,
                      onSubmitted: _applyHeading,
                    ),
                  ),
                  if (state.distanceMode == DeadReckoningDistanceMode.paces) ...[
                    SizedBox(
                      width: 88,
                      child: TextField(
                        controller: _pacesController,
                        decoration: fieldDecoration(
                          l10n.mapDeadReckoningPacesLabel,
                        ),
                        style: fieldStyle,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: _applyPaces,
                        onSubmitted: _applyPaces,
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: TextField(
                        controller: _paceLengthController,
                        decoration: fieldDecoration(
                          l10n.mapDeadReckoningPaceLengthLabel,
                        ),
                        style: fieldStyle,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        textInputAction: TextInputAction.done,
                        onChanged: _applyPaceLength,
                        onSubmitted: _applyPaceLength,
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 88,
                      child: TextField(
                        controller: _distanceController,
                        decoration: fieldDecoration(
                          l10n.mapDeadReckoningDistanceLabel,
                        ),
                        style: fieldStyle,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        textInputAction: TextInputAction.done,
                        onChanged: _applyDistance,
                        onSubmitted: _applyDistance,
                      ),
                    ),
                    DropdownButton<DistanceInputUnit>(
                      value: _distanceUnit,
                      dropdownColor: theme.colorScheme.inverseSurface,
                      style: fieldStyle,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final unit in distanceInputUnitsFor(units))
                          DropdownMenuItem(
                            value: unit,
                            child: Text(unit.shortLabel),
                          ),
                      ],
                      onChanged: (unit) {
                        if (unit == null) {
                          return;
                        }
                        setState(() {
                          _distanceUnit = unit;
                          _distanceController.text =
                              formatDistanceInputFieldValue(
                                state.distanceMeters,
                                unit,
                              );
                        });
                      },
                    ),
                  ],
                  TextButton(
                    onPressed: canPlace ? widget.onPlaceMarker : null,
                    child: Text(
                      l10n.mapDeadReckoningPlaceMarker,
                      style: TextStyle(color: theme.colorScheme.inversePrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: canPlace ? widget.onCreateLine : null,
                    child: Text(
                      l10n.mapDeadReckoningCreateLine,
                      style: TextStyle(color: theme.colorScheme.inversePrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      l10n.actionCancel,
                      style: TextStyle(color: theme.colorScheme.inversePrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
