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

abstract class AccessRole
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  AccessRole._({
    _i1.UuidValue? id,
    required this.key,
    required this.name,
    this.description,
    required this.isSystem,
    required this.permissionsJson,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory AccessRole({
    _i1.UuidValue? id,
    required String key,
    required String name,
    String? description,
    required bool isSystem,
    required String permissionsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccessRoleImpl;

  factory AccessRole.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccessRole(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      isSystem: _i1.BoolJsonExtension.fromJson(jsonSerialization['isSystem']),
      permissionsJson: jsonSerialization['permissionsJson'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = AccessRoleTable();

  static const db = AccessRoleRepository._();

  @override
  _i1.UuidValue id;

  /// Stable slug: admin, editor, viewer, or custom
  String key;

  String name;

  String? description;

  bool isSystem;

  /// JSON array of permission keys
  String permissionsJson;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [AccessRole]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccessRole copyWith({
    _i1.UuidValue? id,
    String? key,
    String? name,
    String? description,
    bool? isSystem,
    String? permissionsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccessRole',
      'id': id.toJson(),
      'key': key,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
      'permissionsJson': permissionsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccessRole',
      'id': id.toJson(),
      'key': key,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
      'permissionsJson': permissionsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AccessRoleInclude include() {
    return AccessRoleInclude._();
  }

  static AccessRoleIncludeList includeList({
    _i1.WhereExpressionBuilder<AccessRoleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccessRoleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccessRoleTable>? orderByList,
    AccessRoleInclude? include,
  }) {
    return AccessRoleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccessRole.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AccessRole.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccessRoleImpl extends AccessRole {
  _AccessRoleImpl({
    _i1.UuidValue? id,
    required String key,
    required String name,
    String? description,
    required bool isSystem,
    required String permissionsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         name: name,
         description: description,
         isSystem: isSystem,
         permissionsJson: permissionsJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccessRole]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccessRole copyWith({
    _i1.UuidValue? id,
    String? key,
    String? name,
    Object? description = _Undefined,
    bool? isSystem,
    String? permissionsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccessRole(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      isSystem: isSystem ?? this.isSystem,
      permissionsJson: permissionsJson ?? this.permissionsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AccessRoleUpdateTable extends _i1.UpdateTable<AccessRoleTable> {
  AccessRoleUpdateTable(super.table);

  _i1.ColumnValue<String, String> key(String value) => _i1.ColumnValue(
    table.key,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<bool, bool> isSystem(bool value) => _i1.ColumnValue(
    table.isSystem,
    value,
  );

  _i1.ColumnValue<String, String> permissionsJson(String value) =>
      _i1.ColumnValue(
        table.permissionsJson,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AccessRoleTable extends _i1.Table<_i1.UuidValue> {
  AccessRoleTable({super.tableRelation}) : super(tableName: 'access_role') {
    updateTable = AccessRoleUpdateTable(this);
    key = _i1.ColumnString(
      'key',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    isSystem = _i1.ColumnBool(
      'isSystem',
      this,
    );
    permissionsJson = _i1.ColumnString(
      'permissionsJson',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final AccessRoleUpdateTable updateTable;

  /// Stable slug: admin, editor, viewer, or custom
  late final _i1.ColumnString key;

  late final _i1.ColumnString name;

  late final _i1.ColumnString description;

  late final _i1.ColumnBool isSystem;

  /// JSON array of permission keys
  late final _i1.ColumnString permissionsJson;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    key,
    name,
    description,
    isSystem,
    permissionsJson,
    createdAt,
    updatedAt,
  ];
}

class AccessRoleInclude extends _i1.IncludeObject {
  AccessRoleInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => AccessRole.t;
}

class AccessRoleIncludeList extends _i1.IncludeList {
  AccessRoleIncludeList._({
    _i1.WhereExpressionBuilder<AccessRoleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccessRole.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => AccessRole.t;
}

class AccessRoleRepository {
  const AccessRoleRepository._();

  /// Returns a list of [AccessRole]s matching the given query parameters.
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
  Future<List<AccessRole>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AccessRoleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccessRoleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccessRoleTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccessRole>(
      where: where?.call(AccessRole.t),
      orderBy: orderBy?.call(AccessRole.t),
      orderByList: orderByList?.call(AccessRole.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AccessRole] matching the given query parameters.
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
  Future<AccessRole?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AccessRoleTable>? where,
    int? offset,
    _i1.OrderByBuilder<AccessRoleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccessRoleTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccessRole>(
      where: where?.call(AccessRole.t),
      orderBy: orderBy?.call(AccessRole.t),
      orderByList: orderByList?.call(AccessRole.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccessRole] by its [id] or null if no such row exists.
  Future<AccessRole?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccessRole>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccessRole]s in the list and returns the inserted rows.
  ///
  /// The returned [AccessRole]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AccessRole>> insert(
    _i1.DatabaseSession session,
    List<AccessRole> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AccessRole>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AccessRole] and returns the inserted row.
  ///
  /// The returned [AccessRole] will have its `id` field set.
  Future<AccessRole> insertRow(
    _i1.DatabaseSession session,
    AccessRole row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccessRole>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AccessRole]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AccessRole>> update(
    _i1.DatabaseSession session,
    List<AccessRole> rows, {
    _i1.ColumnSelections<AccessRoleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AccessRole>(
      rows,
      columns: columns?.call(AccessRole.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccessRole]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccessRole> updateRow(
    _i1.DatabaseSession session,
    AccessRole row, {
    _i1.ColumnSelections<AccessRoleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccessRole>(
      row,
      columns: columns?.call(AccessRole.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccessRole] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccessRole?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AccessRoleUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AccessRole>(
      id,
      columnValues: columnValues(AccessRole.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccessRole]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AccessRole>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AccessRoleUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AccessRoleTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccessRoleTable>? orderBy,
    _i1.OrderByListBuilder<AccessRoleTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AccessRole>(
      columnValues: columnValues(AccessRole.t.updateTable),
      where: where(AccessRole.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccessRole.t),
      orderByList: orderByList?.call(AccessRole.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AccessRole]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AccessRole>> delete(
    _i1.DatabaseSession session,
    List<AccessRole> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AccessRole>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AccessRole].
  Future<AccessRole> deleteRow(
    _i1.DatabaseSession session,
    AccessRole row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccessRole>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AccessRole>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AccessRoleTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AccessRole>(
      where: where(AccessRole.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AccessRoleTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AccessRole>(
      where: where?.call(AccessRole.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccessRole] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AccessRoleTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccessRole>(
      where: where(AccessRole.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
