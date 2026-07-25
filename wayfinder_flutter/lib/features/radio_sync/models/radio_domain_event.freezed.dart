// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radio_domain_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RadioDomainEvent {

 String get eventId; String get entityId; int get revisedAtSeconds;
/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadioDomainEventCopyWith<RadioDomainEvent> get copyWith => _$RadioDomainEventCopyWithImpl<RadioDomainEvent>(this as RadioDomainEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadioDomainEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds);

@override
String toString() {
  return 'RadioDomainEvent(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds)';
}


}

/// @nodoc
abstract mixin class $RadioDomainEventCopyWith<$Res>  {
  factory $RadioDomainEventCopyWith(RadioDomainEvent value, $Res Function(RadioDomainEvent) _then) = _$RadioDomainEventCopyWithImpl;
@useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds
});




}
/// @nodoc
class _$RadioDomainEventCopyWithImpl<$Res>
    implements $RadioDomainEventCopyWith<$Res> {
  _$RadioDomainEventCopyWithImpl(this._self, this._then);

  final RadioDomainEvent _self;
  final $Res Function(RadioDomainEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RadioDomainEvent].
extension RadioDomainEventPatterns on RadioDomainEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MarkerUpsertEvent value)?  markerUpsert,TResult Function( MarkerDeleteEvent value)?  markerDelete,TResult Function( ZoneUpsertLightEvent value)?  zoneUpsertLight,TResult Function( ZoneDeleteEvent value)?  zoneDelete,TResult Function( LogAppendEvent value)?  logAppend,TResult Function( EventAckEvent value)?  eventAck,TResult Function( EvacKitMetaUpsertEvent value)?  evacKitMetaUpsert,TResult Function( EvacRouteUpsertEvent value)?  evacRouteUpsert,TResult Function( EvacRouteDeleteEvent value)?  evacRouteDelete,TResult Function( EvacKitDeleteEvent value)?  evacKitDelete,TResult Function( HelloEvent value)?  hello,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MarkerUpsertEvent() when markerUpsert != null:
return markerUpsert(_that);case MarkerDeleteEvent() when markerDelete != null:
return markerDelete(_that);case ZoneUpsertLightEvent() when zoneUpsertLight != null:
return zoneUpsertLight(_that);case ZoneDeleteEvent() when zoneDelete != null:
return zoneDelete(_that);case LogAppendEvent() when logAppend != null:
return logAppend(_that);case EventAckEvent() when eventAck != null:
return eventAck(_that);case EvacKitMetaUpsertEvent() when evacKitMetaUpsert != null:
return evacKitMetaUpsert(_that);case EvacRouteUpsertEvent() when evacRouteUpsert != null:
return evacRouteUpsert(_that);case EvacRouteDeleteEvent() when evacRouteDelete != null:
return evacRouteDelete(_that);case EvacKitDeleteEvent() when evacKitDelete != null:
return evacKitDelete(_that);case HelloEvent() when hello != null:
return hello(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MarkerUpsertEvent value)  markerUpsert,required TResult Function( MarkerDeleteEvent value)  markerDelete,required TResult Function( ZoneUpsertLightEvent value)  zoneUpsertLight,required TResult Function( ZoneDeleteEvent value)  zoneDelete,required TResult Function( LogAppendEvent value)  logAppend,required TResult Function( EventAckEvent value)  eventAck,required TResult Function( EvacKitMetaUpsertEvent value)  evacKitMetaUpsert,required TResult Function( EvacRouteUpsertEvent value)  evacRouteUpsert,required TResult Function( EvacRouteDeleteEvent value)  evacRouteDelete,required TResult Function( EvacKitDeleteEvent value)  evacKitDelete,required TResult Function( HelloEvent value)  hello,}){
final _that = this;
switch (_that) {
case MarkerUpsertEvent():
return markerUpsert(_that);case MarkerDeleteEvent():
return markerDelete(_that);case ZoneUpsertLightEvent():
return zoneUpsertLight(_that);case ZoneDeleteEvent():
return zoneDelete(_that);case LogAppendEvent():
return logAppend(_that);case EventAckEvent():
return eventAck(_that);case EvacKitMetaUpsertEvent():
return evacKitMetaUpsert(_that);case EvacRouteUpsertEvent():
return evacRouteUpsert(_that);case EvacRouteDeleteEvent():
return evacRouteDelete(_that);case EvacKitDeleteEvent():
return evacKitDelete(_that);case HelloEvent():
return hello(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MarkerUpsertEvent value)?  markerUpsert,TResult? Function( MarkerDeleteEvent value)?  markerDelete,TResult? Function( ZoneUpsertLightEvent value)?  zoneUpsertLight,TResult? Function( ZoneDeleteEvent value)?  zoneDelete,TResult? Function( LogAppendEvent value)?  logAppend,TResult? Function( EventAckEvent value)?  eventAck,TResult? Function( EvacKitMetaUpsertEvent value)?  evacKitMetaUpsert,TResult? Function( EvacRouteUpsertEvent value)?  evacRouteUpsert,TResult? Function( EvacRouteDeleteEvent value)?  evacRouteDelete,TResult? Function( EvacKitDeleteEvent value)?  evacKitDelete,TResult? Function( HelloEvent value)?  hello,}){
final _that = this;
switch (_that) {
case MarkerUpsertEvent() when markerUpsert != null:
return markerUpsert(_that);case MarkerDeleteEvent() when markerDelete != null:
return markerDelete(_that);case ZoneUpsertLightEvent() when zoneUpsertLight != null:
return zoneUpsertLight(_that);case ZoneDeleteEvent() when zoneDelete != null:
return zoneDelete(_that);case LogAppendEvent() when logAppend != null:
return logAppend(_that);case EventAckEvent() when eventAck != null:
return eventAck(_that);case EvacKitMetaUpsertEvent() when evacKitMetaUpsert != null:
return evacKitMetaUpsert(_that);case EvacRouteUpsertEvent() when evacRouteUpsert != null:
return evacRouteUpsert(_that);case EvacRouteDeleteEvent() when evacRouteDelete != null:
return evacRouteDelete(_that);case EvacKitDeleteEvent() when evacKitDelete != null:
return evacKitDelete(_that);case HelloEvent() when hello != null:
return hello(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int latE7,  int lonE7,  int elevationMeters,  int colorRgb,  int iconId,  bool visible,  String? layerId,  String? notes,  bool notesTruncated,  bool isTracking)?  markerUpsert,TResult Function( String eventId,  String entityId,  int revisedAtSeconds)?  markerDelete,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int zoneType,  int colorRgb,  int borderColorRgb,  int fillColorRgb,  bool visible,  String? layerId,  List<int> geometryBytes)?  zoneUpsertLight,TResult Function( String eventId,  String entityId,  int revisedAtSeconds)?  zoneDelete,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  int occurredAtSeconds,  int severity,  String? author,  String text,  bool textTruncated,  String? markerId,  String? zoneId)?  logAppend,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String ackedEventId,  int status)?  eventAck,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int colorRgb,  int borderColorRgb,  int fillColorRgb,  bool visible,  String? layerId,  String primaryRouteId,  int defaultMode,  bool showNameLabel,  String? notes,  bool notesTruncated)?  evacKitMetaUpsert,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String routeId,  String name,  int role,  int? colorRgb,  int borderPattern,  bool showArrows,  int pathMode,  List<EvacWaypointAir> waypoints)?  evacRouteUpsert,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String routeId)?  evacRouteDelete,TResult Function( String eventId,  String entityId,  int revisedAtSeconds)?  evacKitDelete,TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String senderUnitId,  int schemaVersion)?  hello,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MarkerUpsertEvent() when markerUpsert != null:
return markerUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.latE7,_that.lonE7,_that.elevationMeters,_that.colorRgb,_that.iconId,_that.visible,_that.layerId,_that.notes,_that.notesTruncated,_that.isTracking);case MarkerDeleteEvent() when markerDelete != null:
return markerDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case ZoneUpsertLightEvent() when zoneUpsertLight != null:
return zoneUpsertLight(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.zoneType,_that.colorRgb,_that.borderColorRgb,_that.fillColorRgb,_that.visible,_that.layerId,_that.geometryBytes);case ZoneDeleteEvent() when zoneDelete != null:
return zoneDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case LogAppendEvent() when logAppend != null:
return logAppend(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.occurredAtSeconds,_that.severity,_that.author,_that.text,_that.textTruncated,_that.markerId,_that.zoneId);case EventAckEvent() when eventAck != null:
return eventAck(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.ackedEventId,_that.status);case EvacKitMetaUpsertEvent() when evacKitMetaUpsert != null:
return evacKitMetaUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.colorRgb,_that.borderColorRgb,_that.fillColorRgb,_that.visible,_that.layerId,_that.primaryRouteId,_that.defaultMode,_that.showNameLabel,_that.notes,_that.notesTruncated);case EvacRouteUpsertEvent() when evacRouteUpsert != null:
return evacRouteUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.routeId,_that.name,_that.role,_that.colorRgb,_that.borderPattern,_that.showArrows,_that.pathMode,_that.waypoints);case EvacRouteDeleteEvent() when evacRouteDelete != null:
return evacRouteDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.routeId);case EvacKitDeleteEvent() when evacKitDelete != null:
return evacKitDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case HelloEvent() when hello != null:
return hello(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.senderUnitId,_that.schemaVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int latE7,  int lonE7,  int elevationMeters,  int colorRgb,  int iconId,  bool visible,  String? layerId,  String? notes,  bool notesTruncated,  bool isTracking)  markerUpsert,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds)  markerDelete,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int zoneType,  int colorRgb,  int borderColorRgb,  int fillColorRgb,  bool visible,  String? layerId,  List<int> geometryBytes)  zoneUpsertLight,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds)  zoneDelete,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  int occurredAtSeconds,  int severity,  String? author,  String text,  bool textTruncated,  String? markerId,  String? zoneId)  logAppend,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String ackedEventId,  int status)  eventAck,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int colorRgb,  int borderColorRgb,  int fillColorRgb,  bool visible,  String? layerId,  String primaryRouteId,  int defaultMode,  bool showNameLabel,  String? notes,  bool notesTruncated)  evacKitMetaUpsert,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String routeId,  String name,  int role,  int? colorRgb,  int borderPattern,  bool showArrows,  int pathMode,  List<EvacWaypointAir> waypoints)  evacRouteUpsert,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String routeId)  evacRouteDelete,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds)  evacKitDelete,required TResult Function( String eventId,  String entityId,  int revisedAtSeconds,  String senderUnitId,  int schemaVersion)  hello,}) {final _that = this;
switch (_that) {
case MarkerUpsertEvent():
return markerUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.latE7,_that.lonE7,_that.elevationMeters,_that.colorRgb,_that.iconId,_that.visible,_that.layerId,_that.notes,_that.notesTruncated,_that.isTracking);case MarkerDeleteEvent():
return markerDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case ZoneUpsertLightEvent():
return zoneUpsertLight(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.zoneType,_that.colorRgb,_that.borderColorRgb,_that.fillColorRgb,_that.visible,_that.layerId,_that.geometryBytes);case ZoneDeleteEvent():
return zoneDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case LogAppendEvent():
return logAppend(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.occurredAtSeconds,_that.severity,_that.author,_that.text,_that.textTruncated,_that.markerId,_that.zoneId);case EventAckEvent():
return eventAck(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.ackedEventId,_that.status);case EvacKitMetaUpsertEvent():
return evacKitMetaUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.colorRgb,_that.borderColorRgb,_that.fillColorRgb,_that.visible,_that.layerId,_that.primaryRouteId,_that.defaultMode,_that.showNameLabel,_that.notes,_that.notesTruncated);case EvacRouteUpsertEvent():
return evacRouteUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.routeId,_that.name,_that.role,_that.colorRgb,_that.borderPattern,_that.showArrows,_that.pathMode,_that.waypoints);case EvacRouteDeleteEvent():
return evacRouteDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.routeId);case EvacKitDeleteEvent():
return evacKitDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case HelloEvent():
return hello(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.senderUnitId,_that.schemaVersion);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int latE7,  int lonE7,  int elevationMeters,  int colorRgb,  int iconId,  bool visible,  String? layerId,  String? notes,  bool notesTruncated,  bool isTracking)?  markerUpsert,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds)?  markerDelete,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int zoneType,  int colorRgb,  int borderColorRgb,  int fillColorRgb,  bool visible,  String? layerId,  List<int> geometryBytes)?  zoneUpsertLight,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds)?  zoneDelete,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  int occurredAtSeconds,  int severity,  String? author,  String text,  bool textTruncated,  String? markerId,  String? zoneId)?  logAppend,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String ackedEventId,  int status)?  eventAck,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String name,  int colorRgb,  int borderColorRgb,  int fillColorRgb,  bool visible,  String? layerId,  String primaryRouteId,  int defaultMode,  bool showNameLabel,  String? notes,  bool notesTruncated)?  evacKitMetaUpsert,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String routeId,  String name,  int role,  int? colorRgb,  int borderPattern,  bool showArrows,  int pathMode,  List<EvacWaypointAir> waypoints)?  evacRouteUpsert,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String routeId)?  evacRouteDelete,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds)?  evacKitDelete,TResult? Function( String eventId,  String entityId,  int revisedAtSeconds,  String senderUnitId,  int schemaVersion)?  hello,}) {final _that = this;
switch (_that) {
case MarkerUpsertEvent() when markerUpsert != null:
return markerUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.latE7,_that.lonE7,_that.elevationMeters,_that.colorRgb,_that.iconId,_that.visible,_that.layerId,_that.notes,_that.notesTruncated,_that.isTracking);case MarkerDeleteEvent() when markerDelete != null:
return markerDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case ZoneUpsertLightEvent() when zoneUpsertLight != null:
return zoneUpsertLight(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.zoneType,_that.colorRgb,_that.borderColorRgb,_that.fillColorRgb,_that.visible,_that.layerId,_that.geometryBytes);case ZoneDeleteEvent() when zoneDelete != null:
return zoneDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case LogAppendEvent() when logAppend != null:
return logAppend(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.occurredAtSeconds,_that.severity,_that.author,_that.text,_that.textTruncated,_that.markerId,_that.zoneId);case EventAckEvent() when eventAck != null:
return eventAck(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.ackedEventId,_that.status);case EvacKitMetaUpsertEvent() when evacKitMetaUpsert != null:
return evacKitMetaUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.name,_that.colorRgb,_that.borderColorRgb,_that.fillColorRgb,_that.visible,_that.layerId,_that.primaryRouteId,_that.defaultMode,_that.showNameLabel,_that.notes,_that.notesTruncated);case EvacRouteUpsertEvent() when evacRouteUpsert != null:
return evacRouteUpsert(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.routeId,_that.name,_that.role,_that.colorRgb,_that.borderPattern,_that.showArrows,_that.pathMode,_that.waypoints);case EvacRouteDeleteEvent() when evacRouteDelete != null:
return evacRouteDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.routeId);case EvacKitDeleteEvent() when evacKitDelete != null:
return evacKitDelete(_that.eventId,_that.entityId,_that.revisedAtSeconds);case HelloEvent() when hello != null:
return hello(_that.eventId,_that.entityId,_that.revisedAtSeconds,_that.senderUnitId,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc


class MarkerUpsertEvent extends RadioDomainEvent {
  const MarkerUpsertEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.name, required this.latE7, required this.lonE7, this.elevationMeters = 0, required this.colorRgb, required this.iconId, this.visible = true, this.layerId, this.notes, this.notesTruncated = false, this.isTracking = false}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String name;
 final  int latE7;
 final  int lonE7;
@JsonKey() final  int elevationMeters;
 final  int colorRgb;
 final  int iconId;
@JsonKey() final  bool visible;
 final  String? layerId;
 final  String? notes;
@JsonKey() final  bool notesTruncated;
@JsonKey() final  bool isTracking;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerUpsertEventCopyWith<MarkerUpsertEvent> get copyWith => _$MarkerUpsertEventCopyWithImpl<MarkerUpsertEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerUpsertEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.name, name) || other.name == name)&&(identical(other.latE7, latE7) || other.latE7 == latE7)&&(identical(other.lonE7, lonE7) || other.lonE7 == lonE7)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.colorRgb, colorRgb) || other.colorRgb == colorRgb)&&(identical(other.iconId, iconId) || other.iconId == iconId)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.notesTruncated, notesTruncated) || other.notesTruncated == notesTruncated)&&(identical(other.isTracking, isTracking) || other.isTracking == isTracking));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,name,latE7,lonE7,elevationMeters,colorRgb,iconId,visible,layerId,notes,notesTruncated,isTracking);

