import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/core/app_globals.dart';
import 'package:wayfinder_flutter/core/server_config.dart';
import 'package:wayfinder_flutter/features/access/providers/access_session_provider.dart';
import 'package:wayfinder_flutter/features/kiosk/providers/kiosk_mode_provider.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import 'access_session_fixtures.dart';

/// Default surface for goldens (phone-ish portrait).
const uiTestSurfaceSize = Size(390, 844);

/// Ensures [appServerConfig] is safe for widgets that read globals.
void ensureTestAppServerConfig({
  String apiUrl = 'https://wayfinder-api.example.com',
  String webUrl = 'https://wayfinder-web.example.com',
}) {
  appServerConfig = AppServerConfig(apiUrl: apiUrl, webUrl: webUrl);
}

class StubAccessSessionNotifier extends AccessSessionNotifier {
  StubAccessSessionNotifier(this._session);

  final AccessSessionInfo _session;

  @override
  Future<AccessSessionInfo> build() async => _session;

  @override
  Future<void> refresh() async {
    state = AsyncData(_session);
  }
}

/// Keeps AuthGate on the connection chrome (no usable session value).
class StubAccessSessionConnectionNotifier extends AccessSessionNotifier {
  @override
  Future<AccessSessionInfo> build() async {
    throw Exception('Failed to connect to server');
  }

  @override
  Future<void> refresh() async {
    state = AsyncError(
      Exception('Failed to connect to server'),
      StackTrace.current,
    );
  }
}

List<Override> accessSessionOverrides(AccessSessionInfo session) {
  return [
    accessSessionProvider.overrideWith(
      () => StubAccessSessionNotifier(session),
    ),
  ];
}

List<Override> kioskOverrides({
  required bool active,
  bool serverEnforced = false,
}) {
  return [
    kioskModeActiveProvider.overrideWithValue(active),
    kioskModeServerEnforcedProvider.overrideWithValue(serverEnforced),
  ];
}

ThemeData uiTestTheme({Brightness brightness = Brightness.light}) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B4965),
      brightness: brightness,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );
}

Widget wrapForUiTest(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  ThemeData? theme,
  Size? surfaceSize,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme ?? uiTestTheme(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: surfaceSize == null
          ? Scaffold(body: child)
          : MediaQuery(
              data: MediaQueryData(size: surfaceSize),
              child: Scaffold(body: child),
            ),
    ),
  );
}

Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  ThemeData? theme,
  Size surfaceSize = uiTestSurfaceSize,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    wrapForUiTest(
      child,
      overrides: overrides,
      locale: locale,
      theme: theme,
      surfaceSize: surfaceSize,
    ),
  );
  await tester.pumpAndSettle();
}

/// Install once per golden test file (setUpAll) for Linux/macOS AA tolerance.
void installTolerantGoldens({double precisionTolerance = 0.01}) {
  final current = goldenFileComparator;
  if (current is! LocalFileComparator) {
    return;
  }
  goldenFileComparator = _TolerantGoldenFileComparator(
    Uri.parse('${current.basedir}ui_golden_anchor_test.dart'),
    precisionTolerance: precisionTolerance,
  );
}

Future<void> expectGolden(
  WidgetTester tester,
  String name, {
  Finder? finder,
}) async {
  await expectLater(
    finder ?? find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Allows small AA / platform font differences between developer machines and CI.
class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  }) : assert(
         0 <= precisionTolerance && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       ),
       _precisionTolerance = precisionTolerance;

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

/// Common overrides for AuthGate / connection chrome goldens.
List<Override> signInGateOverrides() {
  return accessSessionOverrides(AccessSessionFixtures.signInRequired());
}

List<Override> connectionGateOverrides() {
  return [
    accessSessionProvider.overrideWith(StubAccessSessionConnectionNotifier.new),
  ];
}
