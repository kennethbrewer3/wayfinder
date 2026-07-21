import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_radio.dart';

class MarkerRadioEditor extends StatefulWidget {
  const MarkerRadioEditor({
    super.key,
    required this.contact,
    required this.onChanged,
    this.markerIcon,
    this.initiallyExpanded = false,
  });

  final MarkerRadioContact contact;
  final ValueChanged<MarkerRadioContact> onChanged;
  final String? markerIcon;
  final bool initiallyExpanded;

  @override
  State<MarkerRadioEditor> createState() => _MarkerRadioEditorState();
}

class _MarkerRadioEditorState extends State<MarkerRadioEditor> {
  late final TextEditingController _callsignController;
  late final TextEditingController _netNameController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _toneController;
  late final TextEditingController _offsetController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _callsignController = TextEditingController(text: contact.callsign);
    _netNameController = TextEditingController(text: contact.netName ?? '');
    _frequencyController = TextEditingController(
      text: formatRadioFrequencyMHz(contact.frequencyMHz),
    );
    _toneController = TextEditingController(
      text: formatRadioFrequencyMHz(contact.toneHz),
    );
    _offsetController = TextEditingController(
      text: formatRadioFrequencyMHz(contact.offsetMHz),
    );
    _notesController = TextEditingController(text: contact.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant MarkerRadioEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact == widget.contact) {
      return;
    }
    _syncController(_callsignController, widget.contact.callsign);
    _syncController(_netNameController, widget.contact.netName ?? '');
    _syncController(
      _frequencyController,
      formatRadioFrequencyMHz(widget.contact.frequencyMHz),
    );
    _syncController(
      _toneController,
      formatRadioFrequencyMHz(widget.contact.toneHz),
    );
    _syncController(
      _offsetController,
      formatRadioFrequencyMHz(widget.contact.offsetMHz),
    );
    _syncController(_notesController, widget.contact.notes ?? '');
  }

  void _syncController(TextEditingController controller, String text) {
    if (controller.text == text) {
      return;
    }
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _callsignController.dispose();
    _netNameController.dispose();
    _frequencyController.dispose();
    _toneController.dispose();
    _offsetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _emit(MarkerRadioContact next) => widget.onChanged(next);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final contact = widget.contact;
    final expanded =
        widget.initiallyExpanded ||
        contact.isNotEmpty ||
        isRadioContactMarkerIcon(widget.markerIcon);

    return ExpansionTile(
      initiallyExpanded: expanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      title: Text(l10n.markerRadioTitle),
      subtitle: Text(
        contact.isEmpty
            ? l10n.markerRadioEmptyHelp
            : l10n.markerRadioSummary(
                contact.callsign.isEmpty
                    ? l10n.markerRadioNoCallsign
                    : contact.callsign,
              ),
        style: theme.textTheme.bodySmall,
      ),
      children: [
        Text(
          l10n.markerRadioStructuredHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _callsignController,
          decoration: InputDecoration(
            labelText: l10n.markerRadioCallsignLabel,
            hintText: 'W1AW',
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) => _emit(contact.copyWith(callsign: value)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<MarkerRadioRole>(
          key: ValueKey('radio-role-${contact.role}'),
          initialValue: contact.role,
          decoration: InputDecoration(labelText: l10n.markerRadioRoleLabel),
          items: [
            for (final role in MarkerRadioRole.values)
              DropdownMenuItem(
                value: role,
                child: Text(markerRadioRoleLabel(l10n, role)),
              ),
          ],
          onChanged: (role) {
            if (role != null) {
              _emit(contact.copyWith(role: role));
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _netNameController,
          decoration: InputDecoration(
            labelText: l10n.markerRadioNetNameLabel,
            hintText: l10n.markerRadioNetNameHint,
          ),
          onChanged: (value) => _emit(
            contact.copyWith(netName: value.trim().isEmpty ? null : value),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: l10n.markerRadioFrequencyLabel,
                  hintText: '146.52',
                  suffixText: 'MHz',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                ],
                onChanged: (value) {
                  final trimmed = value.trim();
                  _emit(
                    contact.copyWith(
                      frequencyMHz: trimmed.isEmpty
                          ? null
                          : double.tryParse(trimmed),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<MarkerRadioMode>(
                key: ValueKey('radio-mode-${contact.mode}'),
                initialValue: contact.mode,
                decoration: InputDecoration(
                  labelText: l10n.markerRadioModeLabel,
                ),
                items: [
                  for (final mode in MarkerRadioMode.values)
                    DropdownMenuItem(
                      value: mode,
                      child: Text(markerRadioModeLabel(l10n, mode)),
                    ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    _emit(contact.copyWith(mode: mode));
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _toneController,
                decoration: InputDecoration(
                  labelText: l10n.markerRadioToneLabel,
                  hintText: '100.0',
                  suffixText: 'Hz',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: (value) {
                  final trimmed = value.trim();
                  _emit(
                    contact.copyWith(
                      toneHz: trimmed.isEmpty ? null : double.tryParse(trimmed),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _offsetController,
                decoration: InputDecoration(
                  labelText: l10n.markerRadioOffsetLabel,
                  hintText: '-0.600',
                  suffixText: 'MHz',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                ],
                onChanged: (value) {
                  final trimmed = value.trim();
                  _emit(
                    contact.copyWith(
                      offsetMHz: trimmed.isEmpty
                          ? null
                          : double.tryParse(trimmed),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.markerRadioNotesLabel,
            hintText: l10n.markerRadioNotesHint,
          ),
          maxLines: 2,
          onChanged: (value) => _emit(
            contact.copyWith(notes: value.trim().isEmpty ? null : value),
          ),
        ),
        if (contact.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                final cleared = const MarkerRadioContact(
                  role: MarkerRadioRole.other,
                );
                _callsignController.clear();
                _netNameController.clear();
                _frequencyController.clear();
                _toneController.clear();
                _offsetController.clear();
                _notesController.clear();
                _emit(cleared);
              },
              icon: const Icon(Icons.clear),
              label: Text(l10n.markerRadioClear),
            ),
          ),
        ],
      ],
    );
  }
}

String markerRadioRoleLabel(AppLocalizations l10n, MarkerRadioRole role) {
  return switch (role) {
    MarkerRadioRole.shack => l10n.markerRadioRoleShack,
    MarkerRadioRole.repeater => l10n.markerRadioRoleRepeater,
    MarkerRadioRole.station => l10n.markerRadioRoleStation,
    MarkerRadioRole.net => l10n.markerRadioRoleNet,
    MarkerRadioRole.other => l10n.markerRadioRoleOther,
  };
}

String markerRadioModeLabel(AppLocalizations l10n, MarkerRadioMode mode) {
  return switch (mode) {
    MarkerRadioMode.fm => l10n.markerRadioModeFm,
    MarkerRadioMode.am => l10n.markerRadioModeAm,
    MarkerRadioMode.ssb => l10n.markerRadioModeSsb,
    MarkerRadioMode.cw => l10n.markerRadioModeCw,
    MarkerRadioMode.digi => l10n.markerRadioModeDigi,
    MarkerRadioMode.dmr => l10n.markerRadioModeDmr,
    MarkerRadioMode.other => l10n.markerRadioModeOther,
  };
}