@override
String toString() {
  return 'RadioDomainEvent.markerUpsert(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, name: $name, latE7: $latE7, lonE7: $lonE7, elevationMeters: $elevationMeters, colorRgb: $colorRgb, iconId: $iconId, visible: $visible, layerId: $layerId, notes: $notes, notesTruncated: $notesTruncated, isTracking: $isTracking)';
}


}

/// @nodoc
abstract mixin class $MarkerUpsertEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $MarkerUpsertEventCopyWith(MarkerUpsertEvent value, $Res Function(MarkerUpsertEvent) _then) = _$MarkerUpsertEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String name, int latE7, int lonE7, int elevationMeters, int colorRgb, int iconId, bool visible, String? layerId, String? notes, bool notesTruncated, bool isTracking
});




}
/// @nodoc
class _$MarkerUpsertEventCopyWithImpl<$Res>
    implements $MarkerUpsertEventCopyWith<$Res> {
  _$MarkerUpsertEventCopyWithImpl(this._self, this._then);

  final MarkerUpsertEvent _self;
  final $Res Function(MarkerUpsertEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? name = null,Object? latE7 = null,Object? lonE7 = null,Object? elevationMeters = null,Object? colorRgb = null,Object? iconId = null,Object? visible = null,Object? layerId = freezed,Object? notes = freezed,Object? notesTruncated = null,Object? isTracking = null,}) {
  return _then(MarkerUpsertEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latE7: null == latE7 ? _self.latE7 : latE7 // ignore: cast_nullable_to_non_nullable
as int,lonE7: null == lonE7 ? _self.lonE7 : lonE7 // ignore: cast_nullable_to_non_nullable
as int,elevationMeters: null == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as int,colorRgb: null == colorRgb ? _self.colorRgb : colorRgb // ignore: cast_nullable_to_non_nullable
as int,iconId: null == iconId ? _self.iconId : iconId // ignore: cast_nullable_to_non_nullable
as int,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,layerId: freezed == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,notesTruncated: null == notesTruncated ? _self.notesTruncated : notesTruncated // ignore: cast_nullable_to_non_nullable
as bool,isTracking: null == isTracking ? _self.isTracking : isTracking // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class MarkerDeleteEvent extends RadioDomainEvent {
  const MarkerDeleteEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerDeleteEventCopyWith<MarkerDeleteEvent> get copyWith => _$MarkerDeleteEventCopyWithImpl<MarkerDeleteEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerDeleteEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds);

@override
String toString() {
  return 'RadioDomainEvent.markerDelete(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds)';
}


}

