import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

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
  });

  final String name;
  final String? notes;
  final Color centerMarkerColor;
  final Color borderColor;
  final Color fillColor;
  final RectangleSizeDisplay sizeDisplay;
  final bool showNameLabel;
  final UuidValue? layerId;
}

Future<RectangleFormData?> showRectangleFormDialog({
  required BuildContext context,
  required RectangleCreationMode creationMode,
  required RectangleBounds bounds,
  required MeasurementUnits measurementUnits,
  RectangleSizeDisplay initialSizeDisplay = RectangleSizeDisplay.dimensions,
  String title = 'Create rectangle',
  String confirmLabel = 'Create',
  String defaultName = 'New rectangle',
  String? initialNotes,
  Color? initialCenterMarkerColor,
  Color? initialBorderColor,
  Color? initialFillColor,
  bool initialShowNameLabel = false,
  UuidValue? initialLayerId,
}) {
  return showDialog<RectangleFormData>(
    context: context,
    builder: (context) {
      return RectangleFormDialog(
        title: title,
        confirmLabel: confirmLabel,
        defaultName: defaultName,
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

  @override
  State<RectangleFormDialog> createState() => _RectangleFormDialogState();
}

class _RectangleFormDialogState extends State<RectangleFormDialog> {
  late final TextEditingController _nameController;
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
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimensionsLabel = formatRectangleDimensions(
      widget.bounds,
      widget.measurementUnits,
    );
    final areaLabel = formatRectangleArea(
      widget.bounds,
      widget.measurementUnits,
    );
    final center = widget.bounds.center;

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
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Search area, Property boundary',
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
                title: Text(widget.creationMode.label),
                subtitle: Text(
                  '${center.latitude.toStringAsFixed(5)}, '
                  '${center.longitude.toStringAsFixed(5)}',
                ),
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
              Text(
                'Size label on map',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<RectangleSizeDisplay>(
                segments: RectangleSizeDisplay.values
                    .map(
                      (display) => ButtonSegment(
                        value: display,
                        label: Text(display.shortLabel),
                        tooltip: display.label,
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
                title: const Text('Show name on map'),
                value: _showNameLabel,
                onChanged: (value) => setState(() => _showNameLabel = value),
              ),
              if (widget.creationMode == RectangleCreationMode.centerExtent) ...[
                const SizedBox(height: 16),
                Text(
                  'Center marker',
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
                'Border color',
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
          child: const Text('Cancel'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fill color',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Adjust opacity to control fill transparency.',
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
          pickerTypeLabels: const {
            ColorPickerType.wheel: 'Wheel',
            ColorPickerType.primary: 'Primary',
            ColorPickerType.accent: 'Accent',
          },
        ),
      ],
    );
  }
}
