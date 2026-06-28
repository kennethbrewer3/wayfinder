import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import 'markers_provider.dart';

const _reconnectDelay = Duration(seconds: 5);

/// Keeps a Serverpod streaming connection open and refreshes [markersProvider]
/// whenever the server broadcasts marker changes (REST, RPC, or restore).
final mapMarkerUpdatesListenerProvider = Provider<MapMarkerUpdatesListener>(
  (ref) {
    final listener = MapMarkerUpdatesListener(ref);
    listener.start();
    ref.onDispose(listener.dispose);
    return listener;
  },
);

class MapMarkerUpdatesListener {
  MapMarkerUpdatesListener(this._ref);

  final Ref _ref;
  var _stopped = false;
  Future<void>? _loop;

  void start() {
    _loop ??= _connectLoop();
  }

  void dispose() {
    _stopped = true;
  }

  Future<void> _connectLoop() async {
    while (!_stopped) {
      try {
        AppLogger.logMarkers.debug('📡 Connecting to marker change stream');
        final client = _ref.read(serverClientProvider);
        await for (final change in client.mapMarker.markerChanges()) {
          if (_stopped) {
            break;
          }
          AppLogger.logMarkers.debug(
            '📡 Marker change received',
            data: 'type=${change.type} id=${change.markerId}',
          );
          _ref.invalidate(markersProvider);
        }
      } catch (error, stackTrace) {
        if (_stopped) {
          return;
        }
        AppLogger.logMarkers.warn(
          '📡 Marker change stream disconnected; reconnecting',
          error: error,
        );
        AppLogger.logMarkers.debug(
          '📡 Marker change stream stack trace',
          data: stackTrace,
        );
        await Future<void>.delayed(_reconnectDelay);
      }
    }
  }
}
