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

abstract class MarkerAttachment implements _i1.SerializableModel {
  MarkerAttachment._({
    _i1.UuidValue? id,
    required this.markerId,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.storageId,
    required this.addedAt,
    required this.sortOrder,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MarkerAttachment({
    _i1.UuidValue? id,
    required _i1.UuidValue markerId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required String storageId,
    required DateTime addedAt,
    required int sortOrder,
  }) = _MarkerAttachmentImpl;

  factory MarkerAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return MarkerAttachment(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      markerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['markerId'],
      ),
      fileName: jsonSerialization['fileName'] as String,
      contentType: jsonSerialization['contentType'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      storageId: jsonSerialization['storageId'] as String,
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  /// Soft link to the owning marker
  _i1.UuidValue markerId;

  String fileName;

  String contentType;

  int sizeBytes;

  /// Basename under marker-attachment storage (same as id for new uploads)
  String storageId;

  DateTime addedAt;

  int sortOrder;

  /// Returns a shallow copy of this [MarkerAttachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkerAttachment copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? markerId,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    String? storageId,
    DateTime? addedAt,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarkerAttachment',
      'id': id.toJson(),
      'markerId': markerId.toJson(),
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'storageId': storageId,
      'addedAt': addedAt.toJson(),
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MarkerAttachmentImpl extends MarkerAttachment {
  _MarkerAttachmentImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue markerId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required String storageId,
    required DateTime addedAt,
    required int sortOrder,
  }) : super._(
         id: id,
         markerId: markerId,
         fileName: fileName,
         contentType: contentType,
         sizeBytes: sizeBytes,
         storageId: storageId,
         addedAt: addedAt,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [MarkerAttachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkerAttachment copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? markerId,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    String? storageId,
    DateTime? addedAt,
    int? sortOrder,
  }) {
    return MarkerAttachment(
      id: id ?? this.id,
      markerId: markerId ?? this.markerId,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storageId: storageId ?? this.storageId,
      addedAt: addedAt ?? this.addedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
