import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// One code-word pairing on a card of the day (e.g. place → code word).
class CommsCardOfTheDayEntry {
  const CommsCardOfTheDayEntry({
    this.item = '',
    this.codeWord = '',
  });

  final String item;
  final String codeWord;

  bool get isBlank => item.trim().isEmpty && codeWord.trim().isEmpty;

  CommsCardOfTheDayEntry copyWith({String? item, String? codeWord}) {
    return CommsCardOfTheDayEntry(
      item: item ?? this.item,
      codeWord: codeWord ?? this.codeWord,
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item,
    'codeWord': codeWord,
  };

  factory CommsCardOfTheDayEntry.fromJson(Map<String, dynamic> json) {
    return CommsCardOfTheDayEntry(
      item: (json['item'] as String?)?.trim() ?? '',
      codeWord: (json['codeWord'] as String?)?.trim() ?? '',
    );
  }
}

/// Daily SOI-style card: code words by category plus a 0–9 letter key.
class CommsCardOfTheDay {
  const CommsCardOfTheDay({
    required this.id,
    required this.label,
    required this.version,
    required this.generatedAt,
    required this.date,
    required this.digitKey,
    required this.places,
    required this.people,
    required this.objects,
    required this.directions,
    required this.conditions,
    required this.other,
    this.note,
  });

  static const currentVersion = 1;
  static const digitKeyLength = 10;

  final String id;
  final String label;
  final int version;
  final DateTime generatedAt;

  /// Calendar date this card applies to (date-only, stored as UTC midnight).
  final DateTime date;

  /// Ten unique A–Z letters mapping to digits 0–9 (may be empty while drafting).
  final String digitKey;

  final List<CommsCardOfTheDayEntry> places;
  final List<CommsCardOfTheDayEntry> people;
  final List<CommsCardOfTheDayEntry> objects;
  final List<CommsCardOfTheDayEntry> directions;
  final List<CommsCardOfTheDayEntry> conditions;
  final List<CommsCardOfTheDayEntry> other;
  final String? note;

  bool get hasValidDigitKey => isValidDigitKey(digitKey);

  /// Letter for digit [0-9], or null if the key is incomplete.
  String? letterForDigit(int digit) {
    if (!hasValidDigitKey || digit < 0 || digit > 9) {
      return null;
    }
    return digitKey[digit];
  }

