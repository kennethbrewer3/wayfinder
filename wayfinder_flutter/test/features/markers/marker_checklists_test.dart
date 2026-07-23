import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_checklists.dart';

void main() {
  group('MarkerChecklists', () {
    test('round-trips checklists through JSON storage', () {
      final stored = MarkerChecklists(
        checklists: [
          MarkerChecklist(
            id: 'cl_1',
            name: 'Bug-out bag audit',
            notes: 'Quarterly at retreat',
            lastAuditedAt: DateTime.utc(2026, 7, 1),
            items: const [
              MarkerChecklistItem(
                id: 'cli_1',
                label: 'Water filter present',
                done: true,
                notes: 'Sawyer',
              ),
              MarkerChecklistItem(
                id: 'cli_2',
                label: 'First-aid restocked',
              ),
            ],
          ),
        ],
      );

      final restored = MarkerChecklists.fromMarkerChecklistsJson(
        stored.toStorageJson(),
      );

      expect(restored.checklists, hasLength(1));
      final checklist = restored.checklists.single;
      expect(checklist.id, 'cl_1');
      expect(checklist.name, 'Bug-out bag audit');
      expect(checklist.notes, 'Quarterly at retreat');
      expect(checklist.lastAuditedAt, DateTime.utc(2026, 7, 1));
      expect(checklist.doneCount, 1);
      expect(checklist.totalCount, 2);
      expect(checklist.isComplete, isFalse);
      expect(checklist.items.first.done, isTrue);
      expect(checklist.items.first.notes, 'Sawyer');
      expect(checklist.items.last.done, isFalse);
    });

    test('empty checklists serialize to null', () {
      expect(const MarkerChecklists().toStorageJson(), isNull);
      expect(
        MarkerChecklists.fromMarkerChecklistsJson(null).isEmpty,
        isTrue,
      );
    });

    test('sanitize drops blank names and labels', () {
      final sanitized = sanitizeMarkerChecklists([
        const MarkerChecklist(
          id: 'cl_1',
          name: '  Keep me  ',
          items: [
            MarkerChecklistItem(id: 'cli_1', label: '  Item  '),
            MarkerChecklistItem(id: 'cli_2', label: '   '),
          ],
        ),
        const MarkerChecklist(id: 'cl_2', name: '   '),
      ]);

      expect(sanitized, hasLength(1));
      expect(sanitized.single.name, 'Keep me');
      expect(sanitized.single.items, hasLength(1));
      expect(sanitized.single.items.single.label, 'Item');
    });
  });
}
