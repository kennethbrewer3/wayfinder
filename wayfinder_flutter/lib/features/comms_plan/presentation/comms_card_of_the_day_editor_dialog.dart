import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/comms_card_of_the_day.dart';
import '../utils/comms_card_of_the_day_nouns.dart';

Future<CommsCardOfTheDay?> showCommsCardOfTheDayEditorDialog({
  required BuildContext context,
  CommsCardOfTheDay? existing,
  String? defaultLabel,
}) {
  return showDialog<CommsCardOfTheDay>(
    context: context,
    builder: (context) => _CommsCardOfTheDayEditorDialog(
      existing: existing,
      defaultLabel: defaultLabel,
    ),
  );
}

class _CommsCardOfTheDayEditorDialog extends StatefulWidget {
  const _CommsCardOfTheDayEditorDialog({
    this.existing,
    this.defaultLabel,
  });

  final CommsCardOfTheDay? existing;
  final String? defaultLabel;

  @override
  State<_CommsCardOfTheDayEditorDialog> createState() =>
      _CommsCardOfTheDayEditorDialogState();
}

class _CommsCardOfTheDayEditorDialogState
    extends State<_CommsCardOfTheDayEditorDialog> {
  late DateTime _date;
  late final TextEditingController _labelController;
  late final TextEditingController _digitKeyController;
  late List<CommsCardOfTheDayEntry> _places;
  late List<CommsCardOfTheDayEntry> _people;
  late List<CommsCardOfTheDayEntry> _objects;
  late List<CommsCardOfTheDayEntry> _directions;
  late List<CommsCardOfTheDayEntry> _conditions;
  late List<CommsCardOfTheDayEntry> _other;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final seed =
        existing ?? createCommsCardOfTheDay(label: widget.defaultLabel);
    _date = seed.date;
    _labelController = TextEditingController(text: seed.label);
    _digitKeyController = TextEditingController(
      text: _formatDigitKeyForEdit(seed.digitKey),
    );
    _places = _copyEntries(seed.places);
    _people = _copyEntries(seed.people);
    _objects = _copyEntries(seed.objects);
    _directions = _copyEntries(seed.directions);
    _conditions = _copyEntries(seed.conditions);
    _other = _copyEntries(seed.other);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _digitKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.existing != null;
    final digitLetters = normalizeDigitKeyLetters(_digitKeyController.text);
    final digitOk = digitLetters.isEmpty || isValidDigitKey(digitLetters);

    return AlertDialog(
      title: Text(
        isEdit
            ? l10n.commsCardOfTheDayEditTitle
            : l10n.commsCardOfTheDayCreateTitle,
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.commsCardOfTheDayLabelLabel,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.commsCardOfTheDayDateLabel),
                subtitle: Text(DateFormat.yMMMMEEEEd().format(_date.toLocal())),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date.toLocal(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) {
                    return;
                  }
                  setState(() => _date = dateOnly(picked));
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.commsCardOfTheDayDigitKeyTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                l10n.commsCardOfTheDayDigitKeyHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _digitKeyController,
                      decoration: InputDecoration(
                        labelText: l10n.commsCardOfTheDayDigitKeyLabel,
                        errorText: digitOk
                            ? null
                            : l10n.commsCardOfTheDayDigitKeyInvalid,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z\s\-]'),
                        ),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        final key = generateDigitKey();
                        setState(() {
                          _digitKeyController.text = _formatDigitKeyForEdit(
                            key,
                          );
                        });
                      },
                      icon: const Icon(Icons.casino, size: 18),
                      label: Text(l10n.commsCardOfTheDayDigitKeyGenerate),
                    ),
                  ),
                ],
              ),
              if (digitLetters.length == 10 && digitOk) ...[
                const SizedBox(height: 8),
                _DigitKeyPreview(digitKey: digitLetters),
              ],
              const SizedBox(height: 16),
              _CategoryEditor(
                title: l10n.commsCardOfTheDayPlaces,
                entries: _places,
                itemLabel: l10n.commsCardOfTheDayItemLabel,
                codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
                addLabel: l10n.commsCardOfTheDayAddEntry,
                randomTooltip: l10n.commsCardOfTheDayCodeWordRandom,
                exhaustedMessage: l10n.commsCardOfTheDayCodeWordExhausted,
                usedElsewhere: _codeWordsFrom([
                  _people,
                  _objects,
                  _directions,
                  _conditions,
                  _other,
                ]),
                onChanged: (value) => setState(() => _places = value),
              ),
              _CategoryEditor(
                title: l10n.commsCardOfTheDayPeople,
                entries: _people,
                itemLabel: l10n.commsCardOfTheDayItemLabel,
                codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
                addLabel: l10n.commsCardOfTheDayAddEntry,
                randomTooltip: l10n.commsCardOfTheDayCodeWordRandom,
                exhaustedMessage: l10n.commsCardOfTheDayCodeWordExhausted,
                usedElsewhere: _codeWordsFrom([
                  _places,
                  _objects,
                  _directions,
                  _conditions,
                  _other,
                ]),
                onChanged: (value) => setState(() => _people = value),
              ),
              _CategoryEditor(
                title: l10n.commsCardOfTheDayObjects,
                entries: _objects,
                itemLabel: l10n.commsCardOfTheDayItemLabel,
                codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
                addLabel: l10n.commsCardOfTheDayAddEntry,
                randomTooltip: l10n.commsCardOfTheDayCodeWordRandom,
                exhaustedMessage: l10n.commsCardOfTheDayCodeWordExhausted,
                usedElsewhere: _codeWordsFrom([
                  _places,
                  _people,
                  _directions,
                  _conditions,
                  _other,
                ]),
                onChanged: (value) => setState(() => _objects = value),
              ),
              _CategoryEditor(
                title: l10n.commsCardOfTheDayDirections,
                entries: _directions,
                itemLabel: l10n.commsCardOfTheDayItemLabel,
                codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
                addLabel: l10n.commsCardOfTheDayAddEntry,
                randomTooltip: l10n.commsCardOfTheDayCodeWordRandom,
                exhaustedMessage: l10n.commsCardOfTheDayCodeWordExhausted,
                usedElsewhere: _codeWordsFrom([
                  _places,
                  _people,
                  _objects,
                  _conditions,
                  _other,
                ]),
                onChanged: (value) => setState(() => _directions = value),
              ),
              _CategoryEditor(
                title: l10n.commsCardOfTheDayConditions,
                entries: _conditions,
                itemLabel: l10n.commsCardOfTheDayItemLabel,
                codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
                addLabel: l10n.commsCardOfTheDayAddEntry,
                randomTooltip: l10n.commsCardOfTheDayCodeWordRandom,
                exhaustedMessage: l10n.commsCardOfTheDayCodeWordExhausted,
                usedElsewhere: _codeWordsFrom([
                  _places,
                  _people,
                  _objects,
                  _directions,
                  _other,
                ]),
                onChanged: (value) => setState(() => _conditions = value),
              ),
              _CategoryEditor(
                title: l10n.commsCardOfTheDayOther,
                entries: _other,
                itemLabel: l10n.commsCardOfTheDayItemLabel,
                codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
                addLabel: l10n.commsCardOfTheDayAddEntry,
                randomTooltip: l10n.commsCardOfTheDayCodeWordRandom,
                exhaustedMessage: l10n.commsCardOfTheDayCodeWordExhausted,
                usedElsewhere: _codeWordsFrom([
                  _places,
                  _people,
                  _objects,
                  _directions,
                  _conditions,
                ]),
                onChanged: (value) => setState(() => _other = value),
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: digitOk ? _save : null,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  Set<String> _codeWordsFrom(Iterable<List<CommsCardOfTheDayEntry>> lists) {
    return {
      for (final list in lists)
        for (final entry in list)
          if (entry.codeWord.trim().isNotEmpty)
            entry.codeWord.trim().toUpperCase(),
    };
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = l10n.commsCardOfTheDayLabelRequired);
      return;
    }
    final digitKey = normalizeDigitKeyLetters(_digitKeyController.text);
    if (digitKey.isNotEmpty && !isValidDigitKey(digitKey)) {
      setState(() => _error = l10n.commsCardOfTheDayDigitKeyInvalid);
      return;
    }
    final existing = widget.existing;
    final card =
        (existing ??
                createCommsCardOfTheDay(
                  label: label,
                  date: _date,
                  digitKey: digitKey,
                ))
            .copyWith(
              label: label,
              date: dateOnly(_date),
              digitKey: digitKey,
              places: _trimEntries(_places),
              people: _trimEntries(_people),
              objects: _trimEntries(_objects),
              directions: _trimEntries(_directions),
              conditions: _trimEntries(_conditions),
              other: _trimEntries(_other),
            );
    Navigator.of(context).pop(card);
  }
}

