import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../markers/models/marker_color.dart';
import '../../markers/presentation/marker_form_fields.dart';
import '../../markers/presentation/marker_notes_editor.dart';
import '../models/seasonal_date_window.dart';

class SeasonalOverlayFormData {
  const SeasonalOverlayFormData({
    required this.name,
    required this.notes,
    required this.borderColor,
    required this.fillColor,
    required this.dateMode,
    required this.windows,
  });

  final String name;
  final String? notes;
  final Color borderColor;
  final Color fillColor;
  final String dateMode;
  final List<SeasonalDateWindow> windows;
}

Future<SeasonalOverlayFormData?> showSeasonalOverlayFormDialog({
  required BuildContext context,
  required List<LatLng> points,
  String? title,
  String? confirmLabel,
  String? defaultName,
  String? initialNotes,
  Color? initialBorderColor,
  Color? initialFillColor,
  String initialDateMode = seasonalDateModeAbsolute,
  List<SeasonalDateWindow>? initialWindows,
}) {
  return showDialog<SeasonalOverlayFormData>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return _SeasonalOverlayFormDialog(
        title: title ?? l10n.seasonalOverlayCreateTitle,
        confirmLabel: confirmLabel ?? l10n.actionCreate,
        defaultName: defaultName ?? l10n.seasonalOverlayDefaultName,
        vertexCount: points.length,
        initialNotes: initialNotes,
        initialBorderColor: initialBorderColor ?? parseMarkerColor('#2E7D32'),
        initialFillColor: initialFillColor ?? parseMarkerColor('#2E7D3240'),
        initialDateMode: initialDateMode,
        initialWindows:
            initialWindows ??
            [
              SeasonalDateWindow.absolute(
                startDate: DateTime.now(),
                endDate: DateTime.now().add(const Duration(days: 30)),
              ),
            ],
      );
    },
  );
}

class _SeasonalOverlayFormDialog extends StatefulWidget {
  const _SeasonalOverlayFormDialog({
    required this.title,
    required this.confirmLabel,
    required this.defaultName,
    required this.vertexCount,
    required this.initialNotes,
    required this.initialBorderColor,
    required this.initialFillColor,
    required this.initialDateMode,
    required this.initialWindows,
  });

  final String title;
  final String confirmLabel;
  final String defaultName;
  final int vertexCount;
  final String? initialNotes;
  final Color initialBorderColor;
  final Color initialFillColor;
  final String initialDateMode;
  final List<SeasonalDateWindow> initialWindows;

  @override
  State<_SeasonalOverlayFormDialog> createState() =>
      _SeasonalOverlayFormDialogState();
}

