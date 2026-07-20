import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_inventory.dart';

void main() {
  group('MarkerInventory', () {
    test('round-trips items through JSON storage', () {
      final inventory = MarkerInventory(
        items: [
          MarkerInventoryItem(
            id: 'inv_1',
            name: 'Rice',
            quantity: 25,
            unit: 'lb',
            category: MarkerInventoryCategory.food,
            expiresAt: DateTime.utc(2026, 10, 1),
            lastAuditedAt: DateTime.utc(2026, 7, 1),
          ),
        ],
      );

      final restored = MarkerInventory.fromMarkerInventoryJson(
        inventory.toStorageJson(),
      );

      expect(restored.items, hasLength(1));
      final item = restored.items.single;
      expect(item.id, 'inv_1');
      expect(item.name, 'Rice');
      expect(item.quantity, 25);
      expect(item.unit, 'lb');
      expect(item.category, MarkerInventoryCategory.food);
      expect(item.expiresAt, DateTime.utc(2026, 10, 1));
      expect(item.lastAuditedAt, DateTime.utc(2026, 7, 1));
    });

    test('empty inventory serializes to null', () {
      expect(const MarkerInventory().toStorageJson(), isNull);
      expect(
        MarkerInventory.fromMarkerInventoryJson(null).isEmpty,
        isTrue,
      );
    });
  });

  group('markerHasFoodExpiringWithin', () {
    final now = DateTime.utc(2026, 7, 19);

    String inventoryJson({
      required MarkerInventoryCategory category,
      required DateTime? expiresAt,
    }) {
      return MarkerInventory(
        items: [
          MarkerInventoryItem(
            id: 'inv_1',
            name: 'Item',
            quantity: 1,
            unit: 'ea',
            category: category,
            expiresAt: expiresAt,
          ),
        ],
      ).toStorageJson()!;
    }

    test('matches food expiring within 90 days', () {
      expect(
        markerHasFoodExpiringWithin(
          inventoryJson(
            category: MarkerInventoryCategory.food,
            expiresAt: DateTime.utc(2026, 9, 1),
          ),
          now: now,
        ),
        isTrue,
      );
    });

    test('matches already-expired food', () {
      expect(
        markerHasFoodExpiringWithin(
          inventoryJson(
            category: MarkerInventoryCategory.food,
            expiresAt: DateTime.utc(2026, 6, 1),
          ),
          now: now,
        ),
        isTrue,
      );
    });

    test('ignores food beyond 90 days', () {
      expect(
        markerHasFoodExpiringWithin(
          inventoryJson(
            category: MarkerInventoryCategory.food,
            expiresAt: DateTime.utc(2026, 12, 1),
          ),
          now: now,
        ),
        isFalse,
      );
    });

    test('ignores non-food categories', () {
      expect(
        markerHasFoodExpiringWithin(
          inventoryJson(
            category: MarkerInventoryCategory.medical,
            expiresAt: DateTime.utc(2026, 8, 1),
          ),
          now: now,
        ),
        isFalse,
      );
    });

    test('ignores food without expiry', () {
      expect(
        markerHasFoodExpiringWithin(
          inventoryJson(
            category: MarkerInventoryCategory.food,
            expiresAt: null,
          ),
          now: now,
        ),
        isFalse,
      );
    });
  });
}
