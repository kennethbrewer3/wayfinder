import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../layers/presentation/layer_picker_field.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../../markers/presentation/marker_notes_editor.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../../tracks/presentation/track_transportation_icon.dart';
import '../utils/evac_kit_eta.dart';

class EvacKitFormData {
  const EvacKitFormData({
    required this.name,
    required this.notes,
    required this.color,
    required this.defaultMode,
    required this.showNameLabel,
    required this.layerId,
    required this.primaryRouteName,
  });

  final String name;
  final String? notes;
  final Color color;
  final TrackTransportationMode defaultMode;
  final bool showNameLabel;
  final UuidValue? layerId;
  final String primaryRouteName;
}

Future<EvacKitFormData?> showEvacKitFormDialog({
  required BuildContext context,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialColor,
  TrackTransportationMode initialDefaultMode = TrackTransportationMode.onFoot,
  bool initialShowNameLabel = true,
  UuidValue? initialLayerId,
  String? initialPrimaryRouteName,
  int waypointCount = 0,
  double? pathLengthMeters,
}) {
  return showDialog<EvacKitFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return EvacKitFormDialog(
        title: title ?? l10n.evacKitCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.evacKitDefaultName,
        initialNotes: initialNotes,
        initialColor: initialColor ?? parseMarkerColor('#B45309'),
        initialDefaultMode: initialDefaultMode,
        initialShowNameLabel: initialShowNameLabel,
        initialLayerId: initialLayerId,
        initialPrimaryRouteName:
            initialPrimaryRouteName ?? l10n.evacKitPrimaryRouteName,
        waypointCount: waypointCount,
        pathLengthMeters: pathLengthMeters,
      );
    },
  );
}

class EvacKitFormDialog extends StatefulWidget {
  const EvacKitFormDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.initialNotes,
    required this.initialColor,
    required this.initialDefaultMode,
    required this.initialShowNameLabel,
    this.initialLayerId,
    required this.initialPrimaryRouteName,
    required this.waypointCount,
    this.pathLengthMeters,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final String? initialNotes;
  final Color initialColor;
  final TrackTransportationMode initialDefaultMode;
  final bool initialShowNameLabel;
  final UuidValue? initialLayerId;
  final String initialPrimaryRouteName;
  final int waypointCount;
  final double? pathLengthMeters;

  @override
  State<EvacKitFormDialog> createState() => _EvacKitFormDialogState();
}

class _EvacKitFormDialogState extends State<EvacKitFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _routeNameController;
  late final QuillController _notesController;
  late Color _color;
  late TrackTransportationMode _defaultMode;
  late bool _showNameLabel;
  UuidValue? _layerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _routeNameController = TextEditingController(
      text: widget.initialPrimaryRouteName,
    );
    _notesController = createMarkerNotesController(markdown: widget.initialNotes);
    _color = widget.initialColor;
    _defaultMode = widget.initialDefaultMode;
    _showNameLabel = widget.initialShowNameLabel;
    _layerId = widget.initialLayerId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _routeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final routeName = _routeNameController.text.trim();
    if (name.isEmpty || routeName.isEmpty) {
      return;
    }
    final notes = markerNotesToMarkdown(_notesController);
    Navigator.of(context).pop(
      EvacKitFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        color: _color,
        defaultMode: _defaultMode,
        showNameLabel: _showNameLabel,
        layerId: _layerId,
        primaryRouteName: routeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final eta = widget.pathLengthMeters == null
        ? null
        : formatEvacDuration(
            evacRouteDuration(
              lengthMeters: widget.pathLengthMeters!,
              mode: _defaultMode,
            ),
          );

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.evacKitFormHelp(widget.waypointCount),
                style: theme.textTheme.bodySmall,
              ),
              if (eta != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.evacKitEtaPreview(_defaultMode.label(l10n), eta),
                  style: theme.textTheme.titleSmall,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.formNameLabel,
                  hintText: l10n.evacKitNameHint,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _routeNameController,
                decoration: InputDecoration(
                  labelText: l10n.evacKitPrimaryRouteNameLabel,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TrackTransportationMode>(
                key: ValueKey(_defaultMode),
                initialValue: _defaultMode,
                decoration: InputDecoration(
                  labelText: l10n.evacKitDefaultModeLabel,
                ),
                items: [
                  for (final mode in evacKitEtaModes)
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
                    setState(() => _defaultMode = mode);
                  }
                },
              ),
              const SizedBox(height: 12),
              LayerPickerField(
                selectedLayerId: _layerId,
                onChanged: (layerId) => setState(() => _layerId = layerId),
              ),
              const SizedBox(height: 12),
              MarkerColorPickerField(
                color: _color,
                onChanged: (color) => setState(() => _color = color),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.evacKitShowNameLabel),
                value: _showNameLabel,
                onChanged: (value) => setState(() => _showNameLabel = value),
              ),
              const SizedBox(height: 8),
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
