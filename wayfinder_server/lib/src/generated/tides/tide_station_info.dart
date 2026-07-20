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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class TideStationInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TideStationInfo._({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
  });

  factory TideStationInfo({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    double? distanceMeters,
  }) = _TideStationInfoImpl;

  factory TideStationInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return TideStationInfo(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      distanceMeters: (jsonSerialization['distanceMeters'] as num?)?.toDouble(),
    );
  }

  String id;

  String name;

  double latitude;

  double longitude;

  double? distanceMeters;

  /// Returns a shallow copy of this [TideStationInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TideStationInfo copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? distanceMeters,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TideStationInfo',
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (distanceMeters != null) 'distanceMeters': distanceMeters,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TideStationInfo',
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (distanceMeters != null) 'distanceMeters': distanceMeters,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TideStationInfoImpl extends TideStationInfo {
  _TideStationInfoImpl({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    double? distanceMeters,
  }) : super._(
         id: id,
         name: name,
         latitude: latitude,
         longitude: longitude,
         distanceMeters: distanceMeters,
       );

  /// Returns a shallow copy of this [TideStationInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TideStationInfo copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    Object? distanceMeters = _Undefined,
  }) {
    return TideStationInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters is double?
          ? distanceMeters
          : this.distanceMeters,
    );
  }
}
