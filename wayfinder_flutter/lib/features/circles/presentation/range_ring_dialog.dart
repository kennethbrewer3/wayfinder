import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../lines/models/measurement_units.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../../tracks/presentation/track_transportation_icon.dart';
import '../models/range_ring.dart';

enum FuelVolumeUnit { liters, gallons }

extension on FuelVolumeUnit {
  String shortLabel(AppLocalizations l10n) => switch (this) {
    FuelVolumeUnit.liters => l10n.rangeRingFuelUnitLiters,
    FuelVolumeUnit.gallons => l10n.rangeRingFuelUnitGallons,
  };
}

double fuelVolumeToLiters(double value, FuelVolumeUnit unit) {
  return switch (unit) {
    FuelVolumeUnit.liters => value,
    FuelVolumeUnit.gallons => value * 3.785411784,
  };
}

double litersToFuelVolume(double liters, FuelVolumeUnit unit) {
  return switch (unit) {
    FuelVolumeUnit.liters => liters,
    FuelVolumeUnit.gallons => liters / 3.785411784,
  };
}

FuelVolumeUnit defaultFuelVolumeUnit(MeasurementUnits units) {
  return switch (units) {
    MeasurementUnits.metric => FuelVolumeUnit.liters,
    MeasurementUnits.imperial ||
    MeasurementUnits.nautical => FuelVolumeUnit.gallons,
  };
}

class RangeRingDialogResult {
  const RangeRingDialogResult({
    required this.center,
    required this.radiusMeters,
    required this.spec,
    required this.suggestedName,
  });

  final LatLng center;
  final double radiusMeters;
  final RangeRingSpec spec;
  final String suggestedName;
}

Future<RangeRingDialogResult?> showRangeRingDialog({
  required BuildContext context,
  required MeasurementUnits measurementUnits,
  LatLng? selectedMarkerCenter,
  String? selectedMarkerId,
  String? selectedMarkerName,
  LatLng? homeCenter,
  LatLng? mapPoint,
}) {
  return showDialog<RangeRingDialogResult>(
    context: context,
    builder: (context) {
      return RangeRingDialog(
        measurementUnits: measurementUnits,
        selectedMarkerCenter: selectedMarkerCenter,
        selectedMarkerId: selectedMarkerId,
        selectedMarkerName: selectedMarkerName,
        homeCenter: homeCenter,
        mapPoint: mapPoint,
      );
    },
  );
}

class RangeRingDialog extends StatefulWidget {
  const RangeRingDialog({
    super.key,
    required this.measurementUnits,
    this.selectedMarkerCenter,
    this.selectedMarkerId,
    this.selectedMarkerName,
    this.homeCenter,
    this.mapPoint,
  });

  final MeasurementUnits measurementUnits;
  final LatLng? selectedMarkerCenter;
  final String? selectedMarkerId;
  final String? selectedMarkerName;
  final LatLng? homeCenter;
  final LatLng? mapPoint;

  @override
  State<RangeRingDialog> createState() => _RangeRingDialogState();
}

class _RangeRingDialogState extends State<RangeRingDialog> {
  late TrackTransportationMode _mode;
  late RangeRingAnchor _anchor;
  late RangeRingBasis _basis;
  late RangeRingAssumptions _assumptions;
  late FuelVolumeUnit _fuelUnit;
  late final TextEditingController _durationController;
  late final TextEditingController _fuelController;
  late final TextEditingController _speedController;
  late final TextEditingController _economyController;
  late final TextEditingController _tankController;

  @override
  void initState() {
    super.initState();
    _mode = TrackTransportationMode.onFoot;
    _anchor = _defaultAnchor();
    _basis = RangeRingBasis.duration;
    _assumptions = defaultRangeRingAssumptions(_mode);
    _fuelUnit = defaultFuelVolumeUnit(widget.measurementUnits);
    _durationController = TextEditingController(text: '4');
    _fuelController = TextEditingController();
    _speedController = TextEditingController(
      text: _trimNumber(_assumptions.speedKmh),
    );
    _economyController = TextEditingController();
    _tankController = TextEditingController();
    _syncAssumptionFields();
    _fillDefaultFuel();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _fuelController.dispose();
    _speedController.dispose();
    _economyController.dispose();
    _tankController.dispose();
    super.dispose();
  }

  RangeRingAnchor _defaultAnchor() {
    if (widget.selectedMarkerCenter != null) {
      return RangeRingAnchor.marker;
    }
    if (widget.homeCenter != null) {
      return RangeRingAnchor.home;
    }
    return RangeRingAnchor.point;
  }

  List<RangeRingAnchor> get _availableAnchors {
    return [
      if (widget.selectedMarkerCenter != null) RangeRingAnchor.marker,
      if (widget.homeCenter != null) RangeRingAnchor.home,
      if (widget.mapPoint != null) RangeRingAnchor.point,
    ];
  }

