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

/// Durable audit trail for marker/zone create, update, delete, restore, purge.
abstract class MapObjectAuditEvent
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
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

  static final t = MapObjectAuditEventTable();

  static const db = MapObjectAuditEventRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static MapObjectAuditEventInclude include() {
    return MapObjectAuditEventInclude._();
  }

  static MapObjectAuditEventIncludeList includeList({
    _i1.WhereExpressionBuilder<MapObjectAuditEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapObjectAuditEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapObjectAuditEventTable>? orderByList,
    MapObjectAuditEventInclude? include,
  }) {
    return MapObjectAuditEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapObjectAuditEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MapObjectAuditEvent.t),
      include: include,
    );
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

class MapObjectAuditEventUpdateTable
    extends _i1.UpdateTable<MapObjectAuditEventTable> {
  MapObjectAuditEventUpdateTable(super.table);

  _i1.ColumnValue<String, String> entityType(String value) => _i1.ColumnValue(
    table.entityType,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> entityId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.entityId,
        value,
      );

  _i1.ColumnValue<String, String> entityName(String? value) => _i1.ColumnValue(
    table.entityName,
    value,
  );

  _i1.ColumnValue<String, String> action(String value) => _i1.ColumnValue(
    table.action,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> actorAuthUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.actorAuthUserId,
    value,
  );

  _i1.ColumnValue<String, String> actorUsername(String? value) =>
      _i1.ColumnValue(
        table.actorUsername,
        value,
      );

  _i1.ColumnValue<String, String> snapshotJson(String? value) =>
      _i1.ColumnValue(
        table.snapshotJson,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class MapObjectAuditEventTable extends _i1.Table<_i1.UuidValue> {
  MapObjectAuditEventTable({super.tableRelation})
    : super(tableName: 'map_object_audit_event') {
    updateTable = MapObjectAuditEventUpdateTable(this);
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    entityId = _i1.ColumnUuid(
      'entityId',
      this,
    );
    entityName = _i1.ColumnString(
      'entityName',
      this,
    );
    action = _i1.ColumnString(
      'action',
      this,
    );
    actorAuthUserId = _i1.ColumnUuid(
      'actorAuthUserId',
      this,
    );
    actorUsername = _i1.ColumnString(
      'actorUsername',
      this,
    );
    snapshotJson = _i1.ColumnString(
      'snapshotJson',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MapObjectAuditEventUpdateTable updateTable;

  /// marker | zone
  late final _i1.ColumnString entityType;

  late final _i1.ColumnUuid entityId;

  late final _i1.ColumnString entityName;

  /// created | updated | deleted | restored | purged
  late final _i1.ColumnString action;

  late final _i1.ColumnUuid actorAuthUserId;

  /// Login id / label at event time
  late final _i1.ColumnString actorUsername;

  /// Optional JSON snapshot of the entity at event time
  late final _i1.ColumnString snapshotJson;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    entityType,
    entityId,
    entityName,
    action,
    actorAuthUserId,
    actorUsername,
    snapshotJson,
    createdAt,
  ];
}

class MapObjectAuditEventInclude extends _i1.IncludeObject {
  MapObjectAuditEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapObjectAuditEvent.t;
}

class MapObjectAuditEventIncludeList extends _i1.IncludeList {
  MapObjectAuditEventIncludeList._({
    _i1.WhereExpressionBuilder<MapObjectAuditEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MapObjectAuditEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapObjectAuditEvent.t;
}

class MapObjectAuditEventRepository {
  const MapObjectAuditEventRepository._();

  /// Returns a list of [MapObjectAuditEvent]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<MapObjectAuditEvent>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapObjectAuditEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapObjectAuditEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapObjectAuditEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MapObjectAuditEvent>(
      where: where?.call(MapObjectAuditEvent.t),
      orderBy: orderBy?.call(MapObjectAuditEvent.t),
      orderByList: orderByList?.call(MapObjectAuditEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MapObjectAuditEvent] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<MapObjectAuditEvent?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapObjectAuditEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<MapObjectAuditEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapObjectAuditEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MapObjectAuditEvent>(
      where: where?.call(MapObjectAuditEvent.t),
      orderBy: orderBy?.call(MapObjectAuditEvent.t),
      orderByList: orderByList?.call(MapObjectAuditEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MapObjectAuditEvent] by its [id] or null if no such row exists.
  Future<MapObjectAuditEvent?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MapObjectAuditEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MapObjectAuditEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [MapObjectAuditEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MapObjectAuditEvent>> insert(
    _i1.DatabaseSession session,
    List<MapObjectAuditEvent> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MapObjectAuditEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MapObjectAuditEvent] and returns the inserted row.
  ///
  /// The returned [MapObjectAuditEvent] will have its `id` field set.
  Future<MapObjectAuditEvent> insertRow(
    _i1.DatabaseSession session,
    MapObjectAuditEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MapObjectAuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MapObjectAuditEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MapObjectAuditEvent>> update(
    _i1.DatabaseSession session,
    List<MapObjectAuditEvent> rows, {
    _i1.ColumnSelections<MapObjectAuditEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MapObjectAuditEvent>(
      rows,
      columns: columns?.call(MapObjectAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapObjectAuditEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MapObjectAuditEvent> updateRow(
    _i1.DatabaseSession session,
    MapObjectAuditEvent row, {
    _i1.ColumnSelections<MapObjectAuditEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MapObjectAuditEvent>(
      row,
      columns: columns?.call(MapObjectAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapObjectAuditEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MapObjectAuditEvent?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MapObjectAuditEventUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MapObjectAuditEvent>(
      id,
      columnValues: columnValues(MapObjectAuditEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MapObjectAuditEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MapObjectAuditEvent>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MapObjectAuditEventUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MapObjectAuditEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapObjectAuditEventTable>? orderBy,
    _i1.OrderByListBuilder<MapObjectAuditEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MapObjectAuditEvent>(
      columnValues: columnValues(MapObjectAuditEvent.t.updateTable),
      where: where(MapObjectAuditEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapObjectAuditEvent.t),
      orderByList: orderByList?.call(MapObjectAuditEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MapObjectAuditEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MapObjectAuditEvent>> delete(
    _i1.DatabaseSession session,
    List<MapObjectAuditEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MapObjectAuditEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MapObjectAuditEvent].
  Future<MapObjectAuditEvent> deleteRow(
    _i1.DatabaseSession session,
    MapObjectAuditEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MapObjectAuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MapObjectAuditEvent>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapObjectAuditEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MapObjectAuditEvent>(
      where: where(MapObjectAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapObjectAuditEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MapObjectAuditEvent>(
      where: where?.call(MapObjectAuditEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MapObjectAuditEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapObjectAuditEventTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MapObjectAuditEvent>(
      where: where(MapObjectAuditEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
