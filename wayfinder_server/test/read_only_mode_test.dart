import 'package:test/test.dart';
import 'package:wayfinder_server/src/core/read_only_mode.dart';

void main() {
  group('ReadOnlyMode.isWriteOperation', () {
    test('allows common read operations', () {
      expect(ReadOnlyMode.isWriteOperation('getSettings'), isFalse);
      expect(ReadOnlyMode.isWriteOperation('listMarkers'), isFalse);
      expect(ReadOnlyMode.isWriteOperation('exportMapData'), isFalse);
      expect(ReadOnlyMode.isWriteOperation('queryAt'), isFalse);
      expect(ReadOnlyMode.isWriteOperation('activeFileId'), isFalse);
      expect(ReadOnlyMode.isWriteOperation('hello'), isFalse);
    });

    test('blocks common write operations', () {
      expect(ReadOnlyMode.isWriteOperation('createMarker'), isTrue);
      expect(ReadOnlyMode.isWriteOperation('updateMarker'), isTrue);
      expect(ReadOnlyMode.isWriteOperation('deleteMarker'), isTrue);
      expect(ReadOnlyMode.isWriteOperation('restoreMapData'), isTrue);
      expect(ReadOnlyMode.isWriteOperation('importPackArchive'), isTrue);
      expect(ReadOnlyMode.isWriteOperation('setFileEnabled'), isTrue);
      expect(ReadOnlyMode.isWriteOperation('clearRestApiKeys'), isTrue);
    });
  });
}
