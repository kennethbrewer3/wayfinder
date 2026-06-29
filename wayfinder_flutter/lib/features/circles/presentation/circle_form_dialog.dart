import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/core/l10n/localized_labels.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/coordinate_form_fields.dart';
import '../../layers/presentation/layer_picker_field.dart';
import '../../lines/models/measurement_units.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../../markers/presentation/marker_notes_editor.dart';
import '../models/circle_size_display.dart';
import '../utils/circle_distance.dart';

class CircleFormData {
  const CircleFormData({
    required this.name,
    required this.notes,
    required this.center,
    required this.radiusMeters,
    required this.centerMarkerColor,
    required this.borderColor,
    required this.fillColor,
    required this.sizeDisplay,
    required this.showNameLabel,
    required this.layerId,
  });

  final String name;
  final String? notes;
  final LatLng center;
  final double radiusMeters;
  final Color centerMarkerColor;
  final Color borderColor;
  final Color fillColor;
  final CircleSizeDisplay sizeDisplay;
  final bool showNameLabel;
  final UuidValue? layerId;
}

Future<CircleFormData?> showCircleFormDialog({
  required BuildContext context,
  required LatLng center,
  required double radiusMeters,
  required MeasurementUnits measurementUnits,
  CircleSizeDisplay initialSizeDisplay = CircleSizeDisplay.radius,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialCenterMarkerColor,
  Color? initialBorderColor,
  Color? initialFillColor,
  bool initialShowNameLabel = false,
  UuidValue? initialLayerId,
}) {
  return showDialog<CircleFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return CircleFormDialog(
        title: title ?? l10n.circleCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.circleDefaultName,
        center: center,
        radiusMeters: radiusMeters,
        measurementUnits: measurementUnits,
        initialSizeDisplay: initialSizeDisplay,
        initialNotes: initialNotes,
        initialCenterMarkerColor:
            initialCenterMarkerColor ?? parseMarkerColor('#1B4965'),
        initialBorderColor: initialBorderColor ?? parseMarkerColor('#1B4965'),
        initialFillColor:
            initialFillColor ?? parseMarkerColor('#1B496540'),
        initialShowNameLabel: initialShowNameLabel,
        initialLayerId: initialLayerId,
      );
    },
  );
}

class CircleFormDialog extends StatefulWidget {
  const CircleFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.center,
    required this.radiusMeters,
    required this.measurementUnits,
    required this.initialSizeDisplay,
    required this.initialNotes,
    required this.initialCenterMarkerColor,
    required this.initialBorderColor,
    required this.initialFillColor,
    required this.initialShowNameLabel,
    this.initialLayerId,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final LatLng center;
  final double radiusMeters;
  final MeasurementUnits measurementUnits;
  final CircleSizeDisplay initialSizeDisplay;
  final String? initialNotes;
  final Color initialCenterMarkerColor;
  final Color initialBorderColor;
  final Color initialFillColor;
  final bool initialShowNameLabel;
  final UuidValue? initialLayerId;

  @override
  State<CircleFormDialog> createState() => _CircleFormDialogState();
}

