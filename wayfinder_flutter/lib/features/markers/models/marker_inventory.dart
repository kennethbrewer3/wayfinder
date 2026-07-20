import 'dart:convert';

/// Categories stored on cache inventory line items.
enum MarkerInventoryCategory {
  food,
  water,
  medical,
  ammo,
  other;

  static MarkerInventoryCategory parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'food' => MarkerInventoryCategory.food,
      'water' => MarkerInventoryCategory.water,
      'medical' => MarkerInventoryCategory.medical,
      'ammo' => MarkerInventoryCategory.ammo,
      _ => MarkerInventoryCategory.other,
    };
  }

  String get storageValue => name;
}

/// Common quantity units for cache inventory.
const markerInventoryUnitOptions = <String>[
  'ea',
  'box',
  'case',
  'can',
  'bag',
  'lb',
  'oz',
  'kg',
  'g',
  'gal',
  'L',
  'qt',
  'pt',
];

class MarkerInventoryItem {
  const MarkerInventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = MarkerInventoryCategory.other,
    this.expiresAt,
    this.lastAuditedAt,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final MarkerInventoryCategory category;
  final DateTime? expiresAt;
  final DateTime? lastAuditedAt;

  MarkerInventoryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    MarkerInventoryCategory? category,
    Object? expiresAt = _unset,
    Object? lastAuditedAt = _unset,
  }) {
    return MarkerInventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      expiresAt: identical(expiresAt, _unset)
          ? this.expiresAt
          : expiresAt as DateTime?,
      lastAuditedAt: identical(lastAuditedAt, _unset)
          ? this.lastAuditedAt
          : lastAuditedAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category.storageValue,
      if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
      if (lastAuditedAt != null)
        'lastAuditedAt': lastAuditedAt!.toUtc().toIso8601String(),
    };
  }

  static MarkerInventoryItem? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    final name = json['name']?.toString().trim();
    final quantityRaw = json['quantity'];
    final unit = json['unit']?.toString().trim();
    if (id == null ||
        id.isEmpty ||
        name == null ||
        name.isEmpty ||
        quantityRaw is! num ||
        unit == null ||
        unit.isEmpty) {
      return null;
    }

    return MarkerInventoryItem(
      id: id,
      name: name,
      quantity: quantityRaw.toDouble(),
      unit: unit,
      category: MarkerInventoryCategory.parse(json['category'] as String?),
      expiresAt: _parseDate(json['expiresAt']),
      lastAuditedAt: _parseDate(json['lastAuditedAt']),
    );
  }
}

class MarkerInventory {
  const MarkerInventory({this.items = const []});

  final List<MarkerInventoryItem> items;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(growable: false),
  };

  String? toStorageJson() {
    if (items.isEmpty) {
      return null;
    }
    return jsonEncode(toJson());
  }

  static MarkerInventory fromMarkerInventoryJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const MarkerInventory();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const MarkerInventory();
      }
      return fromJson(decoded);
    } catch (_) {
      return const MarkerInventory();
    }
  }

  static MarkerInventory fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    if (itemsRaw is! List) {
      return const MarkerInventory();
    }
    final items = <MarkerInventoryItem>[];
    for (final entry in itemsRaw) {
      if (entry is Map<String, dynamic>) {
        final item = MarkerInventoryItem.fromJson(entry);
        if (item != null) {
          items.add(item);
        }
      }
    }
    return MarkerInventory(items: items);
  }
}

/// Whether [expiresAt] falls on or before [now] + [within].
///
/// Includes already-expired items (past expiry counts as "expiring within").
bool inventoryItemExpiresWithin(
  MarkerInventoryItem item, {
  required Duration within,
  DateTime? now,
}) {
  final expiresAt = item.expiresAt;
  if (expiresAt == null) {
    return false;
  }
  final reference = (now ?? DateTime.now()).toUtc();
  return !expiresAt.toUtc().isAfter(reference.add(within));
}

bool markerHasFoodExpiringWithin(
  String? inventoryJson, {
  int days = 90,
  DateTime? now,
}) {
  final inventory = MarkerInventory.fromMarkerInventoryJson(inventoryJson);
  final within = Duration(days: days);
  for (final item in inventory.items) {
    if (item.category != MarkerInventoryCategory.food) {
      continue;
    }
    if (inventoryItemExpiresWithin(item, within: within, now: now)) {
      return true;
    }
  }
  return false;
}

String newMarkerInventoryItemId() {
  return 'inv_${DateTime.now().toUtc().microsecondsSinceEpoch}';
}

DateTime? _parseDate(Object? raw) {
  if (raw is! String || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw)?.toUtc();
}

const Object _unset = Object();