  LatLng? get _center {
    return switch (_anchor) {
      RangeRingAnchor.marker => widget.selectedMarkerCenter,
      RangeRingAnchor.home => widget.homeCenter,
      RangeRingAnchor.point => widget.mapPoint,
    };
  }

  void _applyMode(TrackTransportationMode mode) {
    setState(() {
      _mode = mode;
      _assumptions = defaultRangeRingAssumptions(mode);
      if (!rangeRingModeUsesFuel(mode)) {
        _basis = RangeRingBasis.duration;
      }
      _syncAssumptionFields();
      _fillDefaultFuel();
    });
  }

  void _syncAssumptionFields() {
    _speedController.text = _trimNumber(_assumptions.speedKmh);
    final economy = _assumptions.economyLPer100km;
    _economyController.text = economy == null ? '' : _trimNumber(economy);
    final tank = _assumptions.tankLiters;
    if (tank == null) {
      _tankController.text = '';
    } else {
      _tankController.text = _trimNumber(
        litersToFuelVolume(tank, _fuelUnit),
      );
    }
  }

  void _fillDefaultFuel() {
    final tank = _assumptions.tankLiters;
    if (tank == null) {
      _fuelController.text = '';
      return;
    }
    _fuelController.text = _trimNumber(
      litersToFuelVolume(tank, _fuelUnit),
    );
  }

  RangeRingAssumptions _assumptionsFromFields() {
    final defaults = defaultRangeRingAssumptions(_mode);
    final speed = double.tryParse(_speedController.text.trim());
    final economy = double.tryParse(_economyController.text.trim());
    final tankDisplay = double.tryParse(_tankController.text.trim());
    return RangeRingAssumptions(
      speedKmh: speed != null && speed > 0 ? speed : defaults.speedKmh,
      economyLPer100km: economy != null && economy > 0
          ? economy
          : defaults.economyLPer100km,
      tankLiters: tankDisplay != null && tankDisplay > 0
          ? fuelVolumeToLiters(tankDisplay, _fuelUnit)
          : defaults.tankLiters,
    );
  }

  double? get _durationHours =>
      double.tryParse(_durationController.text.trim());

  double? get _fuelLiters {
    final display = double.tryParse(_fuelController.text.trim());
    if (display == null || display <= 0) {
      return null;
    }
    return fuelVolumeToLiters(display, _fuelUnit);
  }

  double? get _radiusMeters {
    return rangeRingRadiusMeters(
      mode: _mode,
      basis: _basis,
      assumptions: _assumptionsFromFields(),
      durationHours: _durationHours,
      fuelLiters: _fuelLiters,
    );
  }

