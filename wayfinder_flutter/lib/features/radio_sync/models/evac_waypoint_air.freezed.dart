// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evac_waypoint_air.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EvacWaypointAir {

/// `marker` | `point` | `control` (see design doc).
 int get kind; int get latE7; int get lonE7; String? get markerId; String? get label;
/// Create a copy of EvacWaypointAir
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvacWaypointAirCopyWith<EvacWaypointAir> get copyWith => _$EvacWaypointAirCopyWithImpl<EvacWaypointAir>(this as EvacWaypointAir, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvacWaypointAir&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.latE7, latE7) || other.latE7 == latE7)&&(identical(other.lonE7, lonE7) || other.lonE7 == lonE7)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,kind,latE7,lonE7,markerId,label);

@override
String toString() {
  return 'EvacWaypointAir(kind: $kind, latE7: $latE7, lonE7: $lonE7, markerId: $markerId, label: $label)';
}


}

/// @nodoc
abstract mixin class $EvacWaypointAirCopyWith<$Res>  {
  factory $EvacWaypointAirCopyWith(EvacWaypointAir value, $Res Function(EvacWaypointAir) _then) = _$EvacWaypointAirCopyWithImpl;
@useResult
$Res call({
 int kind, int latE7, int lonE7, String? markerId, String? label
});




}
/// @nodoc
class _$EvacWaypointAirCopyWithImpl<$Res>
    implements $EvacWaypointAirCopyWith<$Res> {
  _$EvacWaypointAirCopyWithImpl(this._self, this._then);

  final EvacWaypointAir _self;
  final $Res Function(EvacWaypointAir) _then;

/// Create a copy of EvacWaypointAir
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? latE7 = null,Object? lonE7 = null,Object? markerId = freezed,Object? label = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,latE7: null == latE7 ? _self.latE7 : latE7 // ignore: cast_nullable_to_non_nullable
as int,lonE7: null == lonE7 ? _self.lonE7 : lonE7 // ignore: cast_nullable_to_non_nullable
as int,markerId: freezed == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EvacWaypointAir].
extension EvacWaypointAirPatterns on EvacWaypointAir {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvacWaypointAir value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvacWaypointAir() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvacWaypointAir value)  $default,){
final _that = this;
switch (_that) {
case _EvacWaypointAir():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvacWaypointAir value)?  $default,){
final _that = this;
switch (_that) {
case _EvacWaypointAir() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int kind,  int latE7,  int lonE7,  String? markerId,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvacWaypointAir() when $default != null:
return $default(_that.kind,_that.latE7,_that.lonE7,_that.markerId,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int kind,  int latE7,  int lonE7,  String? markerId,  String? label)  $default,) {final _that = this;
switch (_that) {
case _EvacWaypointAir():
return $default(_that.kind,_that.latE7,_that.lonE7,_that.markerId,_that.label);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int kind,  int latE7,  int lonE7,  String? markerId,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _EvacWaypointAir() when $default != null:
return $default(_that.kind,_that.latE7,_that.lonE7,_that.markerId,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _EvacWaypointAir implements EvacWaypointAir {
  const _EvacWaypointAir({required this.kind, required this.latE7, required this.lonE7, this.markerId, this.label});
  

/// `marker` | `point` | `control` (see design doc).
@override final  int kind;
@override final  int latE7;
@override final  int lonE7;
@override final  String? markerId;
@override final  String? label;

/// Create a copy of EvacWaypointAir
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvacWaypointAirCopyWith<_EvacWaypointAir> get copyWith => __$EvacWaypointAirCopyWithImpl<_EvacWaypointAir>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvacWaypointAir&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.latE7, latE7) || other.latE7 == latE7)&&(identical(other.lonE7, lonE7) || other.lonE7 == lonE7)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,kind,latE7,lonE7,markerId,label);

@override
String toString() {
  return 'EvacWaypointAir(kind: $kind, latE7: $latE7, lonE7: $lonE7, markerId: $markerId, label: $label)';
}


}

/// @nodoc
abstract mixin class _$EvacWaypointAirCopyWith<$Res> implements $EvacWaypointAirCopyWith<$Res> {
  factory _$EvacWaypointAirCopyWith(_EvacWaypointAir value, $Res Function(_EvacWaypointAir) _then) = __$EvacWaypointAirCopyWithImpl;
@override @useResult
$Res call({
 int kind, int latE7, int lonE7, String? markerId, String? label
});




}
/// @nodoc
class __$EvacWaypointAirCopyWithImpl<$Res>
    implements _$EvacWaypointAirCopyWith<$Res> {
  __$EvacWaypointAirCopyWithImpl(this._self, this._then);

  final _EvacWaypointAir _self;
  final $Res Function(_EvacWaypointAir) _then;

/// Create a copy of EvacWaypointAir
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? latE7 = null,Object? lonE7 = null,Object? markerId = freezed,Object? label = freezed,}) {
  return _then(_EvacWaypointAir(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,latE7: null == latE7 ? _self.latE7 : latE7 // ignore: cast_nullable_to_non_nullable
as int,lonE7: null == lonE7 ? _self.lonE7 : lonE7 // ignore: cast_nullable_to_non_nullable
as int,markerId: freezed == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
