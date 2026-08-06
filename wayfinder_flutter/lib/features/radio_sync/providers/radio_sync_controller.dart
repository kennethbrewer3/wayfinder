import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../evac_kits/models/evac_kit_geometry.dart';
import '../../markers/providers/markers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../../watch_log/providers/watch_log_provider.dart';
import '../apply/radio_event_applier.dart';
import '../data/radio_outbox_flush.dart';
import '../data/radio_outbox_store.dart';
import '../mapping/radio_entity_mapper.dart';
import '../models/radio_domain_event.dart';
import '../session/radio_sync_session.dart';
import '../transport/fake_mesh_hub.dart';
import '../transport/ham_digimode.dart';
import '../transport/mesh_radio_transport.dart';
import '../transport/meshcore_channel_stub.dart';
import '../transport/meshtastic_channel_stub.dart';
import '../transport/radio_transport.dart';
import 'radio_mesh_link_provider.dart';
import 'radio_sync_enabled_provider.dart';

final radioOutboxStoreProvider = Provider<RadioOutboxStore>((ref) {
  return RadioOutboxStore();
});

/// Shared simulated mesh hub.
final fakeMeshHubProvider = Provider<FakeMeshHub>((ref) {
  final hub = FakeMeshHub();
  ref.onDispose(hub.dispose);
  return hub;
});

/// Shared simulated ham hub (tiny MTU).
final fakeHamHubProvider = Provider<FakeHamHub>((ref) {
  final hub = FakeHamHub();
  ref.onDispose(hub.dispose);
  return hub;
});

final radioSyncControllerProvider = Provider<RadioSyncController>((ref) {
  final controller = RadioSyncController(ref);
  ref.onDispose(controller.dispose);
  ref.listen<bool>(radioSyncEnabledProvider, (_, next) {
    unawaited(controller.syncMeshSession());
  });
  ref.listen<RadioMeshLinkMode>(radioMeshLinkModeProvider, (_, next) {
    unawaited(controller.syncMeshSession());
  });
  unawaited(controller.syncMeshSession());
  return controller;
});

final radioOutboxPendingCountProvider = FutureProvider<int>((ref) async {
  ref.watch(radioSyncEnabledProvider);
  return ref.read(radioOutboxStoreProvider).pendingCount;
});

final radioMeshSessionActiveProvider = StateProvider<bool>((ref) => false);

/// Outbox flush + live mesh/ham session (bidirectional + gateway rebroadcast).
class RadioSyncController {
  RadioSyncController(this._ref);

  final Ref _ref;
  final RadioEntityMapper _mapper = const RadioEntityMapper();

  RadioSyncSession? _session;
  RadioTransport? _transport;
  StreamSubscription<RadioApplyResult>? _inboundSub;
  MeshtasticChannelStub? _meshtasticStub;
  MeshCoreChannelStub? _meshCoreStub;
  HamDigimodeChannelStub? _hamStub;

  bool get enabled => _ref.read(radioSyncEnabledProvider);
  RadioSyncSession? get session => _session;

  void _setMeshActive(bool active) {
    _ref.read(radioMeshSessionActiveProvider.notifier).state = active;
  }

  void attachSession(RadioSyncSession? session) {
    _inboundSub?.cancel();
    _inboundSub = null;
    _session = session;
    _setMeshActive(session != null);
    if (session != null) {
      _inboundSub = session.applied.listen(_onInboundApplied);
    }
  }

  Future<void> syncMeshSession() async {
    await _teardownMesh();
    if (!enabled) {
      return;
    }
    final mode = _ref.read(radioMeshLinkModeProvider);
    switch (mode) {
      case RadioMeshLinkMode.off:
        return;
      case RadioMeshLinkMode.simulated:
        await _startSession(
          _ref.read(fakeMeshHubProvider).join(peerId: 'local'),
        );
      case RadioMeshLinkMode.meshtastic:
        if (kIsWeb) {
          AppLogger.logMap.warn(
            'Meshtastic mesh link is not available on web',
          );
          return;
        }
        _meshtasticStub = MeshtasticChannelStub();
        await _startSession(MeshRadioTransport(_meshtasticStub!));
        AppLogger.logMap.info(
          'Meshtastic adapter ready (BLE bridge not connected yet)',
        );
      case RadioMeshLinkMode.meshcore:
        if (kIsWeb) {
          AppLogger.logMap.warn(
            'MeshCore mesh link is not available on web',
          );
          return;
        }
        _meshCoreStub = MeshCoreChannelStub();
        await _startSession(MeshRadioTransport(_meshCoreStub!));
        AppLogger.logMap.info(
          'MeshCore adapter ready (companion BLE/USB bridge not connected yet)',
        );
      case RadioMeshLinkMode.simulatedHam:
        await _startSession(
          _ref.read(fakeHamHubProvider).join(peerId: 'local'),
        );
      case RadioMeshLinkMode.hamDigimode:
        _hamStub = HamDigimodeChannelStub();
        await _startSession(hamRadioTransport(_hamStub!));
        AppLogger.logMap.info(
          'Ham digimode adapter ready (modem bridge not connected yet)',
        );
    }
  }

