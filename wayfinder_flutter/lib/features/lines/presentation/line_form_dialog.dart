import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:latlong2/latlong.dart';

import '../../markers/models/marker_color.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../../markers/presentation/marker_notes_editor.dart';
import '../models/measurement_units.dart';
import '../utils/line_distance.dart';

enum LineBorderPattern {
  solid,
  dashed,
}

extension LineBorderPatternLabel on LineBorderPattern {
  String get storageValue => switch (this) {
        LineBorderPattern.solid => 'solid',
        LineBorderPattern.dashed => 'dashed',
      };

  String get label => switch (this) {
        LineBorderPattern.solid => 'Solid',
        LineBorderPattern.dashed => 'Dashed',
      };
}

LineBorderPattern lineBorderPatternFromStorage(String value) {
  return value == 'dashed'
      ? LineBorderPattern.dashed
      : LineBorderPattern.solid;
}

class LineFormData {
  const LineFormData({
    required this.name,
    required this.notes,
    required this.color,
    required this.borderPattern,
    required this.showArrows,
  });

  final String name;
  final String? notes;
  final Color color;
  final LineBorderPattern borderPattern;
  final bool showArrows;
}

Future<LineFormData?> showLineFormDialog({
  required BuildContext context,
  required LatLng start,
  required LatLng end,
  required MeasurementUnits measurementUnits,
  String title = 'Create line',
  String confirmLabel = 'Create',
  String defaultName = 'New line',
  String? initialNotes,
  Color? initialColor,
  LineBorderPattern initialBorderPattern = LineBorderPattern.solid,
  bool initialShowArrows = true,
}) {
  return showDialog<LineFormData>(
    context: context,
    builder: (context) {
      return LineFormDialog(
        title: title,
        confirmLabel: confirmLabel,
        defaultName: defaultName,
        start: start,
        end: end,
        measurementUnits: measurementUnits,
        initialNotes: initialNotes,
        initialColor: initialColor ?? parseMarkerColor('#1B4965'),
        initialBorderPattern: initialBorderPattern,
        initialShowArrows: initialShowArrows,
      );
    },
  );
}

class LineFormDialog extends StatefulWidget {
  const LineFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.start,
    required this.end,
    required this.measurementUnits,
    required this.initialNotes,
    required this.initialColor,
    required this.initialBorderPattern,
    required this.initialShowArrows,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final LatLng start;
  final LatLng end;
  final MeasurementUnits measurementUnits;
  final String? initialNotes;
  final Color initialColor;
  final LineBorderPattern initialBorderPattern;
  final bool initialShowArrows;

  @override
  State<LineFormDialog> createState() => _LineFormDialogState();
}

class _LineFormDialogState extends State<LineFormDialog> {
  late final TextEditingController _nameController;
  late final QuillController _notesController;
  late Color _selectedColor;
  late LineBorderPattern _borderPattern;
  late bool _showArrows;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _notesController = createMarkerNotesController(
      markdown: widget.initialNotes,
    );
    _selectedColor = widget.initialColor;
    _borderPattern = widget.initialBorderPattern;
    _showArrows = widget.initialShowArrows;
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
      LineFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        color: _selectedColor,
        borderPattern: _borderPattern,
        showArrows: _showArrows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distanceMeters = lineLengthMeters(widget.start, widget.end);
    final distanceLabel = formatLineDistance(
      distanceMeters,
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
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Route to camp, Property boundary',
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Distance'),
                subtitle: Text(
                  '${widget.start.latitude.toStringAsFixed(5)}, '
                  '${widget.start.longitude.toStringAsFixed(5)} → '
                  '${widget.end.latitude.toStringAsFixed(5)}, '
                  '${widget.end.longitude.toStringAsFixed(5)}',
                ),
                trailing: Text(
                  distanceLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Line style',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<LineBorderPattern>(
                segments: const [
                  ButtonSegment(
                    value: LineBorderPattern.solid,
                    label: Text('Solid'),
                    icon: Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: LineBorderPattern.dashed,
                    label: Text('Dashed'),
                    icon: Icon(Icons.more_horiz),
                  ),
                ],
                selected: {_borderPattern},
                onSelectionChanged: (selection) {
                  setState(() => _borderPattern = selection.first);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Direction arrows'),
                subtitle: const Text(
                  'Arrows point from the first point toward the second.',
                ),
                value: _showArrows,
                onChanged: (value) => setState(() => _showArrows = value),
              ),
              const SizedBox(height: 16),
              MarkerColorPickerField(
                color: _selectedColor,
                onChanged: (color) => setState(() => _selectedColor = color),
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
