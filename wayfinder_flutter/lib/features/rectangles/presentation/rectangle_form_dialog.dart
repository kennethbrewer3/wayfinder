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
import '../models/rectangle_geometry.dart';
import '../models/rectangle_size_display.dart';
import '../utils/rectangle_bounds.dart';
import '../utils/rectangle_dimensions.dart';

class RectangleFormData {
  const RectangleFormData({
    required this.name,
    required this.notes,
    required this.centerMarkerColor,
    required this.borderColor,
    required this.fillColor,
    required this.sizeDisplay,
    required this.showNameLabel,
    required this.layerId,
    this.center,
    this.cornerA,
    this.cornerB,
  });

  final String name;
  final String? notes;
  final Color centerMarkerColor;
  final Color borderColor;
  final Color fillColor;
  final RectangleSizeDisplay sizeDisplay;
  final bool showNameLabel;
  final UuidValue? layerId;
  final LatLng? center;
  final LatLng? cornerA;
  final LatLng? cornerB;
}

Future<RectangleFormData?> showRectangleFormDialog({
  required BuildContext context,
  required RectangleCreationMode creationMode,
  required RectangleBounds bounds,
  required MeasurementUnits measurementUnits,
  RectangleSizeDisplay initialSizeDisplay = RectangleSizeDisplay.dimensions,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialCenterMarkerColor,
  Color? initialBorderColor,
  Color? initialFillColor,
  bool initialShowNameLabel = false,
  UuidValue? initialLayerId,
  LatLng? initialCenter,
  LatLng? initialCornerA,
  LatLng? initialCornerB,
}) {
  return showDialog<RectangleFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return RectangleFormDialog(
        title: title ?? l10n.rectangleCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.rectangleDefaultName,
        creationMode: creationMode,
        bounds: bounds,
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
        initialCenter: initialCenter,
        initialCornerA: initialCornerA,
        initialCornerB: initialCornerB,
      );
    },
  );
}

class RectangleFormDialog extends StatefulWidget {
  const RectangleFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.creationMode,
    required this.bounds,
    required this.measurementUnits,
    required this.initialSizeDisplay,
    required this.initialNotes,
    required this.initialCenterMarkerColor,
    required this.initialBorderColor,
    required this.initialFillColor,
    required this.initialShowNameLabel,
    this.initialLayerId,
    this.initialCenter,
    this.initialCornerA,
    this.initialCornerB,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final RectangleCreationMode creationMode;
  final RectangleBounds bounds;
  final MeasurementUnits measurementUnits;
  final RectangleSizeDisplay initialSizeDisplay;
  final String? initialNotes;
  final Color initialCenterMarkerColor;
  final Color initialBorderColor;
  final Color initialFillColor;
  final bool initialShowNameLabel;
  final UuidValue? initialLayerId;
  final LatLng? initialCenter;
  final LatLng? initialCornerA;
  final LatLng? initialCornerB;

  @override
  State<RectangleFormDialog> createState() => _RectangleFormDialogState();
}

