import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_raster_svg.dart';
import 'package:wayfinder_flutter/features/markers/presentation/marker_svg_picture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('extractPngFromRasterSvg', () {
    test('returns null for vector SVG assets', () {
      final bytes = File('assets/markers/apartment.svg').readAsBytesSync();
      expect(extractPngFromRasterSvg(bytes), isNull);
    });

    test('extracts PNG bytes from raster wrapper SVG assets', () {
      final bytes = File('assets/markers/retreat.svg').readAsBytesSync();
      final pngBytes = extractPngFromRasterSvg(bytes);
      expect(pngBytes, isNotNull);
      expect(pngBytes!.length, greaterThan(100));
      expect(
        String.fromCharCodes(pngBytes.take(4)),
        '\x89PNG',
      );
    });

    test('extracts PNG from all optimized raster wrapper icons', () {
      final markerDir = Directory('assets/markers');
      final rasterWrappers = markerDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.svg'))
          .where((file) {
            final text = file.readAsStringSync();
            return text.contains('data:image/png;base64,');
          })
          .toList();

      expect(rasterWrappers, isNotEmpty);
      for (final file in rasterWrappers) {
        final pngBytes = extractPngFromRasterSvg(file.readAsBytesSync());
        expect(
          pngBytes,
          isNotNull,
          reason: file.path,
        );
      }
    });
  });

  group('markerSvgAssetPicture', () {
    testWidgets('renders raster wrapper icons with Image.memory', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: _RasterWrapperIcon(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });

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

class _RasterWrapperIcon extends StatelessWidget {
  const _RasterWrapperIcon();

  @override
  Widget build(BuildContext context) {
    return markerSvgAssetPicture(
      assetPath: 'assets/markers/retreat.svg',
      width: 48,
      height: 48,
    );
  }
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
