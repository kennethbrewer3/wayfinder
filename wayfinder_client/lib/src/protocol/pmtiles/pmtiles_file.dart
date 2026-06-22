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
import 'package:wayfinder_client/src/protocol/protocol.dart' as _i2;

abstract class PmtilesFile implements _i1.SerializableModel {
  PmtilesFile._({
    _i1.UuidValue? id,
    required this.name,
    required this.sizeBytes,
    required this.isActive,
    required this.addedAt,
    this.minZoom,
    this.maxZoom,
    this.minLatitude,
    this.minLongitude,
    this.maxLatitude,
    this.maxLongitude,
    this.groupIds,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory PmtilesFile({
    _i1.UuidValue? id,
    required String name,
    required int sizeBytes,
    required bool isActive,
    required DateTime addedAt,
    int? minZoom,
    int? maxZoom,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
    List<_i1.UuidValue>? groupIds,
  }) = _PmtilesFileImpl;

  factory PmtilesFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return PmtilesFile(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
      minZoom: jsonSerialization['minZoom'] as int?,
      maxZoom: jsonSerialization['maxZoom'] as int?,
      minLatitude: (jsonSerialization['minLatitude'] as num?)?.toDouble(),
      minLongitude: (jsonSerialization['minLongitude'] as num?)?.toDouble(),
      maxLatitude: (jsonSerialization['maxLatitude'] as num?)?.toDouble(),
      maxLongitude: (jsonSerialization['maxLongitude'] as num?)?.toDouble(),
      groupIds: jsonSerialization['groupIds'] == null
          ? null
          : _i2.Protocol().deserialize<List<_i1.UuidValue>>(
              jsonSerialization['groupIds'],
            ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String name;

  int sizeBytes;

  bool isActive;

  DateTime addedAt;

  int? minZoom;

  int? maxZoom;

  double? minLatitude;

  double? minLongitude;

  double? maxLatitude;

  double? maxLongitude;

  List<_i1.UuidValue>? groupIds;

  /// Returns a shallow copy of this [PmtilesFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesFile copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sizeBytes,
    bool? isActive,
    DateTime? addedAt,
    int? minZoom,
    int? maxZoom,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
    List<_i1.UuidValue>? groupIds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PmtilesFile',
      'id': id.toJson(),
      'name': name,
      'sizeBytes': sizeBytes,
      'isActive': isActive,
      'addedAt': addedAt.toJson(),
      if (minZoom != null) 'minZoom': minZoom,
      if (maxZoom != null) 'maxZoom': maxZoom,
      if (minLatitude != null) 'minLatitude': minLatitude,
      if (minLongitude != null) 'minLongitude': minLongitude,
      if (maxLatitude != null) 'maxLatitude': maxLatitude,
      if (maxLongitude != null) 'maxLongitude': maxLongitude,
      if (groupIds != null)
        'groupIds': groupIds?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PmtilesFileImpl extends PmtilesFile {
  _PmtilesFileImpl({
    _i1.UuidValue? id,
    required String name,
    required int sizeBytes,
    required bool isActive,
    required DateTime addedAt,
    int? minZoom,
    int? maxZoom,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
    List<_i1.UuidValue>? groupIds,
  }) : super._(
         id: id,
         name: name,
         sizeBytes: sizeBytes,
         isActive: isActive,
         addedAt: addedAt,
         minZoom: minZoom,
         maxZoom: maxZoom,
         minLatitude: minLatitude,
         minLongitude: minLongitude,
         maxLatitude: maxLatitude,
         maxLongitude: maxLongitude,
         groupIds: groupIds,
       );

  /// Returns a shallow copy of this [PmtilesFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PmtilesFile copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sizeBytes,
    bool? isActive,
    DateTime? addedAt,
    Object? minZoom = _Undefined,
    Object? maxZoom = _Undefined,
    Object? minLatitude = _Undefined,
    Object? minLongitude = _Undefined,
    Object? maxLatitude = _Undefined,
    Object? maxLongitude = _Undefined,
    Object? groupIds = _Undefined,
  }) {
    return PmtilesFile(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isActive: isActive ?? this.isActive,
      addedAt: addedAt ?? this.addedAt,
      minZoom: minZoom is int? ? minZoom : this.minZoom,
      maxZoom: maxZoom is int? ? maxZoom : this.maxZoom,
      minLatitude: minLatitude is double? ? minLatitude : this.minLatitude,
      minLongitude: minLongitude is double? ? minLongitude : this.minLongitude,
      maxLatitude: maxLatitude is double? ? maxLatitude : this.maxLatitude,
      maxLongitude: maxLongitude is double? ? maxLongitude : this.maxLongitude,
      groupIds: groupIds is List<_i1.UuidValue>?
          ? groupIds
          : this.groupIds?.map((e0) => e0).toList(),
    );
  }
}
