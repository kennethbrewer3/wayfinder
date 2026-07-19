import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../layers/presentation/layer_picker_field.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../../markers/presentation/marker_notes_editor.dart';

class PolygonFormData {
  const PolygonFormData({
    required this.name,
    required this.notes,
    required this.borderColor,
    required this.fillColor,
    required this.showNameLabel,
    required this.layerId,
  });

  final String name;
  final String? notes;
  final Color borderColor;
  final Color fillColor;
  final bool showNameLabel;
  final UuidValue? layerId;
}

Future<PolygonFormData?> showPolygonFormDialog({
  required BuildContext context,
  required List<LatLng> points,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialBorderColor,
  Color? initialFillColor,
  bool initialShowNameLabel = false,
  UuidValue? initialLayerId,
}) {
  return showDialog<PolygonFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return PolygonFormDialog(
        title: title ?? l10n.polygonCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.polygonDefaultName,
        vertexCount: points.length,
        initialNotes: initialNotes,
        initialBorderColor: initialBorderColor ?? parseMarkerColor('#8B1E3F'),
        initialFillColor: initialFillColor ?? parseMarkerColor('#8B1E3F40'),
        initialShowNameLabel: initialShowNameLabel,
        initialLayerId: initialLayerId,
      );
    },
  );
}

class PolygonFormDialog extends StatefulWidget {
  const PolygonFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.vertexCount,
    required this.initialNotes,
    required this.initialBorderColor,
    required this.initialFillColor,
    required this.initialShowNameLabel,
    this.initialLayerId,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final int vertexCount;
  final String? initialNotes;
  final Color initialBorderColor;
  final Color initialFillColor;
  final bool initialShowNameLabel;
  final UuidValue? initialLayerId;

  @override
  State<PolygonFormDialog> createState() => _PolygonFormDialogState();
}

class _PolygonFormDialogState extends State<PolygonFormDialog> {
  late final TextEditingController _nameController;
  late final QuillController _notesController;
  late Color _borderColor;
  late Color _fillColor;
  late bool _showNameLabel;
  UuidValue? _selectedLayerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _notesController = createMarkerNotesController(
      markdown: widget.initialNotes,
    );
    _borderColor = widget.initialBorderColor;
    _fillColor = widget.initialFillColor;
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
      PolygonFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        borderColor: _borderColor,
        fillColor: _fillColor,
        showNameLabel: _showNameLabel,
        layerId: _selectedLayerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.formNameLabel,
                  hintText: l10n.polygonNameHint,
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.polygonVertexCount(widget.vertexCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              LayerPickerField(
                selectedLayerId: _selectedLayerId,
                onChanged: (layerId) =>
                    setState(() => _selectedLayerId = layerId),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.formShowNameOnMap),
                value: _showNameLabel,
                onChanged: (value) => setState(() => _showNameLabel = value),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.formBorderColorLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              MarkerColorPickerField(
                color: _borderColor,
                onChanged: (color) => setState(() => _borderColor = color),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.formFillColorLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.formFillOpacityHelp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ColorPicker(
                color: _fillColor,
                onColorChanged: (color) => setState(() => _fillColor = color),
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
