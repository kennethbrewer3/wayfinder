import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../lines/models/distance_input_unit.dart';
import '../../lines/models/measurement_units.dart';
import '../models/coverage_plan.dart';

class CoveragePlanDialogResult {
  const CoveragePlanDialogResult({required this.spec});

  final CoveragePlanSpec spec;
}

Future<CoveragePlanDialogResult?> showCoveragePlanDialog({
  required BuildContext context,
  required MeasurementUnits measurementUnits,
  LatLng? selectedMarkerCenter,
  String? selectedMarkerName,
  LatLng? homeCenter,
  LatLng? mapPoint,
}) {
  return showDialog<CoveragePlanDialogResult>(
    context: context,
    builder: (context) {
      return CoveragePlanDialog(
        measurementUnits: measurementUnits,
        selectedMarkerCenter: selectedMarkerCenter,
        selectedMarkerName: selectedMarkerName,
        homeCenter: homeCenter,
        mapPoint: mapPoint,
      );
    },
  );
}

enum _CoverageAnchor { marker, home, point }

class CoveragePlanDialog extends StatefulWidget {
  const CoveragePlanDialog({
    super.key,
    required this.measurementUnits,
    this.selectedMarkerCenter,
    this.selectedMarkerName,
    this.homeCenter,
    this.mapPoint,
  });

  final MeasurementUnits measurementUnits;
  final LatLng? selectedMarkerCenter;
  final String? selectedMarkerName;
  final LatLng? homeCenter;
  final LatLng? mapPoint;

  @override
  State<CoveragePlanDialog> createState() => _CoveragePlanDialogState();
}

