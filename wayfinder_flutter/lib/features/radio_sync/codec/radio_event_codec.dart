import 'dart:typed_data';

import '../models/evac_waypoint_air.dart';
import '../models/radio_domain_event.dart';
import '../models/radio_sync_msg_type.dart';
import 'radio_binary_io.dart';
import 'radio_frame.dart';

/// Air string maxima from `radio-sync-events.md`.
abstract final class RadioAirLimits {
  static const int name = 40;
  static const int notes = 80;
  static const int logAuthor = 20;
  static const int logText = 180;
  static const int routeName = 32;
  static const int waypointLabel = 20;
  static const int senderUnitId = 32;
  static const int maxWaypoints = 24;
}

/// Encode / decode [RadioDomainEvent] as CRC-checked radio frames.
class RadioEventCodec {
  const RadioEventCodec();

  /// Encode a domain event to a single frame (no chunking).
  Uint8List encode(RadioDomainEvent event, {int flags = 0}) {
    final payload = encodePayload(event);
    return encodeRadioFrame(
      msgType: event.msgType,
      eventId: event.eventId,
      entityId: event.entityId,
      revisedAtSeconds: event.revisedAtSeconds,
      payload: payload,
      flags: flags,
    );
  }

  /// Decode a frame into a domain event. Returns `null` if CRC fails, version
  /// is unsupported, or the msgType/payload is unknown/invalid.
  RadioDomainEvent? decode(Uint8List frameBytes) {
    final frame = decodeRadioFrame(frameBytes);
    if (frame == null) {
      return null;
    }
    if (frame.version != radioFrameVersion) {
      return null;
    }
    if (frame.msgType == RadioSyncMsgType.chunk) {
      return null;
    }
    try {
      return decodePayload(
        msgType: frame.msgType,
        eventId: frame.eventId,
        entityId: frame.entityId,
        revisedAtSeconds: frame.revisedAtSeconds,
        payload: frame.payload,
      );
    } on FormatException {
      return null;
    }
  }

