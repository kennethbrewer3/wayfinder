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
import '../layers/map_layer.dart' as _i2;
import 'package:wayfinder_client/src/protocol/protocol.dart' as _i3;

abstract class MapLayerChange implements _i1.SerializableModel {
  MapLayerChange._({
    required this.type,
    this.layer,
    this.layerId,
  });

  factory MapLayerChange({
    required String type,
    _i2.MapLayer? layer,
    _i1.UuidValue? layerId,
  }) = _MapLayerChangeImpl;

  factory MapLayerChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapLayerChange(
      type: jsonSerialization['type'] as String,
      layer: jsonSerialization['layer'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.MapLayer>(
              jsonSerialization['layer'],
            ),
      layerId: jsonSerialization['layerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['layerId']),
    );
  }

  /// One of: created, updated, deleted, bulk
  String type;

  _i2.MapLayer? layer;

  _i1.UuidValue? layerId;

  /// Returns a shallow copy of this [MapLayerChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapLayerChange copyWith({
    String? type,
    _i2.MapLayer? layer,
    _i1.UuidValue? layerId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapLayerChange',
      'type': type,
      if (layer != null) 'layer': layer?.toJson(),
      if (layerId != null) 'layerId': layerId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapLayerChangeImpl extends MapLayerChange {
  _MapLayerChangeImpl({
    required String type,
    _i2.MapLayer? layer,
    _i1.UuidValue? layerId,
  }) : super._(
         type: type,
         layer: layer,
         layerId: layerId,
       );

  /// Returns a shallow copy of this [MapLayerChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapLayerChange copyWith({
    String? type,
    Object? layer = _Undefined,
    Object? layerId = _Undefined,
  }) {
    return MapLayerChange(
      type: type ?? this.type,
      layer: layer is _i2.MapLayer? ? layer : this.layer?.copyWith(),
      layerId: layerId is _i1.UuidValue? ? layerId : this.layerId,
    );
  }
}