  String _suggestedName(AppLocalizations l10n) {
    final modeLabel = _mode.label(l10n);
    if (_basis == RangeRingBasis.fuel) {
      final fuel = double.tryParse(_fuelController.text.trim());
      if (fuel != null) {
        return l10n.rangeRingSuggestedNameFuel(
          modeLabel,
          _trimNumber(fuel),
          _fuelUnit.shortLabel(l10n),
        );
      }
    }
    final hours = _durationHours;
    if (hours != null) {
      return l10n.rangeRingSuggestedNameDuration(
        modeLabel,
        _trimNumber(hours),
      );
    }
    return l10n.rangeRingSuggestedNameMode(modeLabel);
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final center = _center;
    final radius = _radiusMeters;
    if (center == null || radius == null || radius < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rangeRingInvalidInput)),
      );
      return;
    }

    final assumptions = _assumptionsFromFields();
    final spec = RangeRingSpec(
      mode: _mode,
      basis: _basis,
      assumptions: assumptions,
      anchor: _anchor,
      markerId: _anchor == RangeRingAnchor.marker
          ? widget.selectedMarkerId
          : null,
      durationHours: _basis == RangeRingBasis.duration ? _durationHours : null,
      fuelLiters: _basis == RangeRingBasis.fuel ? _fuelLiters : null,
    );

    Navigator.of(context).pop(
      RangeRingDialogResult(
        center: center,
        radiusMeters: radius,
        spec: spec,
        suggestedName: _suggestedName(l10n),
      ),
    );
  }

  String _trimNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final anchors = _availableAnchors;
    final radius = _radiusMeters;
    final usesFuel = rangeRingModeUsesFuel(_mode);

    return AlertDialog(
      title: Text(l10n.rangeRingTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.rangeRingHelp,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.rangeRingCenterLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (anchors.isEmpty)
                Text(
                  l10n.rangeRingNoCenter,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                )
              else
                SegmentedButton<RangeRingAnchor>(
                  segments: [
                    for (final anchor in anchors)
                      ButtonSegment(
                        value: anchor,
                        label: Text(_anchorLabel(l10n, anchor)),
                        icon: Icon(_anchorIcon(anchor)),
                      ),
                  ],
                  selected: {_anchor},
                  onSelectionChanged: (value) {
                    setState(() => _anchor = value.single);
                  },
                ),
              if (_anchor == RangeRingAnchor.marker &&
                  widget.selectedMarkerName != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.selectedMarkerName!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<TrackTransportationMode>(
                key: ValueKey(_mode),
                initialValue: _mode,
                decoration: InputDecoration(
                  labelText: l10n.rangeRingModeLabel,
                ),
                items: [
                  for (final mode in rangeRingModes)
                    DropdownMenuItem(
                      value: mode,
                      child: Row(
                        children: [
                          TrackTransportationIcon(mode, size: 20),
                          const SizedBox(width: 12),
                          Text(mode.label(l10n)),
                        ],
                      ),
                    ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    _applyMode(mode);
                  }
                },
              ),
              if (usesFuel) ...[
                const SizedBox(height: 16),
                SegmentedButton<RangeRingBasis>(
                  segments: [
                    ButtonSegment(
                      value: RangeRingBasis.duration,
                      label: Text(l10n.rangeRingBasisDuration),
                      icon: const Icon(Icons.schedule),
                    ),
                    ButtonSegment(
                      value: RangeRingBasis.fuel,
                      label: Text(l10n.rangeRingBasisFuel),
                      icon: const Icon(Icons.local_gas_station),
                    ),
                  ],
                  selected: {_basis},
                  onSelectionChanged: (value) {
                    setState(() => _basis = value.single);
                  },
                ),
              ],
              const SizedBox(height: 16),
              if (_basis == RangeRingBasis.duration || !usesFuel)
                TextField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: l10n.rangeRingDurationHoursLabel,
                    helperText: l10n.rangeRingDurationHelp(
                      _trimNumber(_assumptionsFromFields().speedKmh),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => setState(() {}),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fuelController,
                        decoration: InputDecoration(
                          labelText: l10n.rangeRingFuelAmountLabel,
                          helperText: () {
                            final tank = _assumptionsFromFields().tankLiters;
                            if (tank == null) {
                              return null;
                            }
                            return l10n.rangeRingFuelTankHelp(
                              _trimNumber(
                                litersToFuelVolume(tank, _fuelUnit),
                              ),
                              _fuelUnit.shortLabel(l10n),
                            );
                          }(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: DropdownButtonFormField<FuelVolumeUnit>(
                        initialValue: _fuelUnit,
                        decoration: InputDecoration(
                          labelText: l10n.rangeRingFuelUnitLabel,
                        ),
                        items: [
                          for (final unit in FuelVolumeUnit.values)
                            DropdownMenuItem(
                              value: unit,
                              child: Text(unit.shortLabel(l10n)),
                            ),
                        ],
                        onChanged: (unit) {
                          if (unit == null || unit == _fuelUnit) {
                            return;
                          }
                          final currentLiters = _fuelLiters;
                          setState(() {
                            _fuelUnit = unit;
                            if (currentLiters != null) {
                              _fuelController.text = _trimNumber(
                                litersToFuelVolume(currentLiters, unit),
                              );
                            }
                            _syncAssumptionFields();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(l10n.rangeRingAssumptionsTitle),
                children: [
                  TextField(
                    controller: _speedController,
                    decoration: InputDecoration(
                      labelText: l10n.rangeRingSpeedKmhLabel,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  if (usesFuel) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _economyController,
                      decoration: InputDecoration(
                        labelText: l10n.rangeRingEconomyLabel,
                        helperText: l10n.rangeRingEconomyHelp,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tankController,
                      decoration: InputDecoration(
                        labelText: l10n.rangeRingTankLabel(
                          _fuelUnit.shortLabel(l10n),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          final tank =
                              _assumptionsFromFields().tankLiters ??
                              defaultRangeRingAssumptions(_mode).tankLiters;
                          if (tank == null) {
                            return;
                          }
                          setState(() {
                            _fuelController.text = _trimNumber(
                              litersToFuelVolume(tank, _fuelUnit),
                            );
                          });
                        },
                        child: Text(l10n.rangeRingUseFullTank),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    radius == null
                        ? l10n.rangeRingPreviewEmpty
                        : l10n.rangeRingPreviewRadius(
                            formatLineDistance(
                              radius,
                              widget.measurementUnits,
                            ),
                          ),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: anchors.isEmpty ? null : _submit,
          child: Text(l10n.rangeRingContinue),
        ),
      ],
    );
  }

  String _anchorLabel(AppLocalizations l10n, RangeRingAnchor anchor) {
    return switch (anchor) {
      RangeRingAnchor.marker => l10n.rangeRingCenterMarker,
      RangeRingAnchor.home => l10n.rangeRingCenterHome,
      RangeRingAnchor.point => l10n.rangeRingCenterMapPoint,
    };
  }

  IconData _anchorIcon(RangeRingAnchor anchor) {
    return switch (anchor) {
      RangeRingAnchor.marker => Icons.place_outlined,
      RangeRingAnchor.home => Icons.home_outlined,
      RangeRingAnchor.point => Icons.my_location,
    };
  }
}
