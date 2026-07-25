import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/app/app_theme_ids.dart';

void main() {
  group('AppThemeIds', () {
    final customId = UuidValue.fromString(
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    );

    test('normalize defaults unknown values', () {
      expect(AppThemeIds.normalize(null), AppThemeIds.defaultId);
      expect(AppThemeIds.normalize(''), AppThemeIds.defaultId);
      expect(AppThemeIds.normalize('nope'), AppThemeIds.defaultId);
      expect(AppThemeIds.normalize('dark'), 'dark');
    });

    test('custom ids encode light and dark', () {
      expect(
        AppThemeIds.forCustom(customId),
        'custom:aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      expect(
        AppThemeIds.forCustom(customId, dark: true),
        'custom:aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa:dark',
      );
      expect(
        AppThemeIds.isCustomDark(AppThemeIds.forCustom(customId, dark: true)),
        isTrue,
      );
      expect(
        AppThemeIds.isCustomDark(AppThemeIds.forCustom(customId)),
        isFalse,
      );
    });

    test('tryParseCustomId strips brightness suffix', () {
      final darkId = AppThemeIds.forCustom(customId, dark: true);
      expect(AppThemeIds.tryParseCustomId(darkId), customId);
      expect(AppThemeIds.customBaseId(darkId), AppThemeIds.forCustom(customId));
      expect(AppThemeIds.matchesCustom(darkId, customId), isTrue);
    });

    test('withDarkMode toggles custom and built-in', () {
      final lightCustom = AppThemeIds.forCustom(customId);
      expect(
        AppThemeIds.withDarkMode(lightCustom, true),
        AppThemeIds.forCustom(customId, dark: true),
      );
      expect(AppThemeIds.withDarkMode('light', true), 'dark');
      expect(AppThemeIds.withDarkMode('dark', false), 'light');
    });
  });
}
