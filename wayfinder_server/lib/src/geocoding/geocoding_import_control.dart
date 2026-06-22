import 'dart:io';

import 'geocoding_import_exceptions.dart';

/// Cooperative cancellation for long-running geocoding imports.
abstract final class GeocodingImportControl {
  static HttpClient? _activeClient;
  static bool _cancelRequested = false;

  static void begin() {
    _cancelRequested = false;
    _activeClient = null;
  }

  static void attachClient(HttpClient client) {
    _activeClient = client;
  }

  static void requestCancel() {
    _cancelRequested = true;
    _activeClient?.close(force: true);
    _activeClient = null;
  }

  static bool get cancelRequested => _cancelRequested;

  static void checkCancelled() {
    if (_cancelRequested) {
      throw const ImportCancelledException();
    }
  }

  static void end() {
    _cancelRequested = false;
    _activeClient = null;
  }
}
