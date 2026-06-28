// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/services.dart';

Future<bool> copyTextToClipboard(String text) async {
  // Run synchronously in the click handler so Brave/Chrome keep user activation.
  if (_copyWithExecCommand(text)) {
    return true;
  }

  try {
    final clipboard = html.window.navigator.clipboard;
    if (clipboard != null) {
      await clipboard.writeText(text);
      return true;
    }
  } catch (_) {}

  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    return false;
  }
}

bool _copyWithExecCommand(String text) {
  final textarea = html.TextAreaElement()
    ..value = text
    ..readOnly = true
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '0';
  html.document.body?.children.add(textarea);
  textarea.focus();
  textarea.select();
  textarea.setSelectionRange(0, text.length);
  final copied = html.document.execCommand('copy');
  textarea.remove();
  return copied;
}