/// @nodoc
abstract mixin class $MarkerDeleteEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $MarkerDeleteEventCopyWith(MarkerDeleteEvent value, $Res Function(MarkerDeleteEvent) _then) = _$MarkerDeleteEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds
});




}
/// @nodoc
class _$MarkerDeleteEventCopyWithImpl<$Res>
    implements $MarkerDeleteEventCopyWith<$Res> {
  _$MarkerDeleteEventCopyWithImpl(this._self, this._then);

  final MarkerDeleteEvent _self;
  final $Res Function(MarkerDeleteEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,}) {
  return _then(MarkerDeleteEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ZoneUpsertLightEvent extends RadioDomainEvent {
  const ZoneUpsertLightEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.name, required this.zoneType, required this.colorRgb, required this.borderColorRgb, required this.fillColorRgb, this.visible = true, this.layerId, required final  List<int> geometryBytes}): _geometryBytes = geometryBytes,super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String name;
 final  int zoneType;
 final  int colorRgb;
 final  int borderColorRgb;
 final  int fillColorRgb;
@JsonKey() final  bool visible;
 final  String? layerId;
 final  List<int> _geometryBytes;
 List<int> get geometryBytes {
  if (_geometryBytes is EqualUnmodifiableListView) return _geometryBytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_geometryBytes);
}


