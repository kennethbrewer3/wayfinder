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

abstract class RestApiKey
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
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

  static final t = RestApiKeyTable();

  static const db = RestApiKeyRepository._();

  @override
  _i1.UuidValue id;

  String name;

  String keyHash;

  String keyPreview;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RestApiKey',
      'id': id.toJson(),
      'name': name,
      'keyHash': keyHash,
      'keyPreview': keyPreview,
      'createdAt': createdAt.toJson(),
    };
  }

  static RestApiKeyInclude include() {
    return RestApiKeyInclude._();
  }

  static RestApiKeyIncludeList includeList({
    _i1.WhereExpressionBuilder<RestApiKeyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RestApiKeyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RestApiKeyTable>? orderByList,
    RestApiKeyInclude? include,
  }) {
    return RestApiKeyIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestApiKey.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RestApiKey.t),
      include: include,
    );
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

class RestApiKeyUpdateTable extends _i1.UpdateTable<RestApiKeyTable> {
  RestApiKeyUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> keyHash(String value) => _i1.ColumnValue(
    table.keyHash,
    value,
  );

  _i1.ColumnValue<String, String> keyPreview(String value) => _i1.ColumnValue(
    table.keyPreview,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class RestApiKeyTable extends _i1.Table<_i1.UuidValue> {
  RestApiKeyTable({super.tableRelation}) : super(tableName: 'rest_api_key') {
    updateTable = RestApiKeyUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    keyHash = _i1.ColumnString(
      'keyHash',
      this,
    );
    keyPreview = _i1.ColumnString(
      'keyPreview',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final RestApiKeyUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString keyHash;

  late final _i1.ColumnString keyPreview;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    keyHash,
    keyPreview,
    createdAt,
  ];
}

class RestApiKeyInclude extends _i1.IncludeObject {
  RestApiKeyInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => RestApiKey.t;
}

class RestApiKeyIncludeList extends _i1.IncludeList {
  RestApiKeyIncludeList._({
    _i1.WhereExpressionBuilder<RestApiKeyTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RestApiKey.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => RestApiKey.t;
}

class RestApiKeyRepository {
  const RestApiKeyRepository._();

  /// Returns a list of [RestApiKey]s matching the given query parameters.
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
  Future<List<RestApiKey>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RestApiKeyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RestApiKeyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RestApiKeyTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RestApiKey>(
      where: where?.call(RestApiKey.t),
      orderBy: orderBy?.call(RestApiKey.t),
      orderByList: orderByList?.call(RestApiKey.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RestApiKey] matching the given query parameters.
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
  Future<RestApiKey?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RestApiKeyTable>? where,
    int? offset,
    _i1.OrderByBuilder<RestApiKeyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RestApiKeyTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RestApiKey>(
      where: where?.call(RestApiKey.t),
      orderBy: orderBy?.call(RestApiKey.t),
      orderByList: orderByList?.call(RestApiKey.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RestApiKey] by its [id] or null if no such row exists.
  Future<RestApiKey?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RestApiKey>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RestApiKey]s in the list and returns the inserted rows.
  ///
  /// The returned [RestApiKey]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<RestApiKey>> insert(
    _i1.DatabaseSession session,
    List<RestApiKey> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RestApiKey>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RestApiKey] and returns the inserted row.
  ///
  /// The returned [RestApiKey] will have its `id` field set.
  Future<RestApiKey> insertRow(
    _i1.DatabaseSession session,
    RestApiKey row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RestApiKey>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RestApiKey]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RestApiKey>> update(
    _i1.DatabaseSession session,
    List<RestApiKey> rows, {
    _i1.ColumnSelections<RestApiKeyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RestApiKey>(
      rows,
      columns: columns?.call(RestApiKey.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestApiKey]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RestApiKey> updateRow(
    _i1.DatabaseSession session,
    RestApiKey row, {
    _i1.ColumnSelections<RestApiKeyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RestApiKey>(
      row,
      columns: columns?.call(RestApiKey.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestApiKey] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RestApiKey?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<RestApiKeyUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RestApiKey>(
      id,
      columnValues: columnValues(RestApiKey.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RestApiKey]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RestApiKey>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<RestApiKeyUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<RestApiKeyTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RestApiKeyTable>? orderBy,
    _i1.OrderByListBuilder<RestApiKeyTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RestApiKey>(
      columnValues: columnValues(RestApiKey.t.updateTable),
      where: where(RestApiKey.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestApiKey.t),
      orderByList: orderByList?.call(RestApiKey.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RestApiKey]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RestApiKey>> delete(
    _i1.DatabaseSession session,
    List<RestApiKey> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RestApiKey>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RestApiKey].
  Future<RestApiKey> deleteRow(
    _i1.DatabaseSession session,
    RestApiKey row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RestApiKey>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RestApiKey>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RestApiKeyTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RestApiKey>(
      where: where(RestApiKey.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RestApiKeyTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RestApiKey>(
      where: where?.call(RestApiKey.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RestApiKey] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RestApiKeyTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RestApiKey>(
      where: where(RestApiKey.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
