import 'dart:convert';

class MarkerChecklistItem {
  const MarkerChecklistItem({
    required this.id,
    required this.label,
    this.done = false,
    this.notes,
  });

  final String id;
  final String label;
  final bool done;
  final String? notes;

  MarkerChecklistItem copyWith({
    String? id,
    String? label,
    bool? done,
    Object? notes = _unset,
  }) {
    return MarkerChecklistItem(
      id: id ?? this.id,
      label: label ?? this.label,
      done: done ?? this.done,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'done': done,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };

  static MarkerChecklistItem? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    final label = json['label']?.toString().trim();
    if (id == null || id.isEmpty || label == null || label.isEmpty) {
      return null;
    }
    final notes = json['notes']?.toString().trim();
    return MarkerChecklistItem(
      id: id,
      label: label,
      done: json['done'] == true,
      notes: notes == null || notes.isEmpty ? null : notes,
    );
  }
}

class MarkerChecklist {
  const MarkerChecklist({
    required this.id,
    required this.name,
    this.notes,
    this.lastAuditedAt,
    this.items = const [],
  });

  final String id;
  final String name;
  final String? notes;
  final DateTime? lastAuditedAt;
  final List<MarkerChecklistItem> items;

  int get doneCount => items.where((item) => item.done).length;
  int get totalCount => items.length;
  bool get isComplete => items.isNotEmpty && doneCount == totalCount;

  MarkerChecklist copyWith({
    String? id,
    String? name,
    Object? notes = _unset,
    Object? lastAuditedAt = _unset,
    List<MarkerChecklistItem>? items,
  }) {
    return MarkerChecklist(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      lastAuditedAt: identical(lastAuditedAt, _unset)
          ? this.lastAuditedAt
          : lastAuditedAt as DateTime?,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    if (lastAuditedAt != null)
      'lastAuditedAt': lastAuditedAt!.toUtc().toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(growable: false),
  };

  static MarkerChecklist? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    final name = json['name']?.toString().trim();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      return null;
    }
    final notes = json['notes']?.toString().trim();
    final itemsRaw = json['items'];
    final items = <MarkerChecklistItem>[];
    if (itemsRaw is List) {
      for (final entry in itemsRaw) {
        if (entry is Map<String, dynamic>) {
          final item = MarkerChecklistItem.fromJson(entry);
          if (item != null) {
            items.add(item);
          }
        }
      }
    }
    return MarkerChecklist(
      id: id,
      name: name,
      notes: notes == null || notes.isEmpty ? null : notes,
      lastAuditedAt: _parseDate(json['lastAuditedAt']),
      items: items,
    );
  }
}

class MarkerChecklists {
  const MarkerChecklists({this.checklists = const []});

  final List<MarkerChecklist> checklists;

  bool get isEmpty => checklists.isEmpty;
  bool get isNotEmpty => checklists.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'checklists': checklists
        .map((checklist) => checklist.toJson())
        .toList(growable: false),
  };

  String? toStorageJson() {
    if (checklists.isEmpty) {
      return null;
    }
    return jsonEncode(toJson());
  }

  static MarkerChecklists fromMarkerChecklistsJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const MarkerChecklists();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const MarkerChecklists();
      }
      return fromJson(decoded);
    } catch (_) {
      return const MarkerChecklists();
    }
  }

  static MarkerChecklists fromJson(Map<String, dynamic> json) {
    final raw = json['checklists'];
    if (raw is! List) {
      return const MarkerChecklists();
    }
    final checklists = <MarkerChecklist>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        final checklist = MarkerChecklist.fromJson(entry);
        if (checklist != null) {
          checklists.add(checklist);
        }
      }
    }
    return MarkerChecklists(checklists: checklists);
  }
}

String newMarkerChecklistId() {
  return 'cl_${DateTime.now().toUtc().microsecondsSinceEpoch}';
}

String newMarkerChecklistItemId() {
  return 'cli_${DateTime.now().toUtc().microsecondsSinceEpoch}';
}

List<MarkerChecklist> sanitizeMarkerChecklists(
  List<MarkerChecklist> checklists,
) {
  final result = <MarkerChecklist>[];
  for (final checklist in checklists) {
    final name = checklist.name.trim();
    if (name.isEmpty) {
      continue;
    }
    final items = <MarkerChecklistItem>[];
    for (final item in checklist.items) {
      final label = item.label.trim();
      if (label.isEmpty) {
        continue;
      }
      final notes = item.notes?.trim();
      items.add(
        item.copyWith(
          label: label,
          notes: notes == null || notes.isEmpty ? null : notes,
        ),
      );
    }
    final notes = checklist.notes?.trim();
    result.add(
      checklist.copyWith(
        name: name,
        notes: notes == null || notes.isEmpty ? null : notes,
        items: items,
      ),
    );
  }
  return result;
}

DateTime? _parseDate(Object? raw) {
  if (raw is! String || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw)?.toUtc();
}

const Object _unset = Object();
