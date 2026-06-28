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
import '../map/map_marker.dart' as _i2;
import 'package:wayfinder_server/src/generated/protocol.dart' as _i3;

abstract class MapMarkerChange
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MapMarkerChange._({
    required this.type,
    this.marker,
    this.markerId,
  });

  factory MapMarkerChange({
    required String type,
    _i2.MapMarker? marker,
    _i1.UuidValue? markerId,
  }) = _MapMarkerChangeImpl;

  factory MapMarkerChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapMarkerChange(
      type: jsonSerialization['type'] as String,
      marker: jsonSerialization['marker'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.MapMarker>(
              jsonSerialization['marker'],
            ),
      markerId: jsonSerialization['markerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['markerId']),
    );
  }

  /// One of: created, updated, deleted, bulk
  String type;

  _i2.MapMarker? marker;

  _i1.UuidValue? markerId;

  /// Returns a shallow copy of this [MapMarkerChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapMarkerChange copyWith({
    String? type,
    _i2.MapMarker? marker,
    _i1.UuidValue? markerId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapMarkerChange',
      'type': type,
      if (marker != null) 'marker': marker?.toJson(),
      if (markerId != null) 'markerId': markerId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MapMarkerChange',
      'type': type,
      if (marker != null) 'marker': marker?.toJsonForProtocol(),
      if (markerId != null) 'markerId': markerId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapMarkerChangeImpl extends MapMarkerChange {
  _MapMarkerChangeImpl({
    required String type,
    _i2.MapMarker? marker,
    _i1.UuidValue? markerId,
  }) : super._(
         type: type,
         marker: marker,
         markerId: markerId,
       );

  /// Returns a shallow copy of this [MapMarkerChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapMarkerChange copyWith({
    String? type,
    Object? marker = _Undefined,
    Object? markerId = _Undefined,
  }) {
    return MapMarkerChange(
      type: type ?? this.type,
      marker: marker is _i2.MapMarker? ? marker : this.marker?.copyWith(),
      markerId: markerId is _i1.UuidValue? ? markerId : this.markerId,
    );
  }
}