/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneUpsertLightEventCopyWith<ZoneUpsertLightEvent> get copyWith => _$ZoneUpsertLightEventCopyWithImpl<ZoneUpsertLightEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneUpsertLightEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.name, name) || other.name == name)&&(identical(other.zoneType, zoneType) || other.zoneType == zoneType)&&(identical(other.colorRgb, colorRgb) || other.colorRgb == colorRgb)&&(identical(other.borderColorRgb, borderColorRgb) || other.borderColorRgb == borderColorRgb)&&(identical(other.fillColorRgb, fillColorRgb) || other.fillColorRgb == fillColorRgb)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&const DeepCollectionEquality().equals(other._geometryBytes, _geometryBytes));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,name,zoneType,colorRgb,borderColorRgb,fillColorRgb,visible,layerId,const DeepCollectionEquality().hash(_geometryBytes));

@override
String toString() {
  return 'RadioDomainEvent.zoneUpsertLight(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, name: $name, zoneType: $zoneType, colorRgb: $colorRgb, borderColorRgb: $borderColorRgb, fillColorRgb: $fillColorRgb, visible: $visible, layerId: $layerId, geometryBytes: $geometryBytes)';
}


}

/// @nodoc
abstract mixin class $ZoneUpsertLightEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $ZoneUpsertLightEventCopyWith(ZoneUpsertLightEvent value, $Res Function(ZoneUpsertLightEvent) _then) = _$ZoneUpsertLightEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String name, int zoneType, int colorRgb, int borderColorRgb, int fillColorRgb, bool visible, String? layerId, List<int> geometryBytes
});




}
/// @nodoc
class _$ZoneUpsertLightEventCopyWithImpl<$Res>
    implements $ZoneUpsertLightEventCopyWith<$Res> {
  _$ZoneUpsertLightEventCopyWithImpl(this._self, this._then);

  final ZoneUpsertLightEvent _self;
  final $Res Function(ZoneUpsertLightEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? name = null,Object? zoneType = null,Object? colorRgb = null,Object? borderColorRgb = null,Object? fillColorRgb = null,Object? visible = null,Object? layerId = freezed,Object? geometryBytes = null,}) {
  return _then(ZoneUpsertLightEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zoneType: null == zoneType ? _self.zoneType : zoneType // ignore: cast_nullable_to_non_nullable
as int,colorRgb: null == colorRgb ? _self.colorRgb : colorRgb // ignore: cast_nullable_to_non_nullable
as int,borderColorRgb: null == borderColorRgb ? _self.borderColorRgb : borderColorRgb // ignore: cast_nullable_to_non_nullable
as int,fillColorRgb: null == fillColorRgb ? _self.fillColorRgb : fillColorRgb // ignore: cast_nullable_to_non_nullable
as int,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,layerId: freezed == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String?,geometryBytes: null == geometryBytes ? _self._geometryBytes : geometryBytes // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc


class ZoneDeleteEvent extends RadioDomainEvent {
  const ZoneDeleteEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneDeleteEventCopyWith<ZoneDeleteEvent> get copyWith => _$ZoneDeleteEventCopyWithImpl<ZoneDeleteEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneDeleteEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds);

@override
String toString() {
  return 'RadioDomainEvent.zoneDelete(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds)';
}


}

/// @nodoc
abstract mixin class $ZoneDeleteEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $ZoneDeleteEventCopyWith(ZoneDeleteEvent value, $Res Function(ZoneDeleteEvent) _then) = _$ZoneDeleteEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds
});




}
/// @nodoc
class _$ZoneDeleteEventCopyWithImpl<$Res>
    implements $ZoneDeleteEventCopyWith<$Res> {
  _$ZoneDeleteEventCopyWithImpl(this._self, this._then);

  final ZoneDeleteEvent _self;
  final $Res Function(ZoneDeleteEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,}) {
  return _then(ZoneDeleteEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LogAppendEvent extends RadioDomainEvent {
  const LogAppendEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.occurredAtSeconds, required this.severity, this.author, required this.text, this.textTruncated = false, this.markerId, this.zoneId}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  int occurredAtSeconds;
 final  int severity;
 final  String? author;
 final  String text;
@JsonKey() final  bool textTruncated;
 final  String? markerId;
 final  String? zoneId;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogAppendEventCopyWith<LogAppendEvent> get copyWith => _$LogAppendEventCopyWithImpl<LogAppendEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogAppendEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.occurredAtSeconds, occurredAtSeconds) || other.occurredAtSeconds == occurredAtSeconds)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.textTruncated, textTruncated) || other.textTruncated == textTruncated)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,occurredAtSeconds,severity,author,text,textTruncated,markerId,zoneId);

