import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../layers/presentation/layer_picker_field.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../models/track_geometry.dart';

class TrackFormData {
  const TrackFormData({
    required this.name,
    required this.color,
    required this.showFootsteps,
    required this.layerId,
  });

  final String name;
  final Color color;
  final bool showFootsteps;
  final UuidValue? layerId;
}

Future<TrackFormData?> showTrackFormDialog({
  required BuildContext context,
  required MapZone zone,
  required TrackGeometry geometry,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<TrackFormData>(
    context: context,
    builder: (context) => TrackFormDialog(
      title: l10n.trackEditTitle,
      confirmLabel: l10n.actionSave,
      defaultName: zone.name,
      initialColor: parseMarkerColor(zone.color),
      initialShowFootsteps: geometry.showFootsteps,
      initialLayerId: zone.layerId,
    ),
  );
}

class TrackFormDialog extends StatefulWidget {
  const TrackFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.initialColor,
    required this.initialShowFootsteps,
    this.initialLayerId,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final Color initialColor;
  final bool initialShowFootsteps;
  final UuidValue? initialLayerId;

  @override
  State<TrackFormDialog> createState() => _TrackFormDialogState();
}

class _TrackFormDialogState extends State<TrackFormDialog> {
  late final TextEditingController _nameController;
  late Color _selectedColor;
  late bool _showFootsteps;
  UuidValue? _selectedLayerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _selectedColor = widget.initialColor;
    _showFootsteps = widget.initialShowFootsteps;
    _selectedLayerId = widget.initialLayerId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      TrackFormData(
        name: name,
        color: _selectedColor,
        showFootsteps: _showFootsteps,
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
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.formNameLabel,
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
              MarkerColorPickerField(
                color: _selectedColor,
                onChanged: (color) => setState(() => _selectedColor = color),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.trackShowFootstepsLabel),
                subtitle: Text(l10n.trackShowFootstepsHelp),
                value: _showFootsteps,
                onChanged: (value) => setState(() => _showFootsteps = value),
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
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