class _RectangleFormDialogState extends State<RectangleFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController? _centerLatitudeController;
  late final TextEditingController? _centerLongitudeController;
  late final TextEditingController? _cornerALatitudeController;
  late final TextEditingController? _cornerALongitudeController;
  late final TextEditingController? _cornerBLatitudeController;
  late final TextEditingController? _cornerBLongitudeController;
  late final QuillController _notesController;
  late Color _centerMarkerColor;
  late Color _borderColor;
  late Color _fillColor;
  late RectangleSizeDisplay _sizeDisplay;
  late bool _showNameLabel;
  UuidValue? _selectedLayerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    if (widget.creationMode == RectangleCreationMode.centerExtent) {
      final center = widget.initialCenter ?? widget.bounds.center;
      _centerLatitudeController = TextEditingController(
        text: formatCoordinateField(center.latitude),
      );
      _centerLongitudeController = TextEditingController(
        text: formatCoordinateField(center.longitude),
      );
      _cornerALatitudeController = null;
      _cornerALongitudeController = null;
      _cornerBLatitudeController = null;
      _cornerBLongitudeController = null;
    } else {
      final cornerA = widget.initialCornerA ??
          LatLng(widget.bounds.north, widget.bounds.west);
      final cornerB = widget.initialCornerB ??
          LatLng(widget.bounds.south, widget.bounds.east);
      _centerLatitudeController = null;
      _centerLongitudeController = null;
      _cornerALatitudeController = TextEditingController(
        text: formatCoordinateField(cornerA.latitude),
      );
      _cornerALongitudeController = TextEditingController(
        text: formatCoordinateField(cornerA.longitude),
      );
      _cornerBLatitudeController = TextEditingController(
        text: formatCoordinateField(cornerB.latitude),
      );
      _cornerBLongitudeController = TextEditingController(
        text: formatCoordinateField(cornerB.longitude),
      );
    }
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
    _centerLatitudeController?.dispose();
    _centerLongitudeController?.dispose();
    _cornerALatitudeController?.dispose();
    _cornerALongitudeController?.dispose();
    _cornerBLatitudeController?.dispose();
    _cornerBLongitudeController?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    LatLng? center;
    LatLng? cornerA;
    LatLng? cornerB;
    if (_centerLatitudeController != null && _centerLongitudeController != null) {
      center = parseLatLngFields(
        _centerLatitudeController!.text,
        _centerLongitudeController!.text,
      );
      if (center == null) {
        return;
      }
    } else if (_cornerALatitudeController != null &&
        _cornerALongitudeController != null &&
        _cornerBLatitudeController != null &&
        _cornerBLongitudeController != null) {
      cornerA = parseLatLngFields(
        _cornerALatitudeController!.text,
        _cornerALongitudeController!.text,
      );
      cornerB = parseLatLngFields(
        _cornerBLatitudeController!.text,
        _cornerBLongitudeController!.text,
      );
      if (cornerA == null || cornerB == null) {
        return;
      }
    }

    final notes = markerNotesToMarkdown(_notesController);
    Navigator.of(context).pop(
      RectangleFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        centerMarkerColor: _centerMarkerColor,
        borderColor: _borderColor,
        fillColor: _fillColor,
        sizeDisplay: _sizeDisplay,
        showNameLabel: _showNameLabel,
        layerId: _selectedLayerId,
        center: center,
        cornerA: cornerA,
        cornerB: cornerB,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dimensionsLabel = formatRectangleDimensions(
      widget.bounds,
      widget.measurementUnits,
    );
    final areaLabel = formatRectangleArea(
      widget.bounds,
      widget.measurementUnits,
    );

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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(widget.creationMode.localizedLabel(l10n)),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dimensionsLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      areaLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_centerLatitudeController != null &&
                  _centerLongitudeController != null)
                CoordinateFormFields(
                  title: l10n.circleCenterLabel,
                  latitudeController: _centerLatitudeController!,
                  longitudeController: _centerLongitudeController!,
                  helperText: l10n.rectangleCenterMoveHelp,
                )
              else if (_cornerALatitudeController != null &&
                  _cornerALongitudeController != null &&
                  _cornerBLatitudeController != null &&
                  _cornerBLongitudeController != null) ...[
                CoordinateFormFields(
                  title: l10n.rectangleCornerALabel,
                  latitudeController: _cornerALatitudeController!,
                  longitudeController: _cornerALongitudeController!,
                ),
                const SizedBox(height: 16),
                CoordinateFormFields(
                  title: l10n.rectangleCornerBLabel,
                  latitudeController: _cornerBLatitudeController!,
                  longitudeController: _cornerBLongitudeController!,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.circleSizeLabelOnMap,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<RectangleSizeDisplay>(
                segments: RectangleSizeDisplay.values
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
              if (widget.creationMode == RectangleCreationMode.centerExtent) ...[
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
              ],
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