  CommsCardOfTheDay copyWith({
    String? id,
    String? label,
    DateTime? date,
    String? digitKey,
    List<CommsCardOfTheDayEntry>? places,
    List<CommsCardOfTheDayEntry>? people,
    List<CommsCardOfTheDayEntry>? objects,
    List<CommsCardOfTheDayEntry>? directions,
    List<CommsCardOfTheDayEntry>? conditions,
    List<CommsCardOfTheDayEntry>? other,
    Object? note = _unset,
  }) {
    return CommsCardOfTheDay(
      id: id ?? this.id,
      label: label ?? this.label,
      version: version,
      generatedAt: generatedAt,
      date: date ?? this.date,
      digitKey: digitKey ?? this.digitKey,
      places: places ?? this.places,
      people: people ?? this.people,
      objects: objects ?? this.objects,
      directions: directions ?? this.directions,
      conditions: conditions ?? this.conditions,
      other: other ?? this.other,
      note: identical(note, _unset) ? this.note : note as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'version': version,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'date': dateOnlyIso(date),
    'digitKey': digitKey,
    'places': [for (final e in places) e.toJson()],
    'people': [for (final e in people) e.toJson()],
    'objects': [for (final e in objects) e.toJson()],
    'directions': [for (final e in directions) e.toJson()],
    'conditions': [for (final e in conditions) e.toJson()],
    'other': [for (final e in other) e.toJson()],
    if (note != null && note!.trim().isNotEmpty) 'note': note,
  };

  factory CommsCardOfTheDay.fromJson(Map<String, dynamic> json) {
    final generatedRaw = json['generatedAt'] as String?;
    final id = (json['id'] as String?)?.trim();
    final label = (json['label'] as String?)?.trim();
    final digitRaw = (json['digitKey'] as String?) ?? '';
    return CommsCardOfTheDay(
      id: (id == null || id.isEmpty) ? const Uuid().v4() : id,
      label: (label == null || label.isEmpty) ? 'Card of the day' : label,
      version: (json['version'] as num?)?.toInt() ?? currentVersion,
      generatedAt: generatedRaw == null
          ? DateTime.now().toUtc()
          : DateTime.parse(generatedRaw).toUtc(),
      date: parseDateOnly(json['date']) ?? dateOnly(DateTime.now().toUtc()),
      digitKey: normalizeDigitKeyLetters(digitRaw),
      places: _entriesFromJson(json['places']),
      people: _entriesFromJson(json['people']),
      objects: _entriesFromJson(json['objects']),
      directions: _entriesFromJson(json['directions']),
      conditions: _entriesFromJson(json['conditions']),
      other: _entriesFromJson(json['other']),
      note: (json['note'] as String?)?.trim(),
    );
  }

  bool get isValid => id.isNotEmpty && label.trim().isNotEmpty;
}

const _unset = Object();

List<CommsCardOfTheDayEntry> _entriesFromJson(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  return [
    for (final entry in raw)
      if (entry is Map<String, dynamic>) CommsCardOfTheDayEntry.fromJson(entry),
  ];
}

/// Strip to A–Z only (uppercased). Does not enforce length/uniqueness.
String normalizeDigitKeyLetters(String raw) {
  return raw.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
}

/// True when [raw] yields exactly 10 unique A–Z letters.
bool isValidDigitKey(String raw) {
  final letters = normalizeDigitKeyLetters(raw);
  return letters.length == CommsCardOfTheDay.digitKeyLength &&
      letters.split('').toSet().length == CommsCardOfTheDay.digitKeyLength;
}

/// Calendar date at UTC midnight.
DateTime dateOnly(DateTime value) {
  final utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

String dateOnlyIso(DateTime value) {
  final d = dateOnly(value);
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime? parseDateOnly(Object? raw) {
  if (raw is! String || raw.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw.trim());
  if (match == null) {
    return null;
  }
  return DateTime.utc(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

List<CommsCardOfTheDay> decodeCommsCardsOfTheDay(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return [
        for (final entry in decoded)
          if (entry is Map<String, dynamic>) CommsCardOfTheDay.fromJson(entry),
      ].where((card) => card.isValid).toList();
    }
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['cards'];
      if (nested is List) {
        return [
          for (final entry in nested)
            if (entry is Map<String, dynamic>)
              CommsCardOfTheDay.fromJson(entry),
        ].where((card) => card.isValid).toList();
      }
      final card = CommsCardOfTheDay.fromJson(decoded);
      return card.isValid ? [card] : const [];
    }
    return const [];
  } catch (_) {
    return const [];
  }
}

String? encodeCommsCardsOfTheDay(List<CommsCardOfTheDay> cards) {
  if (cards.isEmpty) {
    return null;
  }
  return jsonEncode({
    'version': 1,
    'cards': [for (final card in cards) card.toJson()],
  });
}

/// Creates an empty card for [date] (defaults to today UTC).
CommsCardOfTheDay createCommsCardOfTheDay({
  DateTime? date,
  DateTime? generatedAt,
  String? label,
  String? id,
  String digitKey = '',
}) {
  return CommsCardOfTheDay(
    id: id ?? const Uuid().v4(),
    label: (label == null || label.trim().isEmpty)
        ? 'Card of the day'
        : label.trim(),
    version: CommsCardOfTheDay.currentVersion,
    generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
    date: dateOnly(date ?? DateTime.now().toUtc()),
    digitKey: normalizeDigitKeyLetters(digitKey),
    places: const [],
    people: const [],
    objects: const [],
    directions: const [],
    conditions: const [],
    other: const [],
  );
}

String nextCardOfTheDayLabel(List<CommsCardOfTheDay> existing) {
  return 'Card of the day ${existing.length + 1}';
}

/// Random 10-letter key with no repeated characters (CSPRNG).
String generateDigitKey() {
  return generateDigitKeyForTest(random: Random.secure());
}

@visibleForTesting
String generateDigitKeyForTest({required Random random}) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final pool = alphabet.split('')..shuffle(random);
  return pool.take(CommsCardOfTheDay.digitKeyLength).join();
}
