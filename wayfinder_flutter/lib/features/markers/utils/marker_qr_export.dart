import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

const wayfinderFaviconAsset = 'assets/wayfinder-favicon.png';

/// Fraction of the QR module grid reserved for the center logo.
const markerQrLogoModuleFraction = 0.22;

const markerQrExportSize = 1024.0;

Future<Uint8List> loadWayfinderFaviconBytes() async {
  final data = await rootBundle.load(wayfinderFaviconAsset);
  return data.buffer.asUint8List();
}

Future<ui.Image> loadWayfinderFaviconImage() async {
  final bytes = await loadWayfinderFaviconBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<Uint8List> buildMarkerQrPngBytes({
  required String data,
  ui.Image? embeddedImage,
  double size = markerQrExportSize,
}) async {
  final logo = embeddedImage ?? await loadWayfinderFaviconImage();
  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
    gapless: true,
    embeddedImage: logo,
    embeddedImageStyle: QrEmbeddedImageStyle(
      size: Size(
        size * markerQrLogoModuleFraction,
        size * markerQrLogoModuleFraction,
      ),
    ),
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF000000),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF000000),
    ),
  );

  final byteData = await painter.toImageData(
    size,
    format: ui.ImageByteFormat.png,
  );
  if (byteData == null) {
    throw StateError('Failed to render QR code PNG.');
  }
  return byteData.buffer.asUint8List();
}

/// Builds an SVG with vector QR modules and an embedded PNG favicon in the
/// center (true vector for the code; favicon remains raster).
Future<String> buildMarkerQrSvg({
  required String data,
  Uint8List? faviconPngBytes,
  int size = 1024,
}) async {
  final favicon = faviconPngBytes ?? await loadWayfinderFaviconBytes();
  final qrCode = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.H,
  );
  final qrImage = QrImage(qrCode);
  final moduleCount = qrImage.moduleCount;
  const quietZone = 4;
  final totalModules = moduleCount + quietZone * 2;
  final moduleSize = size / totalModules;

  var logoModules = (moduleCount * markerQrLogoModuleFraction).round();
  if (logoModules.isOdd) {
    logoModules += 1;
  }
  logoModules = logoModules.clamp(4, moduleCount - 8);
  final logoStart = (moduleCount - logoModules) ~/ 2;
  final logoEnd = logoStart + logoModules;

  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'width="$size" height="$size" viewBox="0 0 $size $size">',
    )
    ..writeln('<rect width="100%" height="100%" fill="#FFFFFF"/>');

  for (var y = 0; y < moduleCount; y++) {
    for (var x = 0; x < moduleCount; x++) {
      final inLogo =
          x >= logoStart && x < logoEnd && y >= logoStart && y < logoEnd;
      if (inLogo || !qrImage.isDark(y, x)) {
        continue;
      }
      final px = _svgNumber((x + quietZone) * moduleSize);
      final py = _svgNumber((y + quietZone) * moduleSize);
      final dim = _svgNumber(moduleSize);
      buffer.writeln(
        '<rect x="$px" y="$py" width="$dim" height="$dim" fill="#000000"/>',
      );
    }
  }

  final logoPx = (logoStart + quietZone) * moduleSize;
  final logoSize = logoModules * moduleSize;
  final pad = logoSize * 0.08;
  final imageX = logoPx + pad;
  final imageY = logoPx + pad;
  final imageSize = logoSize - pad * 2;
  final radius = logoSize * 0.12;
  final b64 = base64Encode(favicon);

  buffer
    ..writeln(
      '<rect x="${_svgNumber(logoPx)}" y="${_svgNumber(logoPx)}" '
      'width="${_svgNumber(logoSize)}" height="${_svgNumber(logoSize)}" '
      'rx="${_svgNumber(radius)}" fill="#FFFFFF"/>',
    )
    ..writeln(
      '<image x="${_svgNumber(imageX)}" y="${_svgNumber(imageY)}" '
      'width="${_svgNumber(imageSize)}" height="${_svgNumber(imageSize)}" '
      'preserveAspectRatio="xMidYMid meet" '
      'href="data:image/png;base64,$b64" '
      'xlink:href="data:image/png;base64,$b64"/>',
    )
    ..writeln('</svg>');

  return buffer.toString();
}

String sanitizeMarkerQrFileStem(String name) {
  final trimmed = name.trim();
  final base = trimmed.isEmpty ? 'marker' : trimmed;
  final cleaned = base
      .replaceAll(RegExp(r'[^\w\-. ]+', unicode: true), '_')
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (cleaned.isEmpty) {
    return 'marker';
  }
  return cleaned.length > 48 ? cleaned.substring(0, 48) : cleaned;
}

String _svgNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(3);
}