  Future<void> _startSession(RadioTransport transport) async {
    _transport = transport;
    final session = RadioSyncSession(transport: transport);
    _session = session;
    _setMeshActive(true);
    _inboundSub = session.applied.listen(_onInboundApplied);
    try {
      await session.publish(
        RadioDomainEvent.hello(
          eventId: const Uuid().v4(),
          entityId: const Uuid().v4(),
          revisedAtSeconds:
              DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
          senderUnitId: 'wayfinder',
          schemaVersion: 1,
        ),
      );
    } catch (error, _) {
      AppLogger.logMap.warn(
        'Radio live-link hello not sent',
        error: error,
      );
    }
  }

  Future<void> _teardownMesh() async {
    await _inboundSub?.cancel();
    _inboundSub = null;
    await _session?.dispose();
    _session = null;
    await _transport?.dispose();
    _transport = null;
    _meshtasticStub = null;
    _meshCoreStub = null;
    _hamStub = null;
    _setMeshActive(false);
  }

  Future<void> dispose() => _teardownMesh();

  Future<void> emit(RadioDomainEvent event) async {
    if (!enabled) {
      return;
    }
    await _ref.read(radioOutboxStoreProvider).enqueue(event);
    await _publishLive(event);
    _ref.invalidate(radioOutboxPendingCountProvider);
  }

  Future<void> emitMarkerUpsert(MapMarker marker) =>
      emit(_mapper.markerUpsertFrom(marker));

  Future<void> emitMarkerDelete(UuidValue markerId) => emit(
    _mapper.markerDeleteFrom(
      markerId,
      revisedAt: DateTime.now().toUtc(),
    ),
  );

  Future<void> emitLogAppend(WatchLogEntry entry) =>
      emit(_mapper.logAppendFrom(entry));

  Future<void> emitCircleZone(MapZone zone) => emitLightZone(zone);

  /// Circle / line / polygon light-zone upsert (Phase F).
  Future<void> emitLightZone(MapZone zone) async {
    final event = _mapper.zoneUpsertLightFrom(zone);
    if (event != null) {
      await emit(event);
    }
  }

  Future<void> emitZoneDelete(UuidValue zoneId, {required String zoneType}) {
    if (zoneType == evacKitZoneType) {
      return emit(
        _mapper.evacKitDeleteFrom(
          zoneId,
          revisedAt: DateTime.now().toUtc(),
        ),
      );
    }
    return emit(
      RadioDomainEvent.zoneDelete(
        eventId: const Uuid().v4(),
        entityId: zoneId.uuid,
        revisedAtSeconds: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
      ),
    );
  }

  Future<void> emitEvacKit(MapZone zone) async {
    final geometry = EvacKitGeometry.fromZone(zone);
    if (geometry == null) {
      return;
    }
    await emit(_mapper.evacKitMetaFrom(zone, geometry));
    for (final route in geometry.routes) {
      final routeEvent = _mapper.evacRouteUpsertFrom(
        kitZone: zone,
        route: route,
      );
      if (routeEvent != null) {
        await emit(routeEvent);
      }
    }
  }

  /// Flush outbox when the server is reachable, then rebroadcast on live link.
  Future<int> flushIfNeeded() async {
    if (!_ref.read(serverReachableProvider)) {
      return 0;
    }
    final flushedEvents = await flushRadioOutbox(
      client: _ref.read(serverClientProvider),
      store: _ref.read(radioOutboxStoreProvider),
      mapper: _mapper,
    );
    if (flushedEvents.isNotEmpty) {
      _invalidateMapProviders();
      _ref.invalidate(radioOutboxPendingCountProvider);
      for (final event in flushedEvents) {
        await _rebroadcast(event);
      }
    }
    return flushedEvents.length;
  }

  Future<void> _onInboundApplied(RadioApplyResult result) async {
    final event = result.event;
    if (event == null) {
      return;
    }
    switch (result.outcome) {
      case RadioApplyOutcome.duplicateEvent:
      case RadioApplyOutcome.ignoredStale:
      case RadioApplyOutcome.ignoredDeleteAlreadyGone:
      case RadioApplyOutcome.ackOnly:
      case RadioApplyOutcome.helloOnly:
        return;
      case RadioApplyOutcome.applied:
        break;
    }

    if (_ref.read(serverReachableProvider)) {
      try {
        await applyRadioEventToServer(
          client: _ref.read(serverClientProvider),
          mapper: _mapper,
          event: event,
        );
        _invalidateMapProviders();
        // Gateway echo so other radio peers converge.
        await _rebroadcast(event);
      } catch (error, stackTrace) {
        AppLogger.logMap.error(
          'Inbound radio apply to server failed; queuing outbox',
          error: error,
          stackTrace: stackTrace,
        );
        await _ref.read(radioOutboxStoreProvider).enqueue(event);
        _ref.invalidate(radioOutboxPendingCountProvider);
      }
    } else {
      await _ref.read(radioOutboxStoreProvider).enqueue(event);
      _ref.invalidate(radioOutboxPendingCountProvider);
    }
  }

  Future<void> _publishLive(RadioDomainEvent event) async {
    final session = _session;
    if (session == null) {
      return;
    }
    try {
      await session.publish(event);
    } catch (error, _) {
      AppLogger.logMap.warn(
        'Radio sync publish failed (kept in outbox)',
        error: error,
      );
    }
  }

  Future<void> _rebroadcast(RadioDomainEvent event) async {
    switch (event) {
      case HelloEvent():
      case EventAckEvent():
        return;
      default:
        await _publishLive(event);
    }
  }

  void _invalidateMapProviders() {
    _ref.invalidate(markersProvider);
    _ref.invalidate(watchLogEntriesProvider);
    _ref.read(zonesProvider.notifier).reload();
  }
}
