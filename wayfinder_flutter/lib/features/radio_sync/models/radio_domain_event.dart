import 'package:freezed_annotation/freezed_annotation.dart';

import 'evac_waypoint_air.dart';
import 'radio_sync_msg_type.dart';

part 'radio_domain_event.freezed.dart';

/// Transport-agnostic domain events for radio sync (see `radio-sync-events.md`).
///
/// These Freezed models are the in-app representation. On-air encoding is a
/// separate binary codec (not JSON).
@freezed
sealed class RadioDomainEvent with _$RadioDomainEvent {
  const RadioDomainEvent._();

  const factory RadioDomainEvent.markerUpsert({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String name,
    required int latE7,
    required int lonE7,
    @Default(0) int elevationMeters,
    required int colorRgb,
    required int iconId,
    @Default(true) bool visible,
    String? layerId,
    String? notes,
    @Default(false) bool notesTruncated,
    @Default(false) bool isTracking,
  }) = MarkerUpsertEvent;

  const factory RadioDomainEvent.markerDelete({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
  }) = MarkerDeleteEvent;

  const factory RadioDomainEvent.zoneUpsertLight({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String name,
    required int zoneType,
    required int colorRgb,
    required int borderColorRgb,
    required int fillColorRgb,
    @Default(true) bool visible,
    String? layerId,
    required List<int> geometryBytes,
  }) = ZoneUpsertLightEvent;

  const factory RadioDomainEvent.zoneDelete({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
  }) = ZoneDeleteEvent;

  const factory RadioDomainEvent.logAppend({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required int occurredAtSeconds,
    required int severity,
    String? author,
    required String text,
    @Default(false) bool textTruncated,
    String? markerId,
    String? zoneId,
  }) = LogAppendEvent;

  const factory RadioDomainEvent.eventAck({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String ackedEventId,
    required int status,
  }) = EventAckEvent;

  const factory RadioDomainEvent.evacKitMetaUpsert({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String name,
    required int colorRgb,
    required int borderColorRgb,
    required int fillColorRgb,
    @Default(true) bool visible,
    String? layerId,
    required String primaryRouteId,
    required int defaultMode,
    @Default(true) bool showNameLabel,
    String? notes,
    @Default(false) bool notesTruncated,
  }) = EvacKitMetaUpsertEvent;

  const factory RadioDomainEvent.evacRouteUpsert({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String routeId,
    required String name,
    required int role,
    int? colorRgb,
    @Default(0) int borderPattern,
    @Default(true) bool showArrows,
    @Default(0) int pathMode,
    required List<EvacWaypointAir> waypoints,
  }) = EvacRouteUpsertEvent;

  const factory RadioDomainEvent.evacRouteDelete({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String routeId,
  }) = EvacRouteDeleteEvent;

  const factory RadioDomainEvent.evacKitDelete({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
  }) = EvacKitDeleteEvent;

  const factory RadioDomainEvent.hello({
    required String eventId,
    required String entityId,
    required int revisedAtSeconds,
    required String senderUnitId,
    required int schemaVersion,
  }) = HelloEvent;

  /// Design-doc [msgType] byte for this variant.
  int get msgType => switch (this) {
    MarkerUpsertEvent() => RadioSyncMsgType.markerUpsert,
    MarkerDeleteEvent() => RadioSyncMsgType.markerDelete,
    ZoneUpsertLightEvent() => RadioSyncMsgType.zoneUpsertLight,
    ZoneDeleteEvent() => RadioSyncMsgType.zoneDelete,
    LogAppendEvent() => RadioSyncMsgType.logAppend,
    EventAckEvent() => RadioSyncMsgType.eventAck,
    EvacKitMetaUpsertEvent() => RadioSyncMsgType.evacKitMetaUpsert,
    EvacRouteUpsertEvent() => RadioSyncMsgType.evacRouteUpsert,
    EvacRouteDeleteEvent() => RadioSyncMsgType.evacRouteDelete,
    EvacKitDeleteEvent() => RadioSyncMsgType.evacKitDelete,
    HelloEvent() => RadioSyncMsgType.hello,
  };
}

/// Watch-log severity codes for [LogAppendEvent.severity].
abstract final class RadioLogSeverity {
  static const int info = 0;
  static const int notice = 1;
  static const int warning = 2;
  static const int critical = 3;
}

/// Evac route role codes for [EvacRouteUpsertEvent.role].
abstract final class EvacRouteAirRole {
  static const int primary = 0;
  static const int alternate = 1;
}
