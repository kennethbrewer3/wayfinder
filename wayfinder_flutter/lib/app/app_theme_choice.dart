enum AppThemeFamily {
  standard('Standard'),
  military('Military');

  const AppThemeFamily(this.label);

  final String label;
}

enum AppThemeBrightness {
  light('Light'),
  dark('Dark');

  const AppThemeBrightness(this.label);

  final String label;
}

enum AppThemeChoice {
  light(AppThemeFamily.standard, AppThemeBrightness.light, 'Light'),
  dark(AppThemeFamily.standard, AppThemeBrightness.dark, 'Dark'),
  militaryLight(
    AppThemeFamily.military,
    AppThemeBrightness.light,
    'Military light',
  ),
  militaryDark(
    AppThemeFamily.military,
    AppThemeBrightness.dark,
    'Military dark',
  );

  const AppThemeChoice(this.family, this.brightness, this.label);

  final AppThemeFamily family;
  final AppThemeBrightness brightness;
  final String label;

  static AppThemeChoice combine(
    AppThemeFamily family,
    AppThemeBrightness brightness,
  ) {
    for (final choice in AppThemeChoice.values) {
      if (choice.family == family && choice.brightness == brightness) {
        return choice;
      }
    }
    return AppThemeChoice.light;
  }
}

AppThemeChoice appThemeChoiceFromStorage(String? value) {
  return AppThemeChoice.values.firstWhere(
    (choice) => choice.name == value,
    orElse: () => AppThemeChoice.light,
  );
}

String appThemeChoiceToStorage(AppThemeChoice choice) => choice.name;
