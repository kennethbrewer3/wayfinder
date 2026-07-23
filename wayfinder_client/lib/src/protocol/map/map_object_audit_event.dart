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

/// Durable audit trail for marker/zone create, update, delete, restore, purge.
abstract class MapObjectAuditEvent implements _i1.SerializableModel {
  MapObjectAuditEvent._({
    _i1.UuidValue? id,
    required this.entityType,
    required this.entityId,
    this.entityName,
    required this.action,
    this.actorAuthUserId,
    this.actorUsername,
    this.snapshotJson,
    required this.createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MapObjectAuditEvent({
    _i1.UuidValue? id,
    required String entityType,
    required _i1.UuidValue entityId,
    String? entityName,
    required String action,
    _i1.UuidValue? actorAuthUserId,
    String? actorUsername,
    String? snapshotJson,
    required DateTime createdAt,
  }) = _MapObjectAuditEventImpl;

  factory MapObjectAuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapObjectAuditEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityType: jsonSerialization['entityType'] as String,
      entityId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      entityName: jsonSerialization['entityName'] as String?,
      action: jsonSerialization['action'] as String,
      actorAuthUserId: jsonSerialization['actorAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['actorAuthUserId'],
            ),
      actorUsername: jsonSerialization['actorUsername'] as String?,
      snapshotJson: jsonSerialization['snapshotJson'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  /// marker | zone
  String entityType;

  _i1.UuidValue entityId;

  String? entityName;

  /// created | updated | deleted | restored | purged
  String action;

  _i1.UuidValue? actorAuthUserId;

  /// Login id / label at event time
  String? actorUsername;

  /// Optional JSON snapshot of the entity at event time
  String? snapshotJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [MapObjectAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapObjectAuditEvent copyWith({
    _i1.UuidValue? id,
    String? entityType,
    _i1.UuidValue? entityId,
    String? entityName,
    String? action,
    _i1.UuidValue? actorAuthUserId,
    String? actorUsername,
    String? snapshotJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapObjectAuditEvent',
      'id': id.toJson(),
      'entityType': entityType,
      'entityId': entityId.toJson(),
      if (entityName != null) 'entityName': entityName,
      'action': action,
      if (actorAuthUserId != null) 'actorAuthUserId': actorAuthUserId?.toJson(),
      if (actorUsername != null) 'actorUsername': actorUsername,
      if (snapshotJson != null) 'snapshotJson': snapshotJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapObjectAuditEventImpl extends MapObjectAuditEvent {
  _MapObjectAuditEventImpl({
    _i1.UuidValue? id,
    required String entityType,
    required _i1.UuidValue entityId,
    String? entityName,
    required String action,
    _i1.UuidValue? actorAuthUserId,
    String? actorUsername,
    String? snapshotJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         entityType: entityType,
         entityId: entityId,
         entityName: entityName,
         action: action,
         actorAuthUserId: actorAuthUserId,
         actorUsername: actorUsername,
         snapshotJson: snapshotJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MapObjectAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapObjectAuditEvent copyWith({
    _i1.UuidValue? id,
    String? entityType,
    _i1.UuidValue? entityId,
    Object? entityName = _Undefined,
    String? action,
    Object? actorAuthUserId = _Undefined,
    Object? actorUsername = _Undefined,
    Object? snapshotJson = _Undefined,
    DateTime? createdAt,
  }) {
    return MapObjectAuditEvent(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityName: entityName is String? ? entityName : this.entityName,
      action: action ?? this.action,
      actorAuthUserId: actorAuthUserId is _i1.UuidValue?
          ? actorAuthUserId
          : this.actorAuthUserId,
      actorUsername: actorUsername is String?
          ? actorUsername
          : this.actorUsername,
      snapshotJson: snapshotJson is String? ? snapshotJson : this.snapshotJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