@override
String toString() {
  return 'RadioDomainEvent.logAppend(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, occurredAtSeconds: $occurredAtSeconds, severity: $severity, author: $author, text: $text, textTruncated: $textTruncated, markerId: $markerId, zoneId: $zoneId)';
}


}

/// @nodoc
abstract mixin class $LogAppendEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $LogAppendEventCopyWith(LogAppendEvent value, $Res Function(LogAppendEvent) _then) = _$LogAppendEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, int occurredAtSeconds, int severity, String? author, String text, bool textTruncated, String? markerId, String? zoneId
});




}
/// @nodoc
class _$LogAppendEventCopyWithImpl<$Res>
    implements $LogAppendEventCopyWith<$Res> {
  _$LogAppendEventCopyWithImpl(this._self, this._then);

  final LogAppendEvent _self;
  final $Res Function(LogAppendEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? occurredAtSeconds = null,Object? severity = null,Object? author = freezed,Object? text = null,Object? textTruncated = null,Object? markerId = freezed,Object? zoneId = freezed,}) {
  return _then(LogAppendEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,occurredAtSeconds: null == occurredAtSeconds ? _self.occurredAtSeconds : occurredAtSeconds // ignore: cast_nullable_to_non_nullable
as int,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as int,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textTruncated: null == textTruncated ? _self.textTruncated : textTruncated // ignore: cast_nullable_to_non_nullable
as bool,markerId: freezed == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class EventAckEvent extends RadioDomainEvent {
  const EventAckEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.ackedEventId, required this.status}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String ackedEventId;
 final  int status;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAckEventCopyWith<EventAckEvent> get copyWith => _$EventAckEventCopyWithImpl<EventAckEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAckEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.ackedEventId, ackedEventId) || other.ackedEventId == ackedEventId)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,ackedEventId,status);

