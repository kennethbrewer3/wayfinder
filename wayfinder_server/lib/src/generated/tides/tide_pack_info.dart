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

abstract class TidePackInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TidePackInfo._({
    required this.id,
    required this.name,
    required this.source,
    required this.datum,
    required this.units,
    required this.stationCount,
    required this.sizeBytes,
    required this.addedAt,
    required this.isActive,
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
  });

  factory TidePackInfo({
    required String id,
    required String name,
    required String source,
    required String datum,
    required String units,
    required int stationCount,
    required int sizeBytes,
    required DateTime addedAt,
    required bool isActive,
    required double minLatitude,
    required double minLongitude,
    required double maxLatitude,
    required double maxLongitude,
  }) = _TidePackInfoImpl;

  factory TidePackInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return TidePackInfo(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      source: jsonSerialization['source'] as String,
      datum: jsonSerialization['datum'] as String,
      units: jsonSerialization['units'] as String,
      stationCount: jsonSerialization['stationCount'] as int,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      minLatitude: (jsonSerialization['minLatitude'] as num).toDouble(),
      minLongitude: (jsonSerialization['minLongitude'] as num).toDouble(),
      maxLatitude: (jsonSerialization['maxLatitude'] as num).toDouble(),
      maxLongitude: (jsonSerialization['maxLongitude'] as num).toDouble(),
    );
  }

  String id;

  String name;

  String source;

  String datum;

  String units;

  int stationCount;

  int sizeBytes;

  DateTime addedAt;

  bool isActive;

  double minLatitude;

  double minLongitude;

  double maxLatitude;

  double maxLongitude;

  /// Returns a shallow copy of this [TidePackInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TidePackInfo copyWith({
    String? id,
    String? name,
    String? source,
    String? datum,
    String? units,
    int? stationCount,
    int? sizeBytes,
    DateTime? addedAt,
    bool? isActive,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TidePackInfo',
      'id': id,
      'name': name,
      'source': source,
      'datum': datum,
      'units': units,
      'stationCount': stationCount,
      'sizeBytes': sizeBytes,
      'addedAt': addedAt.toJson(),
      'isActive': isActive,
      'minLatitude': minLatitude,
      'minLongitude': minLongitude,
      'maxLatitude': maxLatitude,
      'maxLongitude': maxLongitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TidePackInfo',
      'id': id,
      'name': name,
      'source': source,
      'datum': datum,
      'units': units,
      'stationCount': stationCount,
      'sizeBytes': sizeBytes,
      'addedAt': addedAt.toJson(),
      'isActive': isActive,
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

class _TidePackInfoImpl extends TidePackInfo {
  _TidePackInfoImpl({
    required String id,
    required String name,
    required String source,
    required String datum,
    required String units,
    required int stationCount,
    required int sizeBytes,
    required DateTime addedAt,
    required bool isActive,
    required double minLatitude,
    required double minLongitude,
    required double maxLatitude,
    required double maxLongitude,
  }) : super._(
         id: id,
         name: name,
         source: source,
         datum: datum,
         units: units,
         stationCount: stationCount,
         sizeBytes: sizeBytes,
         addedAt: addedAt,
         isActive: isActive,
         minLatitude: minLatitude,
         minLongitude: minLongitude,
         maxLatitude: maxLatitude,
         maxLongitude: maxLongitude,
       );

  /// Returns a shallow copy of this [TidePackInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TidePackInfo copyWith({
    String? id,
    String? name,
    String? source,
    String? datum,
    String? units,
    int? stationCount,
    int? sizeBytes,
    DateTime? addedAt,
    bool? isActive,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
  }) {
    return TidePackInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      datum: datum ?? this.datum,
      units: units ?? this.units,
      stationCount: stationCount ?? this.stationCount,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      addedAt: addedAt ?? this.addedAt,
      isActive: isActive ?? this.isActive,
      minLatitude: minLatitude ?? this.minLatitude,
      minLongitude: minLongitude ?? this.minLongitude,
      maxLatitude: maxLatitude ?? this.maxLatitude,
      maxLongitude: maxLongitude ?? this.maxLongitude,
    );
  }
}
