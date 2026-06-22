import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/core/l10n/localized_labels.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/coordinate_form_fields.dart';
import '../../layers/presentation/layer_picker_field.dart';
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
    required this.layerId,
    required this.start,
    required this.end,
  });

  final String name;
  final String? notes;
  final Color color;
  final LineBorderPattern borderPattern;
  final bool showArrows;
  final UuidValue? layerId;
  final LatLng start;
  final LatLng end;
}

Future<LineFormData?> showLineFormDialog({
  required BuildContext context,
  required LatLng start,
  required LatLng end,
  required MeasurementUnits measurementUnits,
  double? pathLengthMeters,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialColor,
  LineBorderPattern initialBorderPattern = LineBorderPattern.solid,
  bool initialShowArrows = true,
  UuidValue? initialLayerId,
}) {
  return showDialog<LineFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return LineFormDialog(
        title: title ?? l10n.lineCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.lineDefaultName,
        start: start,
        end: end,
        pathLengthMeters: pathLengthMeters,
        measurementUnits: measurementUnits,
        initialNotes: initialNotes,
        initialColor: initialColor ?? parseMarkerColor('#1B4965'),
        initialBorderPattern: initialBorderPattern,
        initialShowArrows: initialShowArrows,
        initialLayerId: initialLayerId,
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
    this.pathLengthMeters,
    required this.measurementUnits,
    required this.initialNotes,
    required this.initialColor,
    required this.initialBorderPattern,
    required this.initialShowArrows,
    this.initialLayerId,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final LatLng start;
  final LatLng end;
  final double? pathLengthMeters;
  final MeasurementUnits measurementUnits;
  final String? initialNotes;
  final Color initialColor;
  final LineBorderPattern initialBorderPattern;
  final bool initialShowArrows;
  final UuidValue? initialLayerId;

  @override
  State<LineFormDialog> createState() => _LineFormDialogState();
}

class _LineFormDialogState extends State<LineFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _startLatitudeController;
  late final TextEditingController _startLongitudeController;
  late final TextEditingController _endLatitudeController;
  late final TextEditingController _endLongitudeController;
  late final QuillController _notesController;
  late Color _selectedColor;
  late LineBorderPattern _borderPattern;
  late bool _showArrows;
  UuidValue? _selectedLayerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _startLatitudeController = TextEditingController(
      text: formatCoordinateField(widget.start.latitude),
    );
    _startLongitudeController = TextEditingController(
      text: formatCoordinateField(widget.start.longitude),
    );
    _endLatitudeController = TextEditingController(
      text: formatCoordinateField(widget.end.latitude),
    );
    _endLongitudeController = TextEditingController(
      text: formatCoordinateField(widget.end.longitude),
    );
    _notesController = createMarkerNotesController(
      markdown: widget.initialNotes,
    );
    _selectedColor = widget.initialColor;
    _borderPattern = widget.initialBorderPattern;
    _showArrows = widget.initialShowArrows;
    _selectedLayerId = widget.initialLayerId;
    for (final controller in [
      _startLatitudeController,
      _startLongitudeController,
      _endLatitudeController,
      _endLongitudeController,
    ]) {
      controller.addListener(_onCoordinatesChanged);
    }
  }

  void _onCoordinatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startLatitudeController.dispose();
    _startLongitudeController.dispose();
    _endLatitudeController.dispose();
    _endLongitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final start = parseLatLngFields(
      _startLatitudeController.text,
      _startLongitudeController.text,
    );
    final end = parseLatLngFields(
      _endLatitudeController.text,
      _endLongitudeController.text,
    );
    if (start == null || end == null) {
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
        layerId: _selectedLayerId,
        start: start,
        end: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final start = parseLatLngFields(
      _startLatitudeController.text,
      _startLongitudeController.text,
    );
    final end = parseLatLngFields(
      _endLatitudeController.text,
      _endLongitudeController.text,
    );
    final distanceMeters = start != null && end != null
        ? lineLengthMeters(start, end)
        : null;
    final distanceLabel = distanceMeters == null
        ? '—'
        : formatLineDistance(distanceMeters, widget.measurementUnits);

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
                  hintText: l10n.lineNameHint,
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
                title: Text(l10n.lineDistanceLabel),
                trailing: Text(
                  distanceLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              CoordinateFormFields(
                title: l10n.lineStartPointLabel,
                latitudeController: _startLatitudeController,
                longitudeController: _startLongitudeController,
              ),
              const SizedBox(height: 16),
              CoordinateFormFields(
                title: l10n.lineEndPointLabel,
                latitudeController: _endLatitudeController,
                longitudeController: _endLongitudeController,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lineStyleLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<LineBorderPattern>(
                segments: [
                  ButtonSegment(
                    value: LineBorderPattern.solid,
                    label: Text(l10n.lineBorderSolid),
                    icon: const Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: LineBorderPattern.dashed,
                    label: Text(l10n.lineBorderDashed),
                    icon: const Icon(Icons.more_horiz),
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
                title: Text(l10n.lineDirectionArrowsTitle),
                subtitle: Text(l10n.lineDirectionArrowsSubtitle),
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