  Uint8List encodePayload(RadioDomainEvent event) {
    final w = RadioBinaryWriter();
    switch (event) {
      case MarkerUpsertEvent(
        :final name,
        :final latE7,
        :final lonE7,
        :final elevationMeters,
        :final colorRgb,
        :final iconId,
        :final visible,
        :final layerId,
        :final notes,
        :final notesTruncated,
        :final isTracking,
      ):
        var flags = 0;
        if (elevationMeters != 0) {
          flags |= 1 << 0;
        }
        if (visible) {
          flags |= 1 << 1;
        }
        if (layerId != null && layerId.isNotEmpty) {
          flags |= 1 << 2;
        }
        final hasNotes = notes != null && notes.isNotEmpty;
        if (hasNotes) {
          flags |= 1 << 3;
        }
        if (notesTruncated) {
          flags |= 1 << 4;
        }
        if (isTracking) {
          flags |= 1 << 5;
        }
        final nameTrunc = w.utf8u8(name, maxChars: RadioAirLimits.name);
        if (nameTrunc) {
          // Name truncation is silent at codec layer; callers should pre-trim.
        }
        w.i32(latE7);
        w.i32(lonE7);
        w.u8(flags);
        if (elevationMeters != 0) {
          w.i16(elevationMeters.clamp(-32768, 32767));
        }
        w.u32(colorRgb);
        w.u8(iconId & 0xff);
        if (layerId != null && layerId.isNotEmpty) {
          w.uuid(layerId);
        }
        if (hasNotes) {
          w.utf8u8(notes, maxChars: RadioAirLimits.notes);
        }
      case MarkerDeleteEvent():
      case ZoneDeleteEvent():
      case EvacKitDeleteEvent():
        break;
      case ZoneUpsertLightEvent(
        :final name,
        :final zoneType,
        :final colorRgb,
        :final borderColorRgb,
        :final fillColorRgb,
        :final visible,
        :final layerId,
        :final geometryBytes,
      ):
        var flags = 0;
        if (visible) {
          flags |= 1 << 0;
        }
        if (layerId != null && layerId.isNotEmpty) {
          flags |= 1 << 1;
        }
        w.utf8u8(name, maxChars: RadioAirLimits.name);
        w.u8(zoneType & 0xff);
        w.u8(flags);
        w.u32(colorRgb);
        w.u32(borderColorRgb);
        w.u32(fillColorRgb);
        if (layerId != null && layerId.isNotEmpty) {
          w.uuid(layerId);
        }
        if (geometryBytes.length > 0xffff) {
          throw ArgumentError('Zone geometry exceeds uint16 length');
        }
        w.u16(geometryBytes.length);
        w.bytes(Uint8List.fromList(geometryBytes));
      case LogAppendEvent(
        :final occurredAtSeconds,
        :final severity,
        :final author,
        :final text,
        :final textTruncated,
        :final markerId,
        :final zoneId,
      ):
        var flags = 0;
        if (textTruncated) {
          flags |= 1 << 0;
        }
        if (markerId != null && markerId.isNotEmpty) {
          flags |= 1 << 1;
        }
        if (zoneId != null && zoneId.isNotEmpty) {
          flags |= 1 << 2;
        }
        w.u32(occurredAtSeconds);
        w.u8(severity & 0xff);
        w.u8(flags);
        w.utf8u8(author ?? '', maxChars: RadioAirLimits.logAuthor);
        w.utf8u8(text, maxChars: RadioAirLimits.logText);
        if (markerId != null && markerId.isNotEmpty) {
          w.uuid(markerId);
        }
        if (zoneId != null && zoneId.isNotEmpty) {
          w.uuid(zoneId);
        }
      case EventAckEvent(:final ackedEventId, :final status):
        w.uuid(ackedEventId);
        w.u8(status & 0xff);
      case EvacKitMetaUpsertEvent(
        :final name,
        :final colorRgb,
        :final borderColorRgb,
        :final fillColorRgb,
        :final visible,
        :final layerId,
        :final primaryRouteId,
        :final defaultMode,
        :final showNameLabel,
        :final notes,
        :final notesTruncated,
      ):
        var flags = 0;
        if (visible) {
          flags |= 1 << 0;
        }
        if (layerId != null && layerId.isNotEmpty) {
          flags |= 1 << 1;
        }
        if (showNameLabel) {
          flags |= 1 << 2;
        }
        final hasNotes = notes != null && notes.isNotEmpty;
        if (hasNotes) {
          flags |= 1 << 3;
        }
        if (notesTruncated) {
          flags |= 1 << 4;
        }
        w.utf8u8(name, maxChars: RadioAirLimits.name);
        w.u8(flags);
        w.u32(colorRgb);
        w.u32(borderColorRgb);
        w.u32(fillColorRgb);
        w.uuid(primaryRouteId);
        w.u8(defaultMode & 0xff);
        if (layerId != null && layerId.isNotEmpty) {
          w.uuid(layerId);
        }
        if (hasNotes) {
          w.utf8u8(notes, maxChars: RadioAirLimits.notes);
        }
      case EvacRouteUpsertEvent(
        :final routeId,
        :final name,
        :final role,
        :final colorRgb,
        :final borderPattern,
        :final showArrows,
        :final pathMode,
        :final waypoints,
      ):
        if (waypoints.length > RadioAirLimits.maxWaypoints) {
          throw ArgumentError(
            'Evac route exceeds ${RadioAirLimits.maxWaypoints} waypoints',
          );
        }
        var flags = 0;
        if (colorRgb != null) {
          flags |= 1 << 0;
        }
        if (showArrows) {
          flags |= 1 << 1;
        }
        w.uuid(routeId);
        w.utf8u8(name, maxChars: RadioAirLimits.routeName);
        w.u8(role & 0xff);
        w.u8(flags);
        w.u8(borderPattern & 0xff);
        w.u8(pathMode & 0xff);
        if (colorRgb != null) {
          w.u32(colorRgb);
        }
        w.u8(waypoints.length);
        for (final wp in waypoints) {
          var wpFlags = 0;
          if (wp.markerId != null && wp.markerId!.isNotEmpty) {
            wpFlags |= 1 << 0;
          }
          if (wp.label != null && wp.label!.isNotEmpty) {
            wpFlags |= 1 << 1;
          }
          w.u8(wp.kind & 0xff);
          w.u8(wpFlags);
          w.i32(wp.latE7);
          w.i32(wp.lonE7);
          if (wp.markerId != null && wp.markerId!.isNotEmpty) {
            w.uuid(wp.markerId!);
          }
          if (wp.label != null && wp.label!.isNotEmpty) {
            w.utf8u8(wp.label!, maxChars: RadioAirLimits.waypointLabel);
          }
        }
      case EvacRouteDeleteEvent(:final routeId):
        w.uuid(routeId);
      case HelloEvent(:final senderUnitId, :final schemaVersion):
        w.utf8u8(senderUnitId, maxChars: RadioAirLimits.senderUnitId);
        w.u16(schemaVersion & 0xffff);
    }
    return w.toBytes();
  }

