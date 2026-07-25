import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared setup for widget + golden tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadTestFonts();
  await testMain();
}

Future<void> _loadTestFonts() async {
  try {
    final loader = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/protomaps/fonts/NotoSans-Regular.ttf'));
    await loader.load();
  } on Object {
    // Default test font is fine if assets cannot be loaded.
  }
}
