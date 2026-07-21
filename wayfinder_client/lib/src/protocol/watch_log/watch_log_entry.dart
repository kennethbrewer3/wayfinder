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

abstract class WatchLogEntry implements _i1.SerializableModel {
  WatchLogEntry._({
    _i1.UuidValue? id,
    required this.occurredAt,
    this.author,
    required this.severity,
    required this.text,
    this.markerId,
    this.zoneId,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory WatchLogEntry({
    _i1.UuidValue? id,
    required DateTime occurredAt,
    String? author,
    required String severity,
    required String text,
    _i1.UuidValue? markerId,
    _i1.UuidValue? zoneId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WatchLogEntryImpl;

  factory WatchLogEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return WatchLogEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      occurredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      author: jsonSerialization['author'] as String?,
      severity: jsonSerialization['severity'] as String,
      text: jsonSerialization['text'] as String,
      markerId: jsonSerialization['markerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['markerId']),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  /// Event time (operator-editable; UTC)
  DateTime occurredAt;

  /// Optional freeform operator / callsign
  String? author;

  /// One of: info, notice, warning, critical
  String severity;

  String text;

  /// Soft link to a marker (optional)
  _i1.UuidValue? markerId;

  /// Soft link to a zone (optional)
  _i1.UuidValue? zoneId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [WatchLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WatchLogEntry copyWith({
    _i1.UuidValue? id,
    DateTime? occurredAt,
    String? author,
    String? severity,
    String? text,
    _i1.UuidValue? markerId,
    _i1.UuidValue? zoneId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WatchLogEntry',
      'id': id.toJson(),
      'occurredAt': occurredAt.toJson(),
      if (author != null) 'author': author,
      'severity': severity,
      'text': text,
      if (markerId != null) 'markerId': markerId?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WatchLogEntryImpl extends WatchLogEntry {
  _WatchLogEntryImpl({
    _i1.UuidValue? id,
    required DateTime occurredAt,
    String? author,
    required String severity,
    required String text,
    _i1.UuidValue? markerId,
    _i1.UuidValue? zoneId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         occurredAt: occurredAt,
         author: author,
         severity: severity,
         text: text,
         markerId: markerId,
         zoneId: zoneId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WatchLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WatchLogEntry copyWith({
    _i1.UuidValue? id,
    DateTime? occurredAt,
    Object? author = _Undefined,
    String? severity,
    String? text,
    Object? markerId = _Undefined,
    Object? zoneId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WatchLogEntry(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      author: author is String? ? author : this.author,
      severity: severity ?? this.severity,
      text: text ?? this.text,
      markerId: markerId is _i1.UuidValue? ? markerId : this.markerId,
      zoneId: zoneId is _i1.UuidValue? ? zoneId : this.zoneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
