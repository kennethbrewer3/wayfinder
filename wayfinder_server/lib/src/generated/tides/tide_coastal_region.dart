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

abstract class TideCoastalRegion
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TideCoastalRegion._({
    required this.id,
    required this.name,
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
  });

  factory TideCoastalRegion({
    required String id,
    required String name,
    required double minLatitude,
    required double minLongitude,
    required double maxLatitude,
    required double maxLongitude,
  }) = _TideCoastalRegionImpl;

  factory TideCoastalRegion.fromJson(Map<String, dynamic> jsonSerialization) {
    return TideCoastalRegion(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      minLatitude: (jsonSerialization['minLatitude'] as num).toDouble(),
      minLongitude: (jsonSerialization['minLongitude'] as num).toDouble(),
      maxLatitude: (jsonSerialization['maxLatitude'] as num).toDouble(),
      maxLongitude: (jsonSerialization['maxLongitude'] as num).toDouble(),
    );
  }

  String id;

  String name;

  double minLatitude;

  double minLongitude;

  double maxLatitude;

  double maxLongitude;

  /// Returns a shallow copy of this [TideCoastalRegion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TideCoastalRegion copyWith({
    String? id,
    String? name,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TideCoastalRegion',
      'id': id,
      'name': name,
      'minLatitude': minLatitude,
      'minLongitude': minLongitude,
      'maxLatitude': maxLatitude,
      'maxLongitude': maxLongitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TideCoastalRegion',
      'id': id,
      'name': name,
      'minLatitude': minLatitude,
      'minLongitude': minLongitude,
      'maxLatitude': maxLatitude,
      'maxLongitude': maxLongitude,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TideCoastalRegionImpl extends TideCoastalRegion {
  _TideCoastalRegionImpl({
    required String id,
    required String name,
    required double minLatitude,
    required double minLongitude,
    required double maxLatitude,
    required double maxLongitude,
  }) : super._(
         id: id,
         name: name,
         minLatitude: minLatitude,
         minLongitude: minLongitude,
         maxLatitude: maxLatitude,
         maxLongitude: maxLongitude,
       );

  /// Returns a shallow copy of this [TideCoastalRegion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TideCoastalRegion copyWith({
    String? id,
    String? name,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
  }) {
    return TideCoastalRegion(
      id: id ?? this.id,
      name: name ?? this.name,
      minLatitude: minLatitude ?? this.minLatitude,
      minLongitude: minLongitude ?? this.minLongitude,
      maxLatitude: maxLatitude ?? this.maxLatitude,
      maxLongitude: maxLongitude ?? this.maxLongitude,
    );
  }
}
