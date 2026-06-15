import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import 'router.dart';
import 'theme.dart';

class WayfinderApp extends StatelessWidget {
  const WayfinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
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
