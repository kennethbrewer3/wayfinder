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

abstract class PmtilesFileGroupLink implements _i1.SerializableModel {
  PmtilesFileGroupLink._({
    _i1.UuidValue? id,
    required this.fileId,
    required this.groupId,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory PmtilesFileGroupLink({
    _i1.UuidValue? id,
    required _i1.UuidValue fileId,
    required _i1.UuidValue groupId,
  }) = _PmtilesFileGroupLinkImpl;

  factory PmtilesFileGroupLink.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PmtilesFileGroupLink(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      fileId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['fileId']),
      groupId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupId'],
      ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue fileId;

  _i1.UuidValue groupId;

  /// Returns a shallow copy of this [PmtilesFileGroupLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesFileGroupLink copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? fileId,
    _i1.UuidValue? groupId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PmtilesFileGroupLink',
      'id': id.toJson(),
      'fileId': fileId.toJson(),
      'groupId': groupId.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PmtilesFileGroupLinkImpl extends PmtilesFileGroupLink {
  _PmtilesFileGroupLinkImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue fileId,
    required _i1.UuidValue groupId,
  }) : super._(
         id: id,
         fileId: fileId,
         groupId: groupId,
       );

  /// Returns a shallow copy of this [PmtilesFileGroupLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PmtilesFileGroupLink copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? fileId,
    _i1.UuidValue? groupId,
  }) {
    return PmtilesFileGroupLink(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      groupId: groupId ?? this.groupId,
    );
  }
}
