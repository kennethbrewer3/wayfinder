import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../mapping/radio_entity_mapper.dart';
import '../mapping/radio_uuid.dart';
import '../models/radio_domain_event.dart';
import 'radio_outbox_store.dart';

/// Applies radio outbox events to Serverpod with upsert / create-if-absent.
///
/// Returns the domain events that were successfully applied (for gateway
/// rebroadcast).
Future<List<RadioDomainEvent>> flushRadioOutbox({
  required Client client,
  required RadioOutboxStore store,
  RadioEntityMapper mapper = const RadioEntityMapper(),
}) async {
  final records = await store.load();
  if (records.isEmpty) {
    return const [];
  }

  final remaining = <RadioOutboxRecord>[];
  final flushedEvents = <RadioDomainEvent>[];
  for (final record in records) {
    final event = record.decode();
    if (event == null) {
      AppLogger.logMap.warn(
        'Radio outbox drop: undecodable frame',
        data: record.eventId,
      );
      continue;
    }
    try {
      await applyRadioEventToServer(
        client: client,
        mapper: mapper,
        event: event,
      );
      flushedEvents.add(event);
    } catch (error, stackTrace) {
      AppLogger.logMap.error(
        'Radio outbox flush failed',
        error: error,
        stackTrace: stackTrace,
        data: '${event.msgType} ${event.eventId}',
      );
      remaining.add(record);
    }
  }
  await store.save(remaining);
  if (flushedEvents.isNotEmpty) {
    AppLogger.logMap.success(
      'Radio outbox flushed',
      data: 'flushed=${flushedEvents.length} remaining=${remaining.length}',
    );
  }
  return flushedEvents;
}

/// Upsert / create-if-absent for one domain event (gateway + inbound mesh).
Future<void> applyRadioEventToServer({
  required Client client,
  required RadioEntityMapper mapper,
  required RadioDomainEvent event,
}) async {
  switch (event) {
    case HelloEvent():
    case EventAckEvent():
      return;
    case MarkerUpsertEvent():
      final id = UuidValue.fromString(event.entityId);
      final existing = await client.mapMarker.getMarker(id);
      if (existing != null &&
          radioUtcToSeconds(existing.updatedAt) > event.revisedAtSeconds) {
        return;
      }
      final marker = mapper.markerFromUpsert(event, existing: existing);
      await _upsertMarker(client, marker, creating: existing == null);
    case MarkerDeleteEvent():
      await client.mapMarker.deleteMarker(
        UuidValue.fromString(event.entityId),
      );
    case LogAppendEvent():
      final entry = mapper.watchLogFromAppend(event);
      try {
        await client.watchLog.createEntry(entry);
      } catch (_) {
        // Duplicate entity id from retry — ignore.
      }
    case ZoneUpsertLightEvent():
      final id = UuidValue.fromString(event.entityId);
      final existing = await client.mapZone.getZone(id);
      if (existing != null &&
          radioUtcToSeconds(existing.updatedAt) > event.revisedAtSeconds) {
        return;
      }
      final zone = mapper.zoneFromUpsertLight(event, existing: existing);
      if (zone == null) {
        throw StateError('Unsupported light zone geometry');
      }
      await _upsertZone(client, zone, creating: existing == null);
    case ZoneDeleteEvent():
      await client.mapZone.deleteZone(UuidValue.fromString(event.entityId));
    case EvacKitMetaUpsertEvent():
      final id = UuidValue.fromString(event.entityId);
      final existing = await client.mapZone.getZone(id);
      if (existing != null &&
          radioUtcToSeconds(existing.updatedAt) > event.revisedAtSeconds) {
        return;
      }
      final zone = mapper.applyEvacKitMeta(event, existing: existing);
      await _upsertZone(client, zone, creating: existing == null);
    case EvacRouteUpsertEvent():
      final id = UuidValue.fromString(event.entityId);
      var kit = await client.mapZone.getZone(id);
      if (kit == null) {
        final shell = mapper.applyEvacKitMeta(
          RadioDomainEvent.evacKitMetaUpsert(
                eventId: event.eventId,
                entityId: event.entityId,
                revisedAtSeconds: event.revisedAtSeconds,
                name: 'Evac kit',
                colorRgb: 0x1b4965,
                borderColorRgb: 0x1b4965,
                fillColorRgb: 0x1b4965,
                primaryRouteId: event.routeId,
                defaultMode: 0,
              )
              as EvacKitMetaUpsertEvent,
        );
        await _upsertZone(client, shell, creating: true);
        kit = await client.mapZone.getZone(id) ?? shell;
      }
      final updated = mapper.applyEvacRouteUpsert(event, kitZone: kit);
      if (updated == null) {
        throw StateError('Evac route upsert rejected');
      }
      await client.mapZone.updateZone(updated);
    case EvacRouteDeleteEvent():
      final kit = await client.mapZone.getZone(
        UuidValue.fromString(event.entityId),
      );
      if (kit == null) {
        return;
      }
      final updated = mapper.applyEvacRouteDelete(event, kitZone: kit);
      if (updated == null) {
        return;
      }
      await client.mapZone.updateZone(updated);
    case EvacKitDeleteEvent():
      await client.mapZone.deleteZone(UuidValue.fromString(event.entityId));
  }
}

Future<void> _upsertMarker(
  Client client,
  MapMarker marker, {
  required bool creating,
}) async {
  if (creating) {
    try {
      await client.mapMarker.createMarker(marker);
    } catch (_) {
      await client.mapMarker.updateMarker(marker);
    }
  } else {
    try {
      await client.mapMarker.updateMarker(marker);
    } catch (_) {
      await client.mapMarker.createMarker(marker);
    }
  }
}

Future<void> _upsertZone(
  Client client,
  MapZone zone, {
  required bool creating,
}) async {
  if (creating) {
    try {
      await client.mapZone.createZone(zone);
    } catch (_) {
      await client.mapZone.updateZone(zone);
    }
  } else {
    try {
      await client.mapZone.updateZone(zone);
    } catch (_) {
      await client.mapZone.createZone(zone);
    }
  }
}
