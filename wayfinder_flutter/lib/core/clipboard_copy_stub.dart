import 'package:flutter/services.dart';

Future<bool> copyTextToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  return true;
}
