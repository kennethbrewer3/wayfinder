import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:web/web.dart' hide Clipboard;

Future<bool> copyTextToClipboard(String text) async {
  // Run synchronously in the click handler so Brave/Chrome keep user activation.
  if (_copyWithExecCommand(text)) {
    return true;
  }

  try {
    await window.navigator.clipboard.writeText(text).toDart;
    return true;
  } catch (_) {}

  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    return false;
  }
}

bool _copyWithExecCommand(String text) {
  final textarea = HTMLTextAreaElement()
    ..value = text
    ..readOnly = true
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '0';
  document.body?.append(textarea);
  textarea.focus();
  textarea.select();
  textarea.setSelectionRange(0, text.length);
  final copied = document.execCommand('copy');
  textarea.remove();
  return copied;
}
