import 'package:test/test.dart';
import 'package:wayfinder_server/src/settings/rest_api_key_service.dart';

void main() {
  group('RestApiKeyService helpers', () {
    test('generatePlaintextKey uses wf_ prefix and is unique', () {
      final a = RestApiKeyService.generatePlaintextKey();
      final b = RestApiKeyService.generatePlaintextKey();
      expect(a.startsWith(RestApiKeyService.keyPrefix), isTrue);
      expect(b.startsWith(RestApiKeyService.keyPrefix), isTrue);
      expect(a, isNot(b));
      expect(a.length, greaterThan(RestApiKeyService.previewLength));
    });

    test('hashKey is stable SHA-256 hex', () {
      final hash = RestApiKeyService.hashKey('wf_test_key');
      expect(hash, hasLength(64));
      expect(RestApiKeyService.hashKey('wf_test_key'), hash);
      expect(RestApiKeyService.hashKey(' wf_test_key '), hash);
      expect(RestApiKeyService.hashKey('wf_other'), isNot(hash));
    });

    test('keyPreview truncates long keys', () {
      expect(RestApiKeyService.keyPreview('short'), 'short');
      expect(
        RestApiKeyService.keyPreview('wf_abcdefghijklmnop'),
        'wf_abcde…',
      );
    });
  });
}
