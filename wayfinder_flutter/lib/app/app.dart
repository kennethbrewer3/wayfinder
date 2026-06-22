import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../features/settings/providers/app_locale_provider.dart';
import '../features/settings/providers/app_theme_provider.dart';
import 'app_locale_choice.dart';
import 'router.dart';
import 'theme.dart';

class WayfinderApp extends ConsumerWidget {
  const WayfinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeChoice = ref.watch(appThemeProvider);
    final localeChoice = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.forChoice(themeChoice),
      locale: appLocaleChoiceToLocale(localeChoice),
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class WayfinderAppScope extends StatelessWidget {
  const WayfinderAppScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: child);
  }
}