class _CoveragePlanDialogState extends State<CoveragePlanDialog> {
  late CoverageTemplateKind _template;
  late CoverageLayoutKind _layout;
  late _CoverageAnchor _anchor;
  late DistanceInputUnit _distanceUnit;
  late final TextEditingController _radiusController;
  late final TextEditingController _spacingController;
  bool _createMarkers = true;
  bool _createCircles = true;
  bool _runViewshedOnSeed = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _template = CoverageTemplateKind.mesh;
    _layout = CoverageLayoutKind.hexRing;
    _anchor = _defaultAnchor();
    _distanceUnit = switch (widget.measurementUnits) {
      MeasurementUnits.metric => DistanceInputUnit.kilometers,
      MeasurementUnits.imperial ||
      MeasurementUnits.nautical => DistanceInputUnit.miles,
    };
    _radiusController = TextEditingController(
      text: formatDistanceInputFieldValue(
        _template.defaultCoverageRadiusMeters,
        _distanceUnit,
      ),
    );
    _spacingController = TextEditingController(
      text: formatDistanceInputFieldValue(
        _template.defaultSpacingMeters,
        _distanceUnit,
      ),
    );
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _spacingController.dispose();
    super.dispose();
  }

  _CoverageAnchor _defaultAnchor() {
    if (widget.selectedMarkerCenter != null) {
      return _CoverageAnchor.marker;
    }
    if (widget.mapPoint != null) {
      return _CoverageAnchor.point;
    }
    return _CoverageAnchor.home;
  }

  LatLng? _centerForAnchor(_CoverageAnchor anchor) {
    return switch (anchor) {
      _CoverageAnchor.marker => widget.selectedMarkerCenter,
      _CoverageAnchor.home => widget.homeCenter,
      _CoverageAnchor.point => widget.mapPoint,
    };
  }

  void _applyTemplateDefaults(CoverageTemplateKind template) {
    _radiusController.text = formatDistanceInputFieldValue(
      template.defaultCoverageRadiusMeters,
      _distanceUnit,
    );
    _spacingController.text = formatDistanceInputFieldValue(
      template.defaultSpacingMeters,
      _distanceUnit,
    );
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final center = _centerForAnchor(_anchor);
    if (center == null) {
      setState(() => _error = l10n.coveragePlanMissingCenter);
      return;
    }
    final radius = parseDistanceInputFieldValue(
      _radiusController.text,
      _distanceUnit,
    );
    final spacing = parseDistanceInputFieldValue(
      _spacingController.text,
      _distanceUnit,
    );
    if (radius == null || radius < 50 || radius > 100000) {
      setState(() => _error = l10n.coveragePlanInvalidRadius);
      return;
    }
    if (_layout == CoverageLayoutKind.hexRing &&
        (spacing == null || spacing < 50 || spacing > 100000)) {
      setState(() => _error = l10n.coveragePlanInvalidSpacing);
      return;
    }
    if (!_createMarkers && !_createCircles) {
      setState(() => _error = l10n.coveragePlanNeedOutput);
      return;
    }

    Navigator.of(context).pop(
      CoveragePlanDialogResult(
        spec: CoveragePlanSpec(
          template: _template,
          layout: _layout,
          seed: center,
          coverageRadiusMeters: radius,
          spacingMeters: spacing ?? _template.defaultSpacingMeters,
          createMarkers: _createMarkers,
          createCircles: _createCircles,
          runViewshedOnSeed: _runViewshedOnSeed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final siteCount = _layout == CoverageLayoutKind.single ? 1 : 7;

    return AlertDialog(
      title: Text(l10n.coveragePlanTitle),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.coveragePlanSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.coveragePlanTemplateLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in CoverageTemplateKind.values)
                    ChoiceChip(
                      label: Text(_templateLabel(l10n, kind)),
                      selected: _template == kind,
                      onSelected: (_) {
                        setState(() {
                          _template = kind;
                          _applyTemplateDefaults(kind);
                          _error = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.coveragePlanLayoutLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<CoverageLayoutKind>(
                segments: [
                  ButtonSegment(
                    value: CoverageLayoutKind.single,
                    label: Text(l10n.coveragePlanLayoutSingle),
                    icon: const Icon(Icons.radio_button_checked, size: 18),
                  ),
                  ButtonSegment(
                    value: CoverageLayoutKind.hexRing,
                    label: Text(l10n.coveragePlanLayoutHexRing),
                    icon: const Icon(Icons.hexagon_outlined, size: 18),
                  ),
                ],
                selected: {_layout},
                onSelectionChanged: (selected) {
                  setState(() {
                    _layout = selected.single;
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.coveragePlanAnchorLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.selectedMarkerCenter != null)
                    ChoiceChip(
                      label: Text(
                        widget.selectedMarkerName?.trim().isNotEmpty == true
                            ? l10n.coveragePlanAnchorMarkerNamed(
                                widget.selectedMarkerName!.trim(),
                              )
                            : l10n.coveragePlanAnchorMarker,
                      ),
                      selected: _anchor == _CoverageAnchor.marker,
                      onSelected: (_) {
                        setState(() {
                          _anchor = _CoverageAnchor.marker;
                          _error = null;
                        });
                      },
                    ),
                  if (widget.homeCenter != null)
                    ChoiceChip(
                      label: Text(l10n.coveragePlanAnchorHome),
                      selected: _anchor == _CoverageAnchor.home,
                      onSelected: (_) {
                        setState(() {
                          _anchor = _CoverageAnchor.home;
                          _error = null;
                        });
                      },
                    ),
                  if (widget.mapPoint != null)
                    ChoiceChip(
                      label: Text(l10n.coveragePlanAnchorMapPoint),
                      selected: _anchor == _CoverageAnchor.point,
                      onSelected: (_) {
                        setState(() {
                          _anchor = _CoverageAnchor.point;
                          _error = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _radiusController,
                decoration: InputDecoration(
                  labelText: l10n.coveragePlanRadiusLabel,
                  suffixText: _distanceUnit.shortLabel,
                  helperText: l10n.coveragePlanRadiusHelp,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              if (_layout == CoverageLayoutKind.hexRing) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _spacingController,
                  decoration: InputDecoration(
                    labelText: l10n.coveragePlanSpacingLabel,
                    suffixText: _distanceUnit.shortLabel,
                    helperText: l10n.coveragePlanSpacingHelp,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.coveragePlanCreateMarkers),
                value: _createMarkers,
                onChanged: (value) => setState(() {
                  _createMarkers = value;
                  _error = null;
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.coveragePlanCreateCircles),
                value: _createCircles,
                onChanged: (value) => setState(() {
                  _createCircles = value;
                  _error = null;
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.coveragePlanRunViewshed),
                subtitle: Text(l10n.coveragePlanRunViewshedHelp),
                value: _runViewshedOnSeed,
                onChanged: (value) => setState(() {
                  _runViewshedOnSeed = value;
                }),
              ),
              Text(
                l10n.coveragePlanSiteCount(siteCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
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
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.coveragePlanCreateAction),
        ),
      ],
    );
  }
}

String _templateLabel(AppLocalizations l10n, CoverageTemplateKind kind) {
  return switch (kind) {
    CoverageTemplateKind.mesh => l10n.coveragePlanTemplateMesh,
    CoverageTemplateKind.repeater => l10n.coveragePlanTemplateRepeater,
    CoverageTemplateKind.shack => l10n.coveragePlanTemplateShack,
  };
}
