import '../models/radio_domain_event.dart';

/// Result of applying one radio domain event to local state.
enum RadioApplyOutcome {
  applied,
  duplicateEvent,
  ignoredStale,
  ignoredDeleteAlreadyGone,
  ackOnly,
  helloOnly,
}

class RadioApplyResult {
  const RadioApplyResult(this.outcome, {this.event});

  final RadioApplyOutcome outcome;
  final RadioDomainEvent? event;
}

/// In-memory apply engine: dedupe by `eventId`, LWW by `revisedAt` / entity.
///
/// This is the Phase B reference store. Later phases will map applied events
/// onto Serverpod entities / providers.
class RadioEventApplier {
  final Set<String> _seenEventIds = {};
  final Map<String, RadioDomainEvent> _entities = {};
  final Map<String, Map<String, EvacRouteUpsertEvent>> _evacRoutes = {};
  final List<LogAppendEvent> _logs = [];
  final List<HelloEvent> _hellos = [];
  final List<EventAckEvent> _acks = [];

  Map<String, RadioDomainEvent> get entities => Map.unmodifiable(_entities);
  List<LogAppendEvent> get logs => List.unmodifiable(_logs);
  List<HelloEvent> get hellos => List.unmodifiable(_hellos);

  Map<String, EvacRouteUpsertEvent> routesForKit(String kitId) =>
      Map.unmodifiable(_evacRoutes[kitId] ?? const {});

  RadioApplyResult apply(RadioDomainEvent event) {
    if (!_seenEventIds.add(event.eventId)) {
      return const RadioApplyResult(RadioApplyOutcome.duplicateEvent);
    }

    switch (event) {
      case EventAckEvent():
        _acks.add(event);
        return RadioApplyResult(RadioApplyOutcome.ackOnly, event: event);
      case HelloEvent():
        _hellos.add(event);
        return RadioApplyResult(RadioApplyOutcome.helloOnly, event: event);
      case LogAppendEvent():
        _logs.add(event);
        return RadioApplyResult(RadioApplyOutcome.applied, event: event);
      case MarkerDeleteEvent(:final entityId, :final revisedAtSeconds):
      case ZoneDeleteEvent(:final entityId, :final revisedAtSeconds):
      case EvacKitDeleteEvent(:final entityId, :final revisedAtSeconds):
        final existing = _entities[entityId];
        if (existing == null) {
          _entities[entityId] = event;
          return RadioApplyResult(RadioApplyOutcome.applied, event: event);
        }
        if (_isDelete(existing)) {
          return const RadioApplyResult(
            RadioApplyOutcome.ignoredDeleteAlreadyGone,
          );
        }
        if (existing.revisedAtSeconds > revisedAtSeconds) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        _entities[entityId] = event;
        _evacRoutes.remove(entityId);
        return RadioApplyResult(RadioApplyOutcome.applied, event: event);
      case EvacRouteDeleteEvent(
        :final entityId,
        :final routeId,
        :final revisedAtSeconds,
      ):
        final kit = _entities[entityId];
        if (kit != null &&
            kit is! EvacKitDeleteEvent &&
            kit.revisedAtSeconds > revisedAtSeconds) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        final routes = _evacRoutes[entityId];
        if (routes == null || !routes.containsKey(routeId)) {
          return const RadioApplyResult(
            RadioApplyOutcome.ignoredDeleteAlreadyGone,
          );
        }
        routes.remove(routeId);
        return RadioApplyResult(RadioApplyOutcome.applied, event: event);
      case EvacRouteUpsertEvent(
        :final entityId,
        :final routeId,
        :final revisedAtSeconds,
        :final waypoints,
      ):
        if (waypoints.length < 2) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        final kit = _entities[entityId];
        if (kit is EvacKitDeleteEvent &&
            kit.revisedAtSeconds >= revisedAtSeconds) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        final routes = _evacRoutes.putIfAbsent(entityId, () => {});
        final existingRoute = routes[routeId];
        if (existingRoute != null &&
            existingRoute.revisedAtSeconds > revisedAtSeconds) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        routes[routeId] = event;
        return RadioApplyResult(RadioApplyOutcome.applied, event: event);
      case MarkerUpsertEvent(:final entityId, :final revisedAtSeconds):
      case ZoneUpsertLightEvent(:final entityId, :final revisedAtSeconds):
      case EvacKitMetaUpsertEvent(:final entityId, :final revisedAtSeconds):
        final existing = _entities[entityId];
        if (existing != null && existing.revisedAtSeconds > revisedAtSeconds) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        if (existing is EvacKitDeleteEvent &&
            existing.revisedAtSeconds >= revisedAtSeconds) {
          return const RadioApplyResult(RadioApplyOutcome.ignoredStale);
        }
        _entities[entityId] = event;
        return RadioApplyResult(RadioApplyOutcome.applied, event: event);
    }
  }

  bool _isDelete(RadioDomainEvent event) => switch (event) {
    MarkerDeleteEvent() => true,
    ZoneDeleteEvent() => true,
    EvacKitDeleteEvent() => true,
    _ => false,
  };
}
