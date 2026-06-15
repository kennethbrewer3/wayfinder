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

abstract class PmtilesFile implements _i1.SerializableModel {
  PmtilesFile._({
    _i1.UuidValue? id,
    required this.name,
    required this.sizeBytes,
    required this.isActive,
    required this.addedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory PmtilesFile({
    _i1.UuidValue? id,
    required String name,
    required int sizeBytes,
    required bool isActive,
    required DateTime addedAt,
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
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String name;

  int sizeBytes;

  bool isActive;

  DateTime addedAt;

  /// Returns a shallow copy of this [PmtilesFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesFile copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sizeBytes,
    bool? isActive,
    DateTime? addedAt,
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
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PmtilesFileImpl extends PmtilesFile {
  _PmtilesFileImpl({
    _i1.UuidValue? id,
    required String name,
    required int sizeBytes,
    required bool isActive,
    required DateTime addedAt,
  }) : super._(
         id: id,
         name: name,
         sizeBytes: sizeBytes,
         isActive: isActive,
         addedAt: addedAt,
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
  }) {
    return PmtilesFile(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isActive: isActive ?? this.isActive,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
