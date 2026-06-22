import 'package:flutter/material.dart';

enum AppLocaleChoice {
  system,
  en,
  es,
  fr,
}

const appLocaleChoices = AppLocaleChoice.values;

AppLocaleChoice appLocaleChoiceFromStorage(String? value) {
  return AppLocaleChoice.values.firstWhere(
    (choice) => choice.name == value,
    orElse: () => AppLocaleChoice.system,
  );
}

String appLocaleChoiceToStorage(AppLocaleChoice choice) => choice.name;

Locale? appLocaleChoiceToLocale(AppLocaleChoice choice) {
  return switch (choice) {
    AppLocaleChoice.system => null,
    AppLocaleChoice.en => const Locale('en'),
    AppLocaleChoice.es => const Locale('es'),
    AppLocaleChoice.fr => const Locale('fr'),
  };
}
