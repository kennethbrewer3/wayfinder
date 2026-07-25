import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/core/server_config.dart';

void main() {
  group('normalizeApiUrl / normalizeWebUrl', () {
    test('adds http scheme when missing', () {
      expect(
        normalizeApiUrl('192.168.1.10:18080'),
        'http://192.168.1.10:18080',
      );
      expect(normalizeWebUrl('example.com'), 'http://example.com');
    });

    test('preserves https and strips path', () {
      expect(
        normalizeApiUrl('https://wayfinder-api.example.com/v1'),
        'https://wayfinder-api.example.com',
      );
    });

    test('rejects empty and non-http schemes', () {
      expect(() => normalizeApiUrl(''), throwsFormatException);
      expect(() => normalizeApiUrl('ftp://example.com'), throwsFormatException);
      expect(() => normalizeApiUrl('http:///'), throwsFormatException);
    });
  });

  group('isLoopbackApiUrl', () {
    test('detects loopback hosts', () {
      expect(isLoopbackApiUrl('http://localhost:18080'), isTrue);
      expect(isLoopbackApiUrl('http://127.0.0.1:18080'), isTrue);
      expect(isLoopbackApiUrl('http://[::1]:18080'), isTrue);
      expect(isLoopbackApiUrl('http://0.0.0.0:18080'), isTrue);
    });

    test('allows LAN and public hosts', () {
      expect(isLoopbackApiUrl('http://192.168.1.10:18080'), isFalse);
      expect(
        isLoopbackApiUrl('https://wayfinder-api.brewerhomestead.com'),
        isFalse,
      );
    });

    test('treats invalid URLs as loopback (unsafe for device forms)', () {
      expect(isLoopbackApiUrl(''), isTrue);
      expect(isLoopbackApiUrl(':::'), isTrue);
    });
  });

  group('device form helpers', () {
    test('apiUrlForDeviceForm hides loopback', () {
      expect(apiUrlForDeviceForm('http://localhost:18080'), isNull);
      expect(
        apiUrlForDeviceForm('http://10.0.0.5:18080'),
        'http://10.0.0.5:18080',
      );
    });

    test('webUrlForDeviceForm hides loopback', () {
      expect(webUrlForDeviceForm('http://127.0.0.1:18082'), isNull);
      expect(
        webUrlForDeviceForm('https://wayfinder-web.example.com'),
        'https://wayfinder-web.example.com',
      );
    });
  });
}