@override
String toString() {
  return 'RadioDomainEvent.eventAck(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, ackedEventId: $ackedEventId, status: $status)';
}


}

/// @nodoc
abstract mixin class $EventAckEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $EventAckEventCopyWith(EventAckEvent value, $Res Function(EventAckEvent) _then) = _$EventAckEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String ackedEventId, int status
});




}
/// @nodoc
class _$EventAckEventCopyWithImpl<$Res>
    implements $EventAckEventCopyWith<$Res> {
  _$EventAckEventCopyWithImpl(this._self, this._then);

  final EventAckEvent _self;
  final $Res Function(EventAckEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? ackedEventId = null,Object? status = null,}) {
  return _then(EventAckEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,ackedEventId: null == ackedEventId ? _self.ackedEventId : ackedEventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class EvacKitMetaUpsertEvent extends RadioDomainEvent {
  const EvacKitMetaUpsertEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.name, required this.colorRgb, required this.borderColorRgb, required this.fillColorRgb, this.visible = true, this.layerId, required this.primaryRouteId, required this.defaultMode, this.showNameLabel = true, this.notes, this.notesTruncated = false}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String name;
 final  int colorRgb;
 final  int borderColorRgb;
 final  int fillColorRgb;
@JsonKey() final  bool visible;
 final  String? layerId;
 final  String primaryRouteId;
 final  int defaultMode;
@JsonKey() final  bool showNameLabel;
 final  String? notes;
@JsonKey() final  bool notesTruncated;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvacKitMetaUpsertEventCopyWith<EvacKitMetaUpsertEvent> get copyWith => _$EvacKitMetaUpsertEventCopyWithImpl<EvacKitMetaUpsertEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvacKitMetaUpsertEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorRgb, colorRgb) || other.colorRgb == colorRgb)&&(identical(other.borderColorRgb, borderColorRgb) || other.borderColorRgb == borderColorRgb)&&(identical(other.fillColorRgb, fillColorRgb) || other.fillColorRgb == fillColorRgb)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.primaryRouteId, primaryRouteId) || other.primaryRouteId == primaryRouteId)&&(identical(other.defaultMode, defaultMode) || other.defaultMode == defaultMode)&&(identical(other.showNameLabel, showNameLabel) || other.showNameLabel == showNameLabel)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.notesTruncated, notesTruncated) || other.notesTruncated == notesTruncated));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,name,colorRgb,borderColorRgb,fillColorRgb,visible,layerId,primaryRouteId,defaultMode,showNameLabel,notes,notesTruncated);

@override
String toString() {
  return 'RadioDomainEvent.evacKitMetaUpsert(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, name: $name, colorRgb: $colorRgb, borderColorRgb: $borderColorRgb, fillColorRgb: $fillColorRgb, visible: $visible, layerId: $layerId, primaryRouteId: $primaryRouteId, defaultMode: $defaultMode, showNameLabel: $showNameLabel, notes: $notes, notesTruncated: $notesTruncated)';
}


}