  RadioDomainEvent decodePayload({
    required int msgType,
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required Uint8List payload,
  }) {
    final r = RadioBinaryReader(payload);
    switch (msgType) {
      case RadioSyncMsgType.markerUpsert:
        final name = r.utf8u8();
        final latE7 = r.i32();
        final lonE7 = r.i32();
        final flags = r.u8();
        final elevation = (flags & (1 << 0)) != 0 ? r.i16() : 0;
        final colorRgb = r.u32();
        final iconId = r.u8();
        final layerId = (flags & (1 << 2)) != 0 ? r.uuid() : null;
        final notes = (flags & (1 << 3)) != 0 ? r.utf8u8() : null;
        return RadioDomainEvent.markerUpsert(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          name: name,
          latE7: latE7,
          lonE7: lonE7,
          elevationMeters: elevation,
          colorRgb: colorRgb,
          iconId: iconId,
          visible: (flags & (1 << 1)) != 0,
          layerId: layerId,
          notes: notes,
          notesTruncated: (flags & (1 << 4)) != 0,
          isTracking: (flags & (1 << 5)) != 0,
        );
      case RadioSyncMsgType.markerDelete:
        return RadioDomainEvent.markerDelete(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
        );
      case RadioSyncMsgType.zoneUpsertLight:
        final name = r.utf8u8();
        final zoneType = r.u8();
        final flags = r.u8();
        final colorRgb = r.u32();
        final borderColorRgb = r.u32();
        final fillColorRgb = r.u32();
        final layerId = (flags & (1 << 1)) != 0 ? r.uuid() : null;
        final geoLen = r.u16();
        final geometryBytes = r.bytes(geoLen);
        return RadioDomainEvent.zoneUpsertLight(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          name: name,
          zoneType: zoneType,
          colorRgb: colorRgb,
          borderColorRgb: borderColorRgb,
          fillColorRgb: fillColorRgb,
          visible: (flags & (1 << 0)) != 0,
          layerId: layerId,
          geometryBytes: geometryBytes,
        );
      case RadioSyncMsgType.zoneDelete:
        return RadioDomainEvent.zoneDelete(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
        );
      case RadioSyncMsgType.logAppend:
        final occurredAtSeconds = r.u32();
        final severity = r.u8();
        final flags = r.u8();
        final authorRaw = r.utf8u8();
        final text = r.utf8u8();
        final markerId = (flags & (1 << 1)) != 0 ? r.uuid() : null;
        final zoneId = (flags & (1 << 2)) != 0 ? r.uuid() : null;
        return RadioDomainEvent.logAppend(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          occurredAtSeconds: occurredAtSeconds,
          severity: severity,
          author: authorRaw.isEmpty ? null : authorRaw,
          text: text,
          textTruncated: (flags & (1 << 0)) != 0,
          markerId: markerId,
          zoneId: zoneId,
        );
      case RadioSyncMsgType.eventAck:
        final ackedEventId = r.uuid();
        final status = r.u8();
        return RadioDomainEvent.eventAck(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          ackedEventId: ackedEventId,
          status: status,
        );
      case RadioSyncMsgType.evacKitMetaUpsert:
        final name = r.utf8u8();
        final flags = r.u8();
        final colorRgb = r.u32();
        final borderColorRgb = r.u32();
        final fillColorRgb = r.u32();
        final primaryRouteId = r.uuid();
        final defaultMode = r.u8();
        final layerId = (flags & (1 << 1)) != 0 ? r.uuid() : null;
        final notes = (flags & (1 << 3)) != 0 ? r.utf8u8() : null;
        return RadioDomainEvent.evacKitMetaUpsert(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          name: name,
          colorRgb: colorRgb,
          borderColorRgb: borderColorRgb,
          fillColorRgb: fillColorRgb,
          visible: (flags & (1 << 0)) != 0,
          layerId: layerId,
          primaryRouteId: primaryRouteId,
          defaultMode: defaultMode,
          showNameLabel: (flags & (1 << 2)) != 0,
          notes: notes,
          notesTruncated: (flags & (1 << 4)) != 0,
        );
      case RadioSyncMsgType.evacRouteUpsert:
        final routeId = r.uuid();
        final name = r.utf8u8();
        final role = r.u8();
        final flags = r.u8();
        final borderPattern = r.u8();
        final pathMode = r.u8();
        final colorRgb = (flags & (1 << 0)) != 0 ? r.u32() : null;
        final count = r.u8();
        final waypoints = <EvacWaypointAir>[];
        for (var i = 0; i < count; i++) {
          final kind = r.u8();
          final wpFlags = r.u8();
          final latE7 = r.i32();
          final lonE7 = r.i32();
          final markerId = (wpFlags & (1 << 0)) != 0 ? r.uuid() : null;
          final label = (wpFlags & (1 << 1)) != 0 ? r.utf8u8() : null;
          waypoints.add(
            EvacWaypointAir(
              kind: kind,
              latE7: latE7,
              lonE7: lonE7,
              markerId: markerId,
              label: label,
            ),
          );
        }
        return RadioDomainEvent.evacRouteUpsert(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          routeId: routeId,
          name: name,
          role: role,
          colorRgb: colorRgb,
          borderPattern: borderPattern,
          showArrows: (flags & (1 << 1)) != 0,
          pathMode: pathMode,
          waypoints: waypoints,
        );
      case RadioSyncMsgType.evacRouteDelete:
        return RadioDomainEvent.evacRouteDelete(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          routeId: r.uuid(),
        );
      case RadioSyncMsgType.evacKitDelete:
        return RadioDomainEvent.evacKitDelete(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
        );
      case RadioSyncMsgType.hello:
        final senderUnitId = r.utf8u8();
        final schemaVersion = r.u16();
        return RadioDomainEvent.hello(
          eventId: eventId,
          entityId: entityId,
          revisedAtSeconds: revisedAtSeconds,
          senderUnitId: senderUnitId,
          schemaVersion: schemaVersion,
        );
      default:
        throw FormatException(
          'Unknown radio msgType 0x${msgType.toRadixString(16)}',
        );
    }
  }
}
