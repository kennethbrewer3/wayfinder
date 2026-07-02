import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import 'markers_provider.dart';

const _reconnectDelay = Duration(seconds: 5);

/// Keeps Serverpod streaming connections open and refreshes map data providers
/// whenever the server broadcasts marker or layer changes (REST, RPC, or restore).
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
  Future<void>? _markerLoop;
  Future<void>? _layerLoop;

  void start() {
    _markerLoop ??= _connectMarkerLoop();
    _layerLoop ??= _connectLayerLoop();
  }

  void dispose() {
    _stopped = true;
  }

  Future<void> _connectMarkerLoop() async {
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
          _ref.read(zonesProvider.notifier).reload();
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

  Future<void> _connectLayerLoop() async {
    while (!_stopped) {
      try {
        AppLogger.logMap.debug('📡 Connecting to layer change stream');
        final client = _ref.read(serverClientProvider);
        await for (final change in client.mapLayer.layerChanges()) {
          if (_stopped) {
            break;
          }
          AppLogger.logMap.debug(
            '📡 Layer change received',
            data: 'type=${change.type} id=${change.layerId}',
          );
          _ref.invalidate(layersProvider);
          if (change.type == 'deleted') {
            _ref.invalidate(markersProvider);
            _ref.read(zonesProvider.notifier).reload();
          }
        }
      } catch (error, stackTrace) {
        if (_stopped) {
          return;
        }
        AppLogger.logMap.warn(
          '📡 Layer change stream disconnected; reconnecting',
          error: error,
        );
        AppLogger.logMap.debug(
          '📡 Layer change stream stack trace',
          data: stackTrace,
        );
        await Future<void>.delayed(_reconnectDelay);
      }
    }
  }
}
