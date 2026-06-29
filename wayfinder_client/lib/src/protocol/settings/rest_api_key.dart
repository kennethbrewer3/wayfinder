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

abstract class RestApiKey implements _i1.SerializableModel {
  RestApiKey._({
    _i1.UuidValue? id,
    required this.name,
    required this.keyHash,
    required this.keyPreview,
    required this.createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory RestApiKey({
    _i1.UuidValue? id,
    required String name,
    required String keyHash,
    required String keyPreview,
    required DateTime createdAt,
  }) = _RestApiKeyImpl;

  factory RestApiKey.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestApiKey(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      keyHash: jsonSerialization['keyHash'] as String,
      keyPreview: jsonSerialization['keyPreview'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String name;

  String keyHash;

  String keyPreview;

  DateTime createdAt;

  /// Returns a shallow copy of this [RestApiKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RestApiKey copyWith({
    _i1.UuidValue? id,
    String? name,
    String? keyHash,
    String? keyPreview,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestApiKey',
      'id': id.toJson(),
      'name': name,
      'keyHash': keyHash,
      'keyPreview': keyPreview,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RestApiKeyImpl extends RestApiKey {
  _RestApiKeyImpl({
    _i1.UuidValue? id,
    required String name,
    required String keyHash,
    required String keyPreview,
    required DateTime createdAt,
  }) : super._(
         id: id,
         name: name,
         keyHash: keyHash,
         keyPreview: keyPreview,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [RestApiKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RestApiKey copyWith({
    _i1.UuidValue? id,
    String? name,
    String? keyHash,
    String? keyPreview,
    DateTime? createdAt,
  }) {
    return RestApiKey(
      id: id ?? this.id,
      name: name ?? this.name,
      keyHash: keyHash ?? this.keyHash,
      keyPreview: keyPreview ?? this.keyPreview,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
