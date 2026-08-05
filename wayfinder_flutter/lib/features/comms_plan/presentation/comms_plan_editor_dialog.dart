import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../markers/models/marker_radio.dart';
import '../../markers/presentation/marker_radio_editor.dart';
import '../../markers/providers/markers_provider.dart';
import '../models/comms_plan_channel.dart';
import '../models/comms_radio_service.dart';
import '../providers/comms_plan_provider.dart';
import '../utils/comms_plan_timezones.dart';

Future<void> showCommsPlanEditorDialog({
  required BuildContext context,
  required WidgetRef ref,
  CommsPlan? existing,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _CommsPlanEditorDialog(existing: existing),
  );
}

class _CommsPlanEditorDialog extends ConsumerStatefulWidget {
  const _CommsPlanEditorDialog({this.existing});

  final CommsPlan? existing;

  @override
  ConsumerState<_CommsPlanEditorDialog> createState() =>
      _CommsPlanEditorDialogState();
}

class _CommsPlanEditorDialogState
    extends ConsumerState<_CommsPlanEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late String _timezone;
  late final List<String> _timezoneOptions;
  late bool _active;
  late List<CommsPlanChannel> _channels;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _timezone = (existing?.timezoneIana.trim().isNotEmpty == true)
        ? existing!.timezoneIana.trim()
        : 'UTC';
    _timezoneOptions = commsPlanTimezoneOptions(current: _timezone);
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _active = existing?.active ?? true;
    _channels = decodeCommsPlanChannels(existing?.channelsJson);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(
        isEdit ? l10n.commsPlanEditTitle : l10n.commsPlanCreateTitle,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanNameLabel,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              DropdownMenu<String>(
                key: ValueKey('comms-plan-timezone-$_timezone'),
                initialSelection: _timezone,
                enableFilter: true,
                requestFocusOnTap: true,
                label: Text(l10n.commsPlanTimezoneLabel),
                hintText: l10n.commsPlanTimezoneHint,
                helperText: l10n.commsPlanTimezoneHelper,
                leadingIcon: const Icon(Icons.public),
                expandedInsets: EdgeInsets.zero,
                filterCallback: (entries, filter) {
                  final query = filter.trim().toLowerCase();
                  if (query.isEmpty || query == _timezone.toLowerCase()) {
                    return entries;
                  }
                  return [
                    for (final entry in entries)
                      if (entry.label.toLowerCase().contains(query)) entry,
                  ];
                },
                onSelected: (value) {
                  if (value != null) {
                    setState(() => _timezone = value);
                  }
                },
                dropdownMenuEntries: [
                  for (final zone in _timezoneOptions)
                    DropdownMenuEntry<String>(value: zone, label: zone),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.commsPlanActiveLabel),
                subtitle: Text(l10n.commsPlanActiveHint),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanNotesLabel,
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.commsPlanChannelsHeading,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saving ? null : _addChannel,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.commsPlanAddChannel),
                  ),
                ],
              ),
              if (_channels.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.commsPlanChannelsEmpty),
                )
              else
                for (var i = 0; i < _channels.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      Icons.cell_tower,
                      color: _availabilityColor(_channels[i].availability),
                    ),
                    title: Text(_channels[i].label),
                    subtitle: Text(_channelSubtitle(l10n, _channels[i])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.actionEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: _saving ? null : () => _editChannel(i),
                        ),
                        IconButton(
                          tooltip: l10n.actionDelete,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: _saving
                              ? null
                              : () => setState(() => _channels.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? l10n.actionSave : l10n.actionCreate),
        ),
      ],
    );
  }

  Future<void> _addChannel() async {
    final channel = await showCommsPlanChannelEditorDialog(
      context: context,
      ref: ref,
    );
    if (channel == null || !mounted) {
      return;
    }
    setState(() => _channels = [..._channels, channel]);
  }

  Future<void> _editChannel(int index) async {
    final channel = await showCommsPlanChannelEditorDialog(
      context: context,
      ref: ref,
      existing: _channels[index],
    );
    if (channel == null || !mounted) {
      return;
    }
    setState(() {
      _channels = [..._channels];
      _channels[index] = channel;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.commsPlanNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final now = DateTime.now().toUtc();
      final existing = widget.existing;
      final plan =
          (existing ??
                  CommsPlan(
                    name: name,
                    channelsJson: '[]',
                    createdAt: now,
                    updatedAt: now,
                  ))
              .copyWith(
                name: name,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                timezoneIana: _timezone,
                active: _active,
                channelsJson: encodeCommsPlanChannels(_channels),
                updatedAt: now,
              );

      final notifier = ref.read(commsPlansProvider.notifier);
      final saved = existing == null
          ? await notifier.create(plan)
          : await notifier.updatePlan(plan);

      if (_active) {
        final others =
            ref.read(commsPlansProvider).valueOrNull ?? const <CommsPlan>[];
        for (final other in others) {
          if (other.id == saved.id || !other.active) {
            continue;
          }
          await notifier.updatePlan(
            other.copyWith(active: false, updatedAt: DateTime.now().toUtc()),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = l10n.commsPlanSaveFailed(error.toString());
      });
    }
  }
}

Future<CommsPlanChannel?> showCommsPlanChannelEditorDialog({
  required BuildContext context,
  required WidgetRef ref,
  CommsPlanChannel? existing,
}) {
  return showDialog<CommsPlanChannel>(
    context: context,
    builder: (context) => _CommsPlanChannelEditorDialog(existing: existing),
  );
}

class _CommsPlanChannelEditorDialog extends ConsumerStatefulWidget {
  const _CommsPlanChannelEditorDialog({this.existing});

  final CommsPlanChannel? existing;

  @override
  ConsumerState<_CommsPlanChannelEditorDialog> createState() =>
      _CommsPlanChannelEditorDialogState();
}

class _CommsPlanChannelEditorDialogState
    extends ConsumerState<_CommsPlanChannelEditorDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _netNameController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _toneController;
  late final TextEditingController _offsetController;
  late final TextEditingController _callsignController;
  late final TextEditingController _startController;
  late final TextEditingController _durationController;
  late final TextEditingController _statusNoteController;
  late final TextEditingController _notesController;
  late CommsChannelRole _role;
  late CommsRadioService _radioService;
  String? _serviceChannelId;
  late MarkerRadioMode _mode;
  late CommsChannelAvailability _availability;
  late Set<int> _days;
  String? _markerId;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _netNameController = TextEditingController(text: existing?.netName ?? '');
    _frequencyController = TextEditingController(
      text: existing?.frequencyMHz?.toString() ?? '',
    );
    _toneController = TextEditingController(
      text: existing?.toneHz?.toString() ?? '',
    );
    _offsetController = TextEditingController(
      text: existing?.offsetMHz?.toString() ?? '',
    );
    _callsignController = TextEditingController(text: existing?.callsign ?? '');
    _startController = TextEditingController(
      text: existing?.startLocalTime ?? '',
    );
    _durationController = TextEditingController(
      text: existing?.durationMinutes?.toString() ?? '',
    );
    _statusNoteController = TextEditingController(
      text: existing?.statusNote ?? '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _role = existing?.role ?? CommsChannelRole.primary;
    _radioService = existing?.radioService ?? CommsRadioService.ham;
    _serviceChannelId = existing?.serviceChannelId;
    if (_radioService.usesPermittedChannels) {
      _serviceChannelId ??= findPermittedChannelByFrequency(
        _radioService,
        existing?.frequencyMHz,
      )?.id;
      _serviceChannelId ??= permittedChannelsFor(_radioService).first.id;
    }
    _mode = existing?.mode ?? MarkerRadioMode.fm;
    _availability = existing?.availability ?? CommsChannelAvailability.unknown;
    _days = {...(existing?.daysOfWeek ?? const <int>[])};
    _markerId = existing?.markerId;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _netNameController.dispose();
    _frequencyController.dispose();
    _toneController.dispose();
    _offsetController.dispose();
    _callsignController.dispose();
    _startController.dispose();
    _durationController.dispose();
    _statusNoteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final markers = ref.watch(markersProvider).valueOrNull ?? const [];
    final sortedMarkers = [...markers]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.commsPlanChannelCreateTitle
            : l10n.commsPlanChannelEditTitle,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _netNameController,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelNetName,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CommsChannelRole>(
                initialValue: _role,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelRole,
                ),
                items: [
                  for (final role in CommsChannelRole.values)
                    DropdownMenuItem(
                      value: role,
                      child: Text(commsChannelRoleLabel(l10n, role)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _role = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CommsRadioService>(
                initialValue: _radioService,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanRadioServiceLabel,
                  helperText: l10n.commsPlanRadioServiceHint,
                ),
                items: [
                  for (final service in CommsRadioService.values)
                    DropdownMenuItem(
                      value: service,
                      child: Text(commsRadioServiceLabel(l10n, service)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _onRadioServiceChanged(value);
                  }
                },
              ),
              const SizedBox(height: 8),
              if (_radioService.usesPermittedChannels)
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'service-channel-$_radioService-$_serviceChannelId',
                  ),
                  initialValue: _validServiceChannelId(),
                  decoration: InputDecoration(
                    labelText: l10n.commsPlanServiceChannelLabel,
                    helperText: l10n.commsPlanServiceChannelHint,
                  ),
                  items: [
                    for (final channel in permittedChannelsFor(_radioService))
                      DropdownMenuItem(
                        value: channel.id,
                        child: Text(channel.listLabel()),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _applyPermittedChannel(value);
                    }
                  },
                )
              else ...[
                TextField(
                  controller: _frequencyController,
                  decoration: InputDecoration(
                    labelText: l10n.markerRadioFrequencyLabel,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MarkerRadioMode>(
                  key: ValueKey('ham-mode-$_mode'),
                  initialValue: _mode,
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _mode = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _toneController,
                        decoration: InputDecoration(
                          labelText: l10n.markerRadioToneLabel,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _offsetController,
                        decoration: InputDecoration(
                          labelText: l10n.markerRadioOffsetLabel,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_radioService == CommsRadioService.gmrs ||
                  _radioService == CommsRadioService.frs) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _toneController,
                  decoration: InputDecoration(
                    labelText: l10n.markerRadioToneLabel,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _callsignController,
                decoration: InputDecoration(
                  labelText: l10n.markerRadioCallsignLabel,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.commsPlanChannelDays,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  for (var day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text(_weekdayShort(l10n, day)),
                      selected: _days.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _days.add(day);
                          } else {
                            _days.remove(day);
                          }
                        });
                      },
                    ),
                ],
              ),
              Text(
                l10n.commsPlanChannelDaysHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startController,
                      decoration: InputDecoration(
                        labelText: l10n.commsPlanChannelStartTime,
                        hintText: '19:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: l10n.commsPlanChannelDuration,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CommsChannelAvailability>(
                initialValue: _availability,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelAvailability,
                ),
                items: [
                  for (final value in CommsChannelAvailability.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(commsChannelAvailabilityLabel(l10n, value)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _availability = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _statusNoteController,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelStatusNote,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _markerId,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelLinkedMarker,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.commsPlanChannelNoMarker),
                  ),
                  for (final marker in sortedMarkers)
                    DropdownMenuItem<String?>(
                      value: marker.id.uuid,
                      child: Text(marker.name),
                    ),
                ],
                onChanged: (value) => setState(() => _markerId = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.commsPlanChannelNotes,
                ),
                minLines: 2,
                maxLines: 3,
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
          onPressed: () {
            final label = _labelController.text.trim();
            if (label.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.commsPlanChannelLabelRequired)),
              );
              return;
            }
            if (_radioService.usesPermittedChannels &&
                _validServiceChannelId() == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.commsPlanServiceChannelRequired)),
              );
              return;
            }
            final permitted = _radioService.usesPermittedChannels
                ? findPermittedChannel(_radioService, _serviceChannelId)
                : null;
            Navigator.of(context).pop(
              CommsPlanChannel(
                id: widget.existing?.id ?? const Uuid().v4(),
                label: label,
                netName: _optional(_netNameController.text),
                role: _role,
                radioService: _radioService,
                serviceChannelId: permitted?.id,
                frequencyMHz:
                    permitted?.frequencyMHz ??
                    double.tryParse(_frequencyController.text.trim()),
                mode: permitted?.defaultMode ?? _mode,
                toneHz: _radioService == CommsRadioService.cb
                    ? null
                    : double.tryParse(_toneController.text.trim()),
                offsetMHz:
                    permitted?.defaultOffsetMHz ??
                    (_radioService == CommsRadioService.ham
                        ? double.tryParse(_offsetController.text.trim())
                        : null),
                callsign: _optional(_callsignController.text),
                daysOfWeek: (_days.toList()..sort()),
                startLocalTime: _optional(_startController.text),
                durationMinutes: int.tryParse(_durationController.text.trim()),
                availability: _availability,
                statusNote: _optional(_statusNoteController.text),
                markerId: _markerId,
                notes: _optional(_notesController.text),
              ),
            );
          },
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  String? _validServiceChannelId() {
    return findPermittedChannel(_radioService, _serviceChannelId)?.id;
  }

  void _onRadioServiceChanged(CommsRadioService service) {
    setState(() {
      _radioService = service;
      if (!service.usesPermittedChannels) {
        _serviceChannelId = null;
        return;
      }
      final channels = permittedChannelsFor(service);
      final keep = findPermittedChannel(service, _serviceChannelId);
      final selected = keep ?? channels.first;
      _serviceChannelId = selected.id;
      _frequencyController.text = selected.frequencyMHz.toString();
      _mode = selected.defaultMode;
      _offsetController.text = selected.defaultOffsetMHz?.toString() ?? '';
    });
  }

  void _applyPermittedChannel(String channelId) {
    final channel = findPermittedChannel(_radioService, channelId);
    if (channel == null) {
      return;
    }
    setState(() {
      _serviceChannelId = channel.id;
      _frequencyController.text = channel.frequencyMHz.toString();
      _mode = channel.defaultMode;
      _offsetController.text = channel.defaultOffsetMHz?.toString() ?? '';
    });
  }
}

