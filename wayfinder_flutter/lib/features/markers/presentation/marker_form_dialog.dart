import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../layers/presentation/layer_picker_field.dart';
import '../models/marker_color.dart';
import '../models/marker_icon_registry.dart';
import 'marker_form_fields.dart';
import 'marker_notes_editor.dart';

class MarkerFormData {
  const MarkerFormData({
    required this.name,
    required this.notes,
    required this.color,
    required this.icon,
    required this.elevation,
    required this.layerId,
  });

  final String name;
  final String? notes;
  final Color color;
  final String icon;
  final double elevation;
  final UuidValue? layerId;
}

Future<MarkerFormData?> showMarkerFormDialog({
  required BuildContext context,
  String title = 'Create marker',
  String confirmLabel = 'Create',
  String defaultName = 'New marker',
  String? initialNotes,
  Color? initialColor,
  String? initialIcon,
  double initialElevation = 0,
  UuidValue? initialLayerId,
}) {
  return showDialog<MarkerFormData>(
    context: context,
    builder: (context) {
      return MarkerFormDialog(
        title: title,
        confirmLabel: confirmLabel,
        defaultName: defaultName,
        initialNotes: initialNotes,
        initialColor: initialColor ?? parseMarkerColor('#1B4965'),
        initialIcon: normalizeMarkerIcon(initialIcon ?? 'place'),
        initialElevation: initialElevation,
        initialLayerId: initialLayerId,
      );
    },
  );
}

Future<MarkerFormData?> showEditMarkerDialog({
  required BuildContext context,
  required MapMarker marker,
}) {
  return showMarkerFormDialog(
    context: context,
    title: 'Edit marker',
    confirmLabel: 'Save',
    defaultName: marker.name,
    initialNotes: marker.notes,
    initialColor: parseMarkerColor(marker.color),
    initialIcon: marker.icon,
    initialElevation: marker.elevation,
    initialLayerId: marker.layerId,
  );
}

class MarkerFormDialog extends StatefulWidget {
  const MarkerFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.initialNotes,
    required this.initialColor,
    required this.initialIcon,
    required this.initialElevation,
    this.initialLayerId,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final String? initialNotes;
  final Color initialColor;
  final String initialIcon;
  final double initialElevation;
  final UuidValue? initialLayerId;

  @override
  State<MarkerFormDialog> createState() => _MarkerFormDialogState();
}

class _MarkerFormDialogState extends State<MarkerFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _elevationController;
  late final QuillController _notesController;
  late Color _selectedColor;
  late String _selectedIcon;
  UuidValue? _selectedLayerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _nameController.addListener(_maybeSuggestIconFromName);
    _elevationController = TextEditingController(
      text: _formatElevationInput(widget.initialElevation),
    );
    _notesController = createMarkerNotesController(
      markdown: widget.initialNotes,
    );
    _selectedColor = widget.initialColor;
    _selectedIcon = widget.initialIcon;
    _selectedLayerId = widget.initialLayerId;
  }

  void _maybeSuggestIconFromName() {
    final suggested = suggestMarkerIconForName(_nameController.text);
    if (suggested == null || suggested == _selectedIcon) {
      return;
    }
    if (_selectedIcon != widget.initialIcon && _selectedIcon != 'place') {
      return;
    }
    setState(() => _selectedIcon = suggested);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _elevationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatElevationInput(double elevation) {
    if (elevation == elevation.roundToDouble()) {
      return elevation.toInt().toString();
    }
    return elevation.toString();
  }

  double? _parseElevation() {
    final raw = _elevationController.text.trim();
    if (raw.isEmpty) {
      return 0;
    }
    return double.tryParse(raw);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final elevation = _parseElevation();
    if (elevation == null) {
      return;
    }

    final notes = markerNotesToMarkdown(_notesController);
    Navigator.of(context).pop(
      MarkerFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        color: _selectedColor,
        icon: _selectedIcon,
        elevation: elevation,
        layerId: _selectedLayerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  hintText: 'e.g. Home, Work, Trailhead',
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _elevationController,
                decoration: const InputDecoration(
                  labelText: 'Elevation (m)',
                  hintText: '0',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              LayerPickerField(
                selectedLayerId: _selectedLayerId,
                onChanged: (layerId) =>
                    setState(() => _selectedLayerId = layerId),
              ),
              const SizedBox(height: 16),
              MarkerIconPicker(
                selectedIcon: _selectedIcon,
                color: _selectedColor,
                onChanged: (icon) => setState(() => _selectedIcon = icon),
              ),
              const SizedBox(height: 16),
              MarkerColorPickerField(
                color: _selectedColor,
                onChanged: (color) => setState(() => _selectedColor = color),
              ),
              const SizedBox(height: 16),
              MarkerPreview(
                color: _selectedColor,
                iconName: _selectedIcon,
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