class _CircleFormDialogState extends State<CircleFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _sizeController;
  late final QuillController _notesController;
  late Color _centerMarkerColor;
  late Color _borderColor;
  late Color _fillColor;
  late CircleSizeDisplay _sizeDisplay;
  late bool _showNameLabel;
  late bool _sizeInputIsDiameter;
  UuidValue? _selectedLayerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _latitudeController = TextEditingController(
      text: formatCoordinateField(widget.center.latitude),
    );
    _longitudeController = TextEditingController(
      text: formatCoordinateField(widget.center.longitude),
    );
    _sizeInputIsDiameter = false;
    _sizeController = TextEditingController(
      text: formatCircleSizeFieldValue(
        widget.radiusMeters,
        widget.measurementUnits,
        asDiameter: _sizeInputIsDiameter,
      ),
    );
    _notesController = createMarkerNotesController(
      markdown: widget.initialNotes,
    );
    _centerMarkerColor = widget.initialCenterMarkerColor;
    _borderColor = widget.initialBorderColor;
    _fillColor = widget.initialFillColor;
    _sizeDisplay = widget.initialSizeDisplay;
    _showNameLabel = widget.initialShowNameLabel;
    _selectedLayerId = widget.initialLayerId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSizeInputModeChanged(bool isDiameter) {
    final radiusMeters = parseCircleSizeFieldValue(
          _sizeController.text,
          widget.measurementUnits,
          asDiameter: _sizeInputIsDiameter,
        ) ??
        widget.radiusMeters;
    setState(() {
      _sizeInputIsDiameter = isDiameter;
      _sizeController.text = formatCircleSizeFieldValue(
        radiusMeters,
        widget.measurementUnits,
        asDiameter: isDiameter,
      );
    });
  }

  String _sizeFieldLabel(AppLocalizations l10n) {
    final unit = switch (widget.measurementUnits) {
      MeasurementUnits.metric => 'm',
      MeasurementUnits.imperial => 'ft',
      MeasurementUnits.nautical => 'nm',
    };
    final dimension = _sizeInputIsDiameter
        ? l10n.circleSizeDiameter
        : l10n.circleSizeRadius;
    return '$dimension ($unit)';
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final center = parseLatLngFields(
      _latitudeController.text,
      _longitudeController.text,
    );
    if (center == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionInvalidCoordinates)),
      );
      return;
    }

    final radiusMeters = parseCircleSizeFieldValue(
      _sizeController.text,
      widget.measurementUnits,
      asDiameter: _sizeInputIsDiameter,
    );
    if (radiusMeters == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.circleInvalidSize)),
      );
      return;
    }

    final notes = markerNotesToMarkdown(_notesController);
    Navigator.of(context).pop(
      CircleFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        center: center,
        radiusMeters: radiusMeters,
        centerMarkerColor: _centerMarkerColor,
        borderColor: _borderColor,
        fillColor: _fillColor,
        sizeDisplay: _sizeDisplay,
        showNameLabel: _showNameLabel,
        layerId: _selectedLayerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.formNameLabel,
                  hintText: l10n.circleNameHint,
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              LayerPickerField(
                selectedLayerId: _selectedLayerId,
                onChanged: (layerId) =>
                    setState(() => _selectedLayerId = layerId),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.circleMeasurementsLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.circleSizeRadius),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.circleSizeDiameter),
                  ),
                ],
                selected: {_sizeInputIsDiameter},
                onSelectionChanged: (selection) {
                  _onSizeInputModeChanged(selection.first);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sizeController,
                decoration: InputDecoration(
                  labelText: _sizeFieldLabel(l10n),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CoordinateFormFields(
                title: l10n.circleCenterLabel,
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                helperText: l10n.circleCenterMoveHelp,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.circleSizeLabelOnMap,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<CircleSizeDisplay>(
                segments: CircleSizeDisplay.values
                    .map(
                      (display) => ButtonSegment(
                        value: display,
                        label: Text(display.localizedShortLabel(l10n)),
                        tooltip: display.localizedLabel(l10n),
                      ),
                    )
                    .toList(),
                selected: {_sizeDisplay},
                onSelectionChanged: (selection) {
                  setState(() => _sizeDisplay = selection.first);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.formShowNameOnMap),
                value: _showNameLabel,
                onChanged: (value) => setState(() => _showNameLabel = value),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.circleCenterMarkerLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              MarkerColorPickerField(
                color: _centerMarkerColor,
                onChanged: (color) =>
                    setState(() => _centerMarkerColor = color),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.formBorderColorLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              MarkerColorPickerField(
                color: _borderColor,
                onChanged: (color) => setState(() => _borderColor = color),
              ),
              const SizedBox(height: 16),
              _FillColorPickerField(
                color: _fillColor,
                onChanged: (color) => setState(() => _fillColor = color),
              ),
              const SizedBox(height: 16),
              MarkerNotesEditor(controller: _notesController),
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
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _FillColorPickerField extends StatelessWidget {
  const _FillColorPickerField({
    required this.color,
    required this.onChanged,
  });

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.formFillColorLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.formFillOpacityHelp,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ColorPicker(
          color: color,
          onColorChanged: onChanged,
          width: 32,
          height: 32,
          borderRadius: 8,
          spacing: 8,
          runSpacing: 8,
          enableOpacity: true,
          pickersEnabled: const {
            ColorPickerType.wheel: true,
            ColorPickerType.primary: true,
            ColorPickerType.accent: true,
          },
          pickerTypeLabels: {
            ColorPickerType.wheel: l10n.themePreviewOutline,
            ColorPickerType.primary: l10n.themePreviewPrimary,
            ColorPickerType.accent: l10n.themePreviewAccent,
          },
        ),
      ],
    );
  }
}