class _SeasonalOverlayFormDialogState
    extends State<_SeasonalOverlayFormDialog> {
  late final TextEditingController _nameController;
  late final QuillController _notesController;
  late Color _borderColor;
  late Color _fillColor;
  late String _dateMode;
  late List<SeasonalDateWindow> _windows;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _notesController = createMarkerNotesController(
      markdown: widget.initialNotes,
    );
    _borderColor = widget.initialBorderColor;
    _fillColor = widget.initialFillColor;
    _dateMode = widget.initialDateMode;
    _windows = List<SeasonalDateWindow>.from(widget.initialWindows);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _editWindow(int index) async {
    final current = _windows[index];
    final updated = _dateMode == seasonalDateModeRecurring
        ? await _editRecurringWindow(current)
        : await _editAbsoluteWindow(current);
    if (updated == null || !mounted) {
      return;
    }
    setState(() => _windows[index] = updated);
  }

  Future<SeasonalDateWindow?> _editAbsoluteWindow(
    SeasonalDateWindow current,
  ) async {
    var start = current.startDate ?? DateTime.now();
    var end = current.endDate ?? start.add(const Duration(days: 30));
    return showDialog<SeasonalDateWindow>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.seasonalOverlayEditWindow),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.seasonalOverlayStartDate),
                    subtitle: Text(_formatDate(start)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: start,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setLocal(() {
                          start = picked;
                          if (end.isBefore(start)) {
                            end = start;
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.seasonalOverlayEndDate),
                    subtitle: Text(_formatDate(end)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: end,
                        firstDate: start,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setLocal(() => end = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    SeasonalDateWindow.absolute(
                      startDate: start,
                      endDate: end,
                    ),
                  ),
                  child: Text(l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<SeasonalDateWindow?> _editRecurringWindow(
    SeasonalDateWindow current,
  ) async {
    final startMonthController = TextEditingController(
      text: '${current.startMonth ?? 1}',
    );
    final startDayController = TextEditingController(
      text: '${current.startDay ?? 1}',
    );
    final endMonthController = TextEditingController(
      text: '${current.endMonth ?? 12}',
    );
    final endDayController = TextEditingController(
      text: '${current.endDay ?? 31}',
    );
    final result = await showDialog<SeasonalDateWindow>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.seasonalOverlayEditWindow),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.seasonalOverlayRecurringHint),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startMonthController,
                      decoration: InputDecoration(
                        labelText: l10n.seasonalOverlayStartMonth,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: startDayController,
                      decoration: InputDecoration(
                        labelText: l10n.seasonalOverlayStartDay,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: endMonthController,
                      decoration: InputDecoration(
                        labelText: l10n.seasonalOverlayEndMonth,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endDayController,
                      decoration: InputDecoration(
                        labelText: l10n.seasonalOverlayEndDay,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                final startMonth = int.tryParse(startMonthController.text);
                final startDay = int.tryParse(startDayController.text);
                final endMonth = int.tryParse(endMonthController.text);
                final endDay = int.tryParse(endDayController.text);
                if (startMonth == null ||
                    startDay == null ||
                    endMonth == null ||
                    endDay == null) {
                  return;
                }
                Navigator.of(context).pop(
                  SeasonalDateWindow.recurring(
                    startMonth: startMonth,
                    startDay: startDay,
                    endMonth: endMonth,
                    endDay: endDay,
                  ),
                );
              },
              child: Text(l10n.actionSave),
            ),
          ],
        );
      },
    );
    startMonthController.dispose();
    startDayController.dispose();
    endMonthController.dispose();
    endDayController.dispose();
    return result;
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _windows.isEmpty) {
      return;
    }
    final notes = markerNotesToMarkdown(_notesController);
    Navigator.of(context).pop(
      SeasonalOverlayFormData(
        name: name,
        notes: notes.isEmpty ? null : notes,
        borderColor: _borderColor,
        fillColor: _fillColor,
        dateMode: _dateMode,
        windows: List<SeasonalDateWindow>.from(_windows),
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
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.seasonalOverlayVertexCount(widget.vertexCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.formNameLabel),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
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
              Text(
                l10n.seasonalOverlayDateMode,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: seasonalDateModeAbsolute,
                    label: Text(l10n.seasonalOverlayDateModeAbsolute),
                  ),
                  ButtonSegment(
                    value: seasonalDateModeRecurring,
                    label: Text(l10n.seasonalOverlayDateModeRecurring),
                  ),
                ],
                selected: {_dateMode},
                onSelectionChanged: (value) {
                  final mode = value.first;
                  setState(() {
                    _dateMode = mode;
                    final now = DateTime.now();
                    if (mode == seasonalDateModeRecurring) {
                      _windows = [
                        SeasonalDateWindow.recurring(
                          startMonth: now.month,
                          startDay: now.day,
                          endMonth: now.month,
                          endDay: now.day,
                        ),
                      ];
                    } else {
                      _windows = [
                        SeasonalDateWindow.absolute(
                          startDate: now,
                          endDate: now.add(const Duration(days: 30)),
                        ),
                      ];
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.seasonalOverlayWindows,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final template = _dateMode == seasonalDateModeRecurring
                          ? const SeasonalDateWindow.recurring(
                              startMonth: 1,
                              startDay: 1,
                              endMonth: 1,
                              endDay: 31,
                            )
                          : SeasonalDateWindow.absolute(
                              startDate: DateTime.now(),
                              endDate: DateTime.now().add(
                                const Duration(days: 14),
                              ),
                            );
                      final created = _dateMode == seasonalDateModeRecurring
                          ? await _editRecurringWindow(template)
                          : await _editAbsoluteWindow(template);
                      if (created != null && mounted) {
                        setState(() => _windows.add(created));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.seasonalOverlayAddWindow),
                  ),
                ],
              ),
              for (final (index, window) in _windows.indexed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_windowLabel(window)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.actionEdit,
                        onPressed: () => _editWindow(index),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: l10n.actionDelete,
                        onPressed: _windows.length <= 1
                            ? null
                            : () => setState(() => _windows.removeAt(index)),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
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

  String _windowLabel(SeasonalDateWindow window) {
    if (window.isAbsolute) {
      return '${_formatDate(window.startDate!)} → ${_formatDate(window.endDate!)}';
    }
    return '${window.startMonth}/${window.startDay} → ${window.endMonth}/${window.endDay}';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
