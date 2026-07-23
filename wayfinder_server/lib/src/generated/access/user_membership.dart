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

abstract class UserMembership
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  UserMembership._({
    _i1.UuidValue? id,
    required this.authUserId,
    required this.roleId,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory UserMembership({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required _i1.UuidValue roleId,
    required String email,
    String? displayName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserMembershipImpl;

  factory UserMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserMembership(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      roleId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['roleId']),
      email: jsonSerialization['email'] as String,
      displayName: jsonSerialization['displayName'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = UserMembershipTable();

  static const db = UserMembershipRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue authUserId;

  _i1.UuidValue roleId;

  String email;

  String? displayName;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [UserMembership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserMembership copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i1.UuidValue? roleId,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserMembership',
      'id': id.toJson(),
      'authUserId': authUserId.toJson(),
      'roleId': roleId.toJson(),
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserMembership',
      'id': id.toJson(),
      'authUserId': authUserId.toJson(),
      'roleId': roleId.toJson(),
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static UserMembershipInclude include() {
    return UserMembershipInclude._();
  }

  static UserMembershipIncludeList includeList({
    _i1.WhereExpressionBuilder<UserMembershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserMembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserMembershipTable>? orderByList,
    UserMembershipInclude? include,
  }) {
    return UserMembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserMembership.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserMembership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserMembershipImpl extends UserMembership {
  _UserMembershipImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required _i1.UuidValue roleId,
    required String email,
    String? displayName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         roleId: roleId,
         email: email,
         displayName: displayName,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserMembership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserMembership copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i1.UuidValue? roleId,
    String? email,
    Object? displayName = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserMembership(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      roleId: roleId ?? this.roleId,
      email: email ?? this.email,
      displayName: displayName is String? ? displayName : this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserMembershipUpdateTable extends _i1.UpdateTable<UserMembershipTable> {
  UserMembershipUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> roleId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.roleId,
        value,
      );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> displayName(String? value) => _i1.ColumnValue(
    table.displayName,
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

class UserMembershipTable extends _i1.Table<_i1.UuidValue> {
  UserMembershipTable({super.tableRelation})
    : super(tableName: 'user_membership') {
    updateTable = UserMembershipUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    roleId = _i1.ColumnUuid(
      'roleId',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    displayName = _i1.ColumnString(
      'displayName',
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

  late final UserMembershipUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  late final _i1.ColumnUuid roleId;

  late final _i1.ColumnString email;

  late final _i1.ColumnString displayName;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    roleId,
    email,
    displayName,
    createdAt,
    updatedAt,
  ];
}

class UserMembershipInclude extends _i1.IncludeObject {
  UserMembershipInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => UserMembership.t;
}

class UserMembershipIncludeList extends _i1.IncludeList {
  UserMembershipIncludeList._({
    _i1.WhereExpressionBuilder<UserMembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserMembership.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => UserMembership.t;
}

class UserMembershipRepository {
  const UserMembershipRepository._();

  /// Returns a list of [UserMembership]s matching the given query parameters.
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
  Future<List<UserMembership>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserMembershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserMembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserMembershipTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserMembership>(
      where: where?.call(UserMembership.t),
      orderBy: orderBy?.call(UserMembership.t),
      orderByList: orderByList?.call(UserMembership.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserMembership] matching the given query parameters.
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
  Future<UserMembership?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserMembershipTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserMembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserMembershipTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserMembership>(
      where: where?.call(UserMembership.t),
      orderBy: orderBy?.call(UserMembership.t),
      orderByList: orderByList?.call(UserMembership.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserMembership] by its [id] or null if no such row exists.
  Future<UserMembership?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserMembership>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserMembership]s in the list and returns the inserted rows.
  ///
  /// The returned [UserMembership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserMembership>> insert(
    _i1.DatabaseSession session,
    List<UserMembership> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserMembership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserMembership] and returns the inserted row.
  ///
  /// The returned [UserMembership] will have its `id` field set.
  Future<UserMembership> insertRow(
    _i1.DatabaseSession session,
    UserMembership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserMembership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserMembership>> update(
    _i1.DatabaseSession session,
    List<UserMembership> rows, {
    _i1.ColumnSelections<UserMembershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserMembership>(
      rows,
      columns: columns?.call(UserMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserMembership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserMembership> updateRow(
    _i1.DatabaseSession session,
    UserMembership row, {
    _i1.ColumnSelections<UserMembershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserMembership>(
      row,
      columns: columns?.call(UserMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserMembership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserMembership?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<UserMembershipUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserMembership>(
      id,
      columnValues: columnValues(UserMembership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserMembership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserMembership>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserMembershipUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserMembershipTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserMembershipTable>? orderBy,
    _i1.OrderByListBuilder<UserMembershipTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserMembership>(
      columnValues: columnValues(UserMembership.t.updateTable),
      where: where(UserMembership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserMembership.t),
      orderByList: orderByList?.call(UserMembership.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserMembership]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserMembership>> delete(
    _i1.DatabaseSession session,
    List<UserMembership> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserMembership>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserMembership].
  Future<UserMembership> deleteRow(
    _i1.DatabaseSession session,
    UserMembership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserMembership>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserMembershipTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserMembership>(
      where: where(UserMembership.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserMembershipTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserMembership>(
      where: where?.call(UserMembership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserMembership] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserMembershipTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserMembership>(
      where: where(UserMembership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