/// @nodoc
abstract mixin class $EvacKitMetaUpsertEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $EvacKitMetaUpsertEventCopyWith(EvacKitMetaUpsertEvent value, $Res Function(EvacKitMetaUpsertEvent) _then) = _$EvacKitMetaUpsertEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String name, int colorRgb, int borderColorRgb, int fillColorRgb, bool visible, String? layerId, String primaryRouteId, int defaultMode, bool showNameLabel, String? notes, bool notesTruncated
});




}
/// @nodoc
class _$EvacKitMetaUpsertEventCopyWithImpl<$Res>
    implements $EvacKitMetaUpsertEventCopyWith<$Res> {
  _$EvacKitMetaUpsertEventCopyWithImpl(this._self, this._then);

  final EvacKitMetaUpsertEvent _self;
  final $Res Function(EvacKitMetaUpsertEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? name = null,Object? colorRgb = null,Object? borderColorRgb = null,Object? fillColorRgb = null,Object? visible = null,Object? layerId = freezed,Object? primaryRouteId = null,Object? defaultMode = null,Object? showNameLabel = null,Object? notes = freezed,Object? notesTruncated = null,}) {
  return _then(EvacKitMetaUpsertEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorRgb: null == colorRgb ? _self.colorRgb : colorRgb // ignore: cast_nullable_to_non_nullable
as int,borderColorRgb: null == borderColorRgb ? _self.borderColorRgb : borderColorRgb // ignore: cast_nullable_to_non_nullable
as int,fillColorRgb: null == fillColorRgb ? _self.fillColorRgb : fillColorRgb // ignore: cast_nullable_to_non_nullable
as int,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,layerId: freezed == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String?,primaryRouteId: null == primaryRouteId ? _self.primaryRouteId : primaryRouteId // ignore: cast_nullable_to_non_nullable
as String,defaultMode: null == defaultMode ? _self.defaultMode : defaultMode // ignore: cast_nullable_to_non_nullable
as int,showNameLabel: null == showNameLabel ? _self.showNameLabel : showNameLabel // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,notesTruncated: null == notesTruncated ? _self.notesTruncated : notesTruncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class EvacRouteUpsertEvent extends RadioDomainEvent {
  const EvacRouteUpsertEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.routeId, required this.name, required this.role, this.colorRgb, this.borderPattern = 0, this.showArrows = true, this.pathMode = 0, required final  List<EvacWaypointAir> waypoints}): _waypoints = waypoints,super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String routeId;
 final  String name;
 final  int role;
 final  int? colorRgb;
@JsonKey() final  int borderPattern;
@JsonKey() final  bool showArrows;
@JsonKey() final  int pathMode;
 final  List<EvacWaypointAir> _waypoints;
 List<EvacWaypointAir> get waypoints {
  if (_waypoints is EqualUnmodifiableListView) return _waypoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypoints);
}


/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvacRouteUpsertEventCopyWith<EvacRouteUpsertEvent> get copyWith => _$EvacRouteUpsertEventCopyWithImpl<EvacRouteUpsertEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvacRouteUpsertEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.colorRgb, colorRgb) || other.colorRgb == colorRgb)&&(identical(other.borderPattern, borderPattern) || other.borderPattern == borderPattern)&&(identical(other.showArrows, showArrows) || other.showArrows == showArrows)&&(identical(other.pathMode, pathMode) || other.pathMode == pathMode)&&const DeepCollectionEquality().equals(other._waypoints, _waypoints));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,routeId,name,role,colorRgb,borderPattern,showArrows,pathMode,const DeepCollectionEquality().hash(_waypoints));

@override
String toString() {
  return 'RadioDomainEvent.evacRouteUpsert(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, routeId: $routeId, name: $name, role: $role, colorRgb: $colorRgb, borderPattern: $borderPattern, showArrows: $showArrows, pathMode: $pathMode, waypoints: $waypoints)';
}


}

/// @nodoc
abstract mixin class $EvacRouteUpsertEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $EvacRouteUpsertEventCopyWith(EvacRouteUpsertEvent value, $Res Function(EvacRouteUpsertEvent) _then) = _$EvacRouteUpsertEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String routeId, String name, int role, int? colorRgb, int borderPattern, bool showArrows, int pathMode, List<EvacWaypointAir> waypoints
});




}
/// @nodoc
class _$EvacRouteUpsertEventCopyWithImpl<$Res>
    implements $EvacRouteUpsertEventCopyWith<$Res> {
  _$EvacRouteUpsertEventCopyWithImpl(this._self, this._then);

  final EvacRouteUpsertEvent _self;
  final $Res Function(EvacRouteUpsertEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? routeId = null,Object? name = null,Object? role = null,Object? colorRgb = freezed,Object? borderPattern = null,Object? showArrows = null,Object? pathMode = null,Object? waypoints = null,}) {
  return _then(EvacRouteUpsertEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,routeId: null == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,colorRgb: freezed == colorRgb ? _self.colorRgb : colorRgb // ignore: cast_nullable_to_non_nullable
as int?,borderPattern: null == borderPattern ? _self.borderPattern : borderPattern // ignore: cast_nullable_to_non_nullable
as int,showArrows: null == showArrows ? _self.showArrows : showArrows // ignore: cast_nullable_to_non_nullable
as bool,pathMode: null == pathMode ? _self.pathMode : pathMode // ignore: cast_nullable_to_non_nullable
as int,waypoints: null == waypoints ? _self._waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<EvacWaypointAir>,
  ));
}


}

