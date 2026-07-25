import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_raster_svg.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_svg_picture.dart';

/// Minimal valid 1×1 PNG (transparent).
final _tinyPng = base64.decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

String _rasterWrapperSvg(Uint8List pngBytes) {
  final b64 = base64.encode(pngBytes);
  return '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="24" height="24">
  <image width="24" height="24" href="data:image/png;base64,$b64"/>
</svg>
''';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('extractPngFromRasterSvg', () {
    test('returns null for vector SVG assets', () {
      final bytes = File('assets/markers/apartment.svg').readAsBytesSync();
      expect(extractPngFromRasterSvg(bytes), isNull);
    });

    test('extracts PNG bytes from raster wrapper SVG markup', () {
      final svgBytes = Uint8List.fromList(
        utf8.encode(_rasterWrapperSvg(_tinyPng)),
      );
      final pngBytes = extractPngFromRasterSvg(svgBytes);
      expect(pngBytes, isNotNull);
      expect(pngBytes, _tinyPng);
      expect(String.fromCharCodes(pngBytes!.take(4)), '\x89PNG');
    });

    test('returns null when asset icons are pure vector SVGs', () {
      final markerDir = Directory('assets/markers');
      final svgFiles = markerDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.svg'))
          .toList();
      expect(svgFiles, isNotEmpty);

      final remainingWrappers = <String>[];
      for (final file in svgFiles) {
        final text = file.readAsStringSync();
        if (text.contains('data:image/png;base64,')) {
          remainingWrappers.add(file.path);
          expect(
            extractPngFromRasterSvg(file.readAsBytesSync()),
            isNotNull,
            reason: file.path,
          );
        } else {
          expect(
            extractPngFromRasterSvg(file.readAsBytesSync()),
            isNull,
            reason: file.path,
          );
        }
      }
      // Bundled icons are expected to be true vectors after optimization.
      expect(remainingWrappers, isEmpty);
    });
  });

  group('markerSvgAssetPicture', () {
    testWidgets('renders vector SVG icons with SvgPicture', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: _VectorIcon(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}

class _VectorIcon extends StatelessWidget {
  const _VectorIcon();

  @override
  Widget build(BuildContext context) {
    return markerSvgAssetPicture(
      assetPath: 'assets/markers/apartment.svg',
      width: 48,
      height: 48,
    );
  }
}
