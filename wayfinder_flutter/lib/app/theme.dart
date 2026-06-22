import 'package:flutter/material.dart';

import 'app_theme_choice.dart';

class AppTheme {
  AppTheme._();

  static ThemeData forChoice(AppThemeChoice choice) {
    return switch (choice) {
      AppThemeChoice.light => _standardLight(),
      AppThemeChoice.dark => _standardDark(),
      AppThemeChoice.militaryLight => _militaryLight(),
      AppThemeChoice.militaryDark => _militaryDark(),
    };
  }

  static ThemeData _standardLight() {
    return _buildTheme(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4965),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData _standardDark() {
    return _buildTheme(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4965),
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _militaryLight() {
    const olive = Color(0xFF4B5320);
    const tan = Color(0xFF8B7355);
    const forest = Color(0xFF3D5A40);

    return _buildTheme(
      const ColorScheme(
        brightness: Brightness.light,
        primary: olive,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD8DCC0),
        onPrimaryContainer: Color(0xFF1A1F0A),
        secondary: tan,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8DCC8),
        onSecondaryContainer: Color(0xFF2E2414),
        tertiary: forest,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFC8D8CA),
        onTertiaryContainer: Color(0xFF102015),
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: Color(0xFFF5F3EB),
        onSurface: Color(0xFF1C1B16),
        onSurfaceVariant: Color(0xFF46453D),
        outline: Color(0xFF78786C),
        outlineVariant: Color(0xFFC9C6BA),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFF31302A),
        onInverseSurface: Color(0xFFF5F3EB),
        inversePrimary: Color(0xFFB8C48A),
        surfaceTint: olive,
      ),
    );
  }

  static ThemeData _militaryDark() {
    const olive = Color(0xFFB8C48A);
    const tan = Color(0xFFC9B48A);
    const forest = Color(0xFF6B9970);

    return _buildTheme(
      const ColorScheme(
        brightness: Brightness.dark,
        primary: olive,
        onPrimary: Color(0xFF1C2009),
        primaryContainer: Color(0xFF434B20),
        onPrimaryContainer: Color(0xFFD4E4A8),
        secondary: tan,
        onSecondary: Color(0xFF2E2610),
        secondaryContainer: Color(0xFF5C4E32),
        onSecondaryContainer: Color(0xFFE8DCC0),
        tertiary: forest,
        onTertiary: Color(0xFF0D1A10),
        tertiaryContainer: Color(0xFF2F4634),
        onTertiaryContainer: Color(0xFFC8E0CC),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF141610),
        onSurface: Color(0xFFE6E4DA),
        onSurfaceVariant: Color(0xFFC9C6BA),
        outline: Color(0xFF929689),
        outlineVariant: Color(0xFF46453D),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFFE6E4DA),
        onInverseSurface: Color(0xFF2F2E28),
        inversePrimary: Color(0xFF4B5320),
        surfaceTint: olive,
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    ).textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.surfaceContainerHighest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurface;
          }),
        ),
      ),
    );
  }
}