/// @nodoc


class EvacRouteDeleteEvent extends RadioDomainEvent {
  const EvacRouteDeleteEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.routeId}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String routeId;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvacRouteDeleteEventCopyWith<EvacRouteDeleteEvent> get copyWith => _$EvacRouteDeleteEventCopyWithImpl<EvacRouteDeleteEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvacRouteDeleteEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.routeId, routeId) || other.routeId == routeId));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,routeId);

@override
String toString() {
  return 'RadioDomainEvent.evacRouteDelete(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, routeId: $routeId)';
}


}

/// @nodoc
abstract mixin class $EvacRouteDeleteEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $EvacRouteDeleteEventCopyWith(EvacRouteDeleteEvent value, $Res Function(EvacRouteDeleteEvent) _then) = _$EvacRouteDeleteEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String routeId
});




}
/// @nodoc
class _$EvacRouteDeleteEventCopyWithImpl<$Res>
    implements $EvacRouteDeleteEventCopyWith<$Res> {
  _$EvacRouteDeleteEventCopyWithImpl(this._self, this._then);

  final EvacRouteDeleteEvent _self;
  final $Res Function(EvacRouteDeleteEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? routeId = null,}) {
  return _then(EvacRouteDeleteEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,routeId: null == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class EvacKitDeleteEvent extends RadioDomainEvent {
  const EvacKitDeleteEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvacKitDeleteEventCopyWith<EvacKitDeleteEvent> get copyWith => _$EvacKitDeleteEventCopyWithImpl<EvacKitDeleteEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvacKitDeleteEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds);

@override
String toString() {
  return 'RadioDomainEvent.evacKitDelete(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds)';
}


}

/// @nodoc
abstract mixin class $EvacKitDeleteEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $EvacKitDeleteEventCopyWith(EvacKitDeleteEvent value, $Res Function(EvacKitDeleteEvent) _then) = _$EvacKitDeleteEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds
});




}
/// @nodoc
class _$EvacKitDeleteEventCopyWithImpl<$Res>
    implements $EvacKitDeleteEventCopyWith<$Res> {
  _$EvacKitDeleteEventCopyWithImpl(this._self, this._then);

  final EvacKitDeleteEvent _self;
  final $Res Function(EvacKitDeleteEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,}) {
  return _then(EvacKitDeleteEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class HelloEvent extends RadioDomainEvent {
  const HelloEvent({required this.eventId, required this.entityId, required this.revisedAtSeconds, required this.senderUnitId, required this.schemaVersion}): super._();
  

@override final  String eventId;
@override final  String entityId;
@override final  int revisedAtSeconds;
 final  String senderUnitId;
 final  int schemaVersion;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelloEventCopyWith<HelloEvent> get copyWith => _$HelloEventCopyWithImpl<HelloEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelloEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.revisedAtSeconds, revisedAtSeconds) || other.revisedAtSeconds == revisedAtSeconds)&&(identical(other.senderUnitId, senderUnitId) || other.senderUnitId == senderUnitId)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,entityId,revisedAtSeconds,senderUnitId,schemaVersion);

@override
String toString() {
  return 'RadioDomainEvent.hello(eventId: $eventId, entityId: $entityId, revisedAtSeconds: $revisedAtSeconds, senderUnitId: $senderUnitId, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $HelloEventCopyWith<$Res> implements $RadioDomainEventCopyWith<$Res> {
  factory $HelloEventCopyWith(HelloEvent value, $Res Function(HelloEvent) _then) = _$HelloEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String entityId, int revisedAtSeconds, String senderUnitId, int schemaVersion
});




}
/// @nodoc
class _$HelloEventCopyWithImpl<$Res>
    implements $HelloEventCopyWith<$Res> {
  _$HelloEventCopyWithImpl(this._self, this._then);

  final HelloEvent _self;
  final $Res Function(HelloEvent) _then;

/// Create a copy of RadioDomainEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? entityId = null,Object? revisedAtSeconds = null,Object? senderUnitId = null,Object? schemaVersion = null,}) {
  return _then(HelloEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,revisedAtSeconds: null == revisedAtSeconds ? _self.revisedAtSeconds : revisedAtSeconds // ignore: cast_nullable_to_non_nullable
as int,senderUnitId: null == senderUnitId ? _self.senderUnitId : senderUnitId // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
