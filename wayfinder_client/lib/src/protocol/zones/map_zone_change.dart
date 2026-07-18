/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../zones/map_zone.dart' as _i2;
import 'package:wayfinder_client/src/protocol/protocol.dart' as _i3;

abstract class MapZoneChange implements _i1.SerializableModel {
  MapZoneChange._({
    required this.type,
    this.zone,
    this.zoneId,
  });

  factory MapZoneChange({
    required String type,
    _i2.MapZone? zone,
    _i1.UuidValue? zoneId,
  }) = _MapZoneChangeImpl;

  factory MapZoneChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapZoneChange(
      type: jsonSerialization['type'] as String,
      zone: jsonSerialization['zone'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.MapZone>(jsonSerialization['zone']),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
    );
  }

  /// One of: created, updated, deleted, bulk
  String type;

  _i2.MapZone? zone;

  _i1.UuidValue? zoneId;

  /// Returns a shallow copy of this [MapZoneChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapZoneChange copyWith({
    String? type,
    _i2.MapZone? zone,
    _i1.UuidValue? zoneId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapZoneChange',
      'type': type,
      if (zone != null) 'zone': zone?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapZoneChangeImpl extends MapZoneChange {
  _MapZoneChangeImpl({
    required String type,
    _i2.MapZone? zone,
    _i1.UuidValue? zoneId,
  }) : super._(
         type: type,
         zone: zone,
         zoneId: zoneId,
       );

  /// Returns a shallow copy of this [MapZoneChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapZoneChange copyWith({
    String? type,
    Object? zone = _Undefined,
    Object? zoneId = _Undefined,
  }) {
    return MapZoneChange(
      type: type ?? this.type,
      zone: zone is _i2.MapZone? ? zone : this.zone?.copyWith(),
      zoneId: zoneId is _i1.UuidValue? ? zoneId : this.zoneId,
    );
  }
}
