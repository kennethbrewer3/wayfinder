import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<void> setBrowserContextMenuEnabled(bool enabled) async {
  if (!kIsWeb) {
    return;
  }
  if (enabled) {
    await BrowserContextMenu.enableContextMenu();
  } else {
    await BrowserContextMenu.disableContextMenu();
  }
}
