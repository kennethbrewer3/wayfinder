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

abstract class PmtilesGroup
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  PmtilesGroup._({
    _i1.UuidValue? id,
    required this.name,
    int? sortOrder,
    required this.createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       sortOrder = sortOrder ?? 0;

  factory PmtilesGroup({
    _i1.UuidValue? id,
    required String name,
    int? sortOrder,
    required DateTime createdAt,
  }) = _PmtilesGroupImpl;

  factory PmtilesGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return PmtilesGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PmtilesGroupTable();

  static const db = PmtilesGroupRepository._();

  @override
  _i1.UuidValue id;

  String name;

  int sortOrder;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [PmtilesGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesGroup copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PmtilesGroup',
      'id': id.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PmtilesGroup',
      'id': id.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
    };
  }

  static PmtilesGroupInclude include() {
    return PmtilesGroupInclude._();
  }

  static PmtilesGroupIncludeList includeList({
    _i1.WhereExpressionBuilder<PmtilesGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesGroupTable>? orderByList,
    PmtilesGroupInclude? include,
  }) {
    return PmtilesGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PmtilesGroup.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PmtilesGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PmtilesGroupImpl extends PmtilesGroup {
  _PmtilesGroupImpl({
    _i1.UuidValue? id,
    required String name,
    int? sortOrder,
    required DateTime createdAt,
  }) : super._(
         id: id,
         name: name,
         sortOrder: sortOrder,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PmtilesGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PmtilesGroup copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return PmtilesGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PmtilesGroupUpdateTable extends _i1.UpdateTable<PmtilesGroupTable> {
  PmtilesGroupUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PmtilesGroupTable extends _i1.Table<_i1.UuidValue> {
  PmtilesGroupTable({super.tableRelation}) : super(tableName: 'pmtiles_group') {
    updateTable = PmtilesGroupUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PmtilesGroupUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnInt sortOrder;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    sortOrder,
    createdAt,
  ];
}

class PmtilesGroupInclude extends _i1.IncludeObject {
  PmtilesGroupInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => PmtilesGroup.t;
}

class PmtilesGroupIncludeList extends _i1.IncludeList {
  PmtilesGroupIncludeList._({
    _i1.WhereExpressionBuilder<PmtilesGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PmtilesGroup.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => PmtilesGroup.t;
}

class PmtilesGroupRepository {
  const PmtilesGroupRepository._();

  /// Returns a list of [PmtilesGroup]s matching the given query parameters.
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
  Future<List<PmtilesGroup>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PmtilesGroup>(
      where: where?.call(PmtilesGroup.t),
      orderBy: orderBy?.call(PmtilesGroup.t),
      orderByList: orderByList?.call(PmtilesGroup.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PmtilesGroup] matching the given query parameters.
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
  Future<PmtilesGroup?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesGroupTable>? where,
    int? offset,
    _i1.OrderByBuilder<PmtilesGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PmtilesGroup>(
      where: where?.call(PmtilesGroup.t),
      orderBy: orderBy?.call(PmtilesGroup.t),
      orderByList: orderByList?.call(PmtilesGroup.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PmtilesGroup] by its [id] or null if no such row exists.
  Future<PmtilesGroup?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PmtilesGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PmtilesGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [PmtilesGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PmtilesGroup>> insert(
    _i1.DatabaseSession session,
    List<PmtilesGroup> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PmtilesGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PmtilesGroup] and returns the inserted row.
  ///
  /// The returned [PmtilesGroup] will have its `id` field set.
  Future<PmtilesGroup> insertRow(
    _i1.DatabaseSession session,
    PmtilesGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PmtilesGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PmtilesGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PmtilesGroup>> update(
    _i1.DatabaseSession session,
    List<PmtilesGroup> rows, {
    _i1.ColumnSelections<PmtilesGroupTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PmtilesGroup>(
      rows,
      columns: columns?.call(PmtilesGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PmtilesGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PmtilesGroup> updateRow(
    _i1.DatabaseSession session,
    PmtilesGroup row, {
    _i1.ColumnSelections<PmtilesGroupTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PmtilesGroup>(
      row,
      columns: columns?.call(PmtilesGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PmtilesGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PmtilesGroup?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PmtilesGroupUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PmtilesGroup>(
      id,
      columnValues: columnValues(PmtilesGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PmtilesGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PmtilesGroup>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PmtilesGroupUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PmtilesGroupTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesGroupTable>? orderBy,
    _i1.OrderByListBuilder<PmtilesGroupTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PmtilesGroup>(
      columnValues: columnValues(PmtilesGroup.t.updateTable),
      where: where(PmtilesGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PmtilesGroup.t),
      orderByList: orderByList?.call(PmtilesGroup.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PmtilesGroup]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PmtilesGroup>> delete(
    _i1.DatabaseSession session,
    List<PmtilesGroup> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PmtilesGroup>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PmtilesGroup].
  Future<PmtilesGroup> deleteRow(
    _i1.DatabaseSession session,
    PmtilesGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PmtilesGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PmtilesGroup>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PmtilesGroupTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PmtilesGroup>(
      where: where(PmtilesGroup.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesGroupTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PmtilesGroup>(
      where: where?.call(PmtilesGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PmtilesGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PmtilesGroupTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PmtilesGroup>(
      where: where(PmtilesGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
