import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Bundled monospace family for OTP UI (declared in pubspec.yaml).
const commsOneTimePadFontFamily = 'Noto Sans Mono';

const _otpMonoBoldAsset = 'assets/fonts/NotoSansMono-Bold.ttf';

/// Loads the embedded OTP mono bold face for PDF embedding.
///
/// Using a bundled TTF (not platform Courier) keeps pad columns identical on
/// every install and PDF viewer.
Future<pw.Font> loadCommsOneTimePadPdfFont() async {
  final data = await rootBundle.load(_otpMonoBoldAsset);
  return pw.Font.ttf(data);
}