String? _optional(String raw) {
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _channelSubtitle(AppLocalizations l10n, CommsPlanChannel channel) {
  final permitted = findPermittedChannel(
    channel.radioService,
    channel.serviceChannelId,
  );
  final parts = <String>[
    commsRadioServiceLabel(l10n, channel.radioService),
    commsChannelRoleLabel(l10n, channel.role),
    if (permitted != null)
      'Ch ${permitted.numberLabel} · ${permitted.frequencyMHz} MHz'
    else if (channel.frequencyMHz != null)
      '${channel.frequencyMHz} ${markerRadioModeLabel(l10n, channel.mode)}',
    commsChannelAvailabilityLabel(l10n, channel.availability),
  ];
  return parts.join(' · ');
}

String commsRadioServiceLabel(
  AppLocalizations l10n,
  CommsRadioService service,
) {
  return switch (service) {
    CommsRadioService.ham => l10n.commsPlanRadioServiceHam,
    CommsRadioService.gmrs => l10n.commsPlanRadioServiceGmrs,
    CommsRadioService.frs => l10n.commsPlanRadioServiceFrs,
    CommsRadioService.cb => l10n.commsPlanRadioServiceCb,
  };
}

Color _availabilityColor(CommsChannelAvailability availability) {
  return switch (availability) {
    CommsChannelAvailability.go => Colors.green.shade700,
    CommsChannelAvailability.noGo => Colors.red.shade700,
    CommsChannelAvailability.conditional => Colors.orange.shade800,
    CommsChannelAvailability.unknown => Colors.blueGrey,
  };
}

String _weekdayShort(AppLocalizations l10n, int day) {
  return switch (day) {
    1 => l10n.commsPlanWeekdayMon,
    2 => l10n.commsPlanWeekdayTue,
    3 => l10n.commsPlanWeekdayWed,
    4 => l10n.commsPlanWeekdayThu,
    5 => l10n.commsPlanWeekdayFri,
    6 => l10n.commsPlanWeekdaySat,
    _ => l10n.commsPlanWeekdaySun,
  };
}

String commsChannelRoleLabel(AppLocalizations l10n, CommsChannelRole role) {
  return switch (role) {
    CommsChannelRole.primary => l10n.commsPlanRolePrimary,
    CommsChannelRole.alternate => l10n.commsPlanRoleAlternate,
    CommsChannelRole.emergency => l10n.commsPlanRoleEmergency,
    CommsChannelRole.tactical => l10n.commsPlanRoleTactical,
    CommsChannelRole.liaison => l10n.commsPlanRoleLiaison,
  };
}

String commsChannelAvailabilityLabel(
  AppLocalizations l10n,
  CommsChannelAvailability availability,
) {
  return switch (availability) {
    CommsChannelAvailability.go => l10n.commsPlanAvailabilityGo,
    CommsChannelAvailability.noGo => l10n.commsPlanAvailabilityNoGo,
    CommsChannelAvailability.conditional =>
      l10n.commsPlanAvailabilityConditional,
    CommsChannelAvailability.unknown => l10n.commsPlanAvailabilityUnknown,
  };
}
