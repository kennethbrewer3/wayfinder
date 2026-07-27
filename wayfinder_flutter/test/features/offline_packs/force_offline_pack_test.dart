import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/offline_packs/providers/force_offline_pack_provider.dart';

void main() {
  group('isOfflineModeActive', () {
    test('is false without a pack', () {
      expect(
        isOfflineModeActive(
          serverReachable: false,
          hasPack: false,
          forceWhileOnline: true,
        ),
        isFalse,
      );
    });

    test('is true when server is down and pack exists', () {
      expect(
        isOfflineModeActive(
          serverReachable: false,
          hasPack: true,
          forceWhileOnline: false,
        ),
        isTrue,
      );
    });

    test('is false when server is up unless forced', () {
      expect(
        isOfflineModeActive(
          serverReachable: true,
          hasPack: true,
          forceWhileOnline: false,
        ),
        isFalse,
      );
      expect(
        isOfflineModeActive(
          serverReachable: true,
          hasPack: true,
          forceWhileOnline: true,
        ),
        isTrue,
      );
    });
  });
}
