import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/coordinate_form_fields.dart';
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
    this.latitude,
    this.longitude,
  });

  final String name;
  final String? notes;
  final Color color;
  final String icon;
  final double elevation;
  final UuidValue? layerId;
  final double? latitude;
  final double? longitude;
}

Future<MarkerFormData?> showMarkerFormDialog({
  required BuildContext context,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialColor,
  String? initialIcon,
  double initialElevation = 0,
  UuidValue? initialLayerId,
  double? initialLatitude,
  double? initialLongitude,
  bool allowCoordinateEdit = false,
}) {
  return showDialog<MarkerFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return MarkerFormDialog(
        title: title ?? l10n.markerCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.markerDefaultName,
        initialNotes: initialNotes,
        initialColor: initialColor ?? parseMarkerColor('#1B4965'),
        initialIcon: normalizeMarkerIcon(initialIcon ?? 'place'),
        initialElevation: initialElevation,
        initialLayerId: initialLayerId,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        allowCoordinateEdit: allowCoordinateEdit,
      );
    },
  );
}

Future<MarkerFormData?> showEditMarkerDialog({
  required BuildContext context,
  required MapMarker marker,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showMarkerFormDialog(
    context: context,
    title: l10n.markerEditTitle,
    confirmLabel: l10n.actionSave,
    defaultName: marker.name,
    initialNotes: marker.notes,
    initialColor: parseMarkerColor(marker.color),
    initialIcon: marker.icon,
    initialElevation: marker.elevation,
    initialLayerId: marker.layerId,
    initialLatitude: marker.latitude,
    initialLongitude: marker.longitude,
    allowCoordinateEdit: true,
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
    this.initialLatitude,
    this.initialLongitude,
    this.allowCoordinateEdit = false,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final String? initialNotes;
  final Color initialColor;
  final String initialIcon;
  final double initialElevation;
  final UuidValue? initialLayerId;
  final double? initialLatitude;
  final double? initialLongitude;
  final bool allowCoordinateEdit;

  @override
  State<MarkerFormDialog> createState() => _MarkerFormDialogState();
}

class _MarkerFormDialogState extends State<MarkerFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _elevationController;
  late final TextEditingController? _latitudeController;
  late final TextEditingController? _longitudeController;
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
    if (widget.allowCoordinateEdit &&
        widget.initialLatitude != null &&
        widget.initialLongitude != null) {
      _latitudeController = TextEditingController(
        text: formatCoordinateField(widget.initialLatitude!),
      );
      _longitudeController = TextEditingController(
        text: formatCoordinateField(widget.initialLongitude!),
      );
    } else {
      _latitudeController = null;
      _longitudeController = null;
    }
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
    _latitudeController?.dispose();
    _longitudeController?.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final elevation = _parseElevation();
    if (elevation == null) {
      return;
    }

    final coordinates = _latitudeController != null && _longitudeController != null
        ? parseLatLngFields(
            _latitudeController.text,
            _longitudeController.text,
          )
        : null;
    if (_latitudeController != null &&
        _longitudeController != null &&
        coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionInvalidCoordinates)),
      );
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
        latitude: coordinates?.latitude,
        longitude: coordinates?.longitude,
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
                  hintText: l10n.markerNameHint,
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              if (_latitudeController != null && _longitudeController != null) ...[
                const SizedBox(height: 16),
                CoordinateFormFields(
                  title: l10n.coordinatesTitle,
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                  helperText: l10n.markerCoordinatesHelp,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _elevationController,
                decoration: InputDecoration(
                  labelText: l10n.markerElevationLabel,
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