class _DigitKeyPreview extends StatelessWidget {
  const _DigitKeyPreview({required this.digitKey});

  final String digitKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Table(
      border: TableBorder.all(color: theme.dividerColor),
      children: [
        TableRow(
          children: [
            for (var d = 0; d < 10; d++)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '$d',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        TableRow(
          children: [
            for (var d = 0; d < 10; d++)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  digitKey[d],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({
    required this.title,
    required this.entries,
    required this.itemLabel,
    required this.codeWordLabel,
    required this.addLabel,
    required this.randomTooltip,
    required this.exhaustedMessage,
    required this.usedElsewhere,
    required this.onChanged,
  });

  final String title;
  final List<CommsCardOfTheDayEntry> entries;
  final String itemLabel;
  final String codeWordLabel;
  final String addLabel;
  final String randomTooltip;
  final String exhaustedMessage;

  /// Code words already used in other categories on this card.
  final Set<String> usedElsewhere;
  final ValueChanged<List<CommsCardOfTheDayEntry>> onChanged;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late List<TextEditingController> _itemControllers;
  late List<TextEditingController> _codeControllers;

  @override
  void initState() {
    super.initState();
    _syncControllers(widget.entries);
  }

  @override
  void didUpdateWidget(covariant _CategoryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries.length != widget.entries.length) {
      _disposeControllers();
      _syncControllers(widget.entries);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _syncControllers(List<CommsCardOfTheDayEntry> entries) {
    _itemControllers = [
      for (final entry in entries) TextEditingController(text: entry.item),
    ];
    _codeControllers = [
      for (final entry in entries) TextEditingController(text: entry.codeWord),
    ];
  }

  void _disposeControllers() {
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    for (final controller in _codeControllers) {
      controller.dispose();
    }
  }

  void _emit() {
    widget.onChanged([
      for (var i = 0; i < _itemControllers.length; i++)
        CommsCardOfTheDayEntry(
          item: _itemControllers[i].text,
          codeWord: _codeControllers[i].text,
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  widget.onChanged([
                    ...widget.entries,
                    const CommsCardOfTheDayEntry(),
                  ]);
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(widget.addLabel),
              ),
            ],
          ),
          for (var i = 0; i < _itemControllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemControllers[i],
                      decoration: InputDecoration(
                        labelText: widget.itemLabel,
                        isDense: true,
                      ),
                      onChanged: (_) => _emit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _codeControllers[i],
                      decoration: InputDecoration(
                        labelText: widget.codeWordLabel,
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => _emit(),
                    ),
                  ),
                  IconButton(
                    tooltip: widget.randomTooltip,
                    onPressed: () {
                      final used = <String>{
                        ...widget.usedElsewhere,
                        for (var j = 0; j < _codeControllers.length; j++)
                          if (j != i &&
                              _codeControllers[j].text.trim().isNotEmpty)
                            _codeControllers[j].text.trim().toUpperCase(),
                      };
                      final picked = pickRandomCardOfTheDayNoun(
                        usedOnCard: used,
                      );
                      if (picked == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(widget.exhaustedMessage)),
                        );
                        return;
                      }
                      _codeControllers[i].text = picked;
                      _emit();
                    },
                    icon: const Icon(Icons.casino, size: 18),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    onPressed: () {
                      widget.onChanged([
                        for (var j = 0; j < widget.entries.length; j++)
                          if (j != i) widget.entries[j],
                      ]);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

List<CommsCardOfTheDayEntry> _copyEntries(List<CommsCardOfTheDayEntry> source) {
  return [
    for (final entry in source)
      CommsCardOfTheDayEntry(item: entry.item, codeWord: entry.codeWord),
  ];
}

List<CommsCardOfTheDayEntry> _trimEntries(List<CommsCardOfTheDayEntry> source) {
  return [
    for (final entry in source)
      if (!entry.isBlank)
        CommsCardOfTheDayEntry(
          item: entry.item.trim(),
          codeWord: entry.codeWord.trim(),
        ),
  ];
}

String _formatDigitKeyForEdit(String key) {
  final letters = normalizeDigitKeyLetters(key);
  if (letters.length != 10) {
    return letters;
  }
  // Prefer a readable 5+5 split when presenting a generated key.
  return '${letters.substring(0, 5)} ${letters.substring(5)}';
}
