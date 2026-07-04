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

abstract class MarkerIconCategoryDefinition
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MarkerIconCategoryDefinition._({
    _i1.UuidValue? id,
    required this.key,
    required this.label,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MarkerIconCategoryDefinition({
    _i1.UuidValue? id,
    required String key,
    required String label,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarkerIconCategoryDefinitionImpl;

  factory MarkerIconCategoryDefinition.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MarkerIconCategoryDefinition(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = MarkerIconCategoryDefinitionTable();

  static const db = MarkerIconCategoryDefinitionRepository._();

  @override
  _i1.UuidValue id;

  String key;

  String label;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MarkerIconCategoryDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkerIconCategoryDefinition copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarkerIconCategoryDefinition',
      'id': id.toJson(),
      'key': key,
      'label': label,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MarkerIconCategoryDefinition',
      'id': id.toJson(),
      'key': key,
      'label': label,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MarkerIconCategoryDefinitionInclude include() {
    return MarkerIconCategoryDefinitionInclude._();
  }

  static MarkerIconCategoryDefinitionIncludeList includeList({
    _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCategoryDefinitionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerIconCategoryDefinitionTable>? orderByList,
    MarkerIconCategoryDefinitionInclude? include,
  }) {
    return MarkerIconCategoryDefinitionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MarkerIconCategoryDefinition.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MarkerIconCategoryDefinition.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MarkerIconCategoryDefinitionImpl extends MarkerIconCategoryDefinition {
  _MarkerIconCategoryDefinitionImpl({
    _i1.UuidValue? id,
    required String key,
    required String label,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         label: label,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MarkerIconCategoryDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkerIconCategoryDefinition copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarkerIconCategoryDefinition(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MarkerIconCategoryDefinitionUpdateTable
    extends _i1.UpdateTable<MarkerIconCategoryDefinitionTable> {
  MarkerIconCategoryDefinitionUpdateTable(super.table);

  _i1.ColumnValue<String, String> key(String value) => _i1.ColumnValue(
    table.key,
    value,
  );

  _i1.ColumnValue<String, String> label(String value) => _i1.ColumnValue(
    table.label,
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

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class MarkerIconCategoryDefinitionTable extends _i1.Table<_i1.UuidValue> {
  MarkerIconCategoryDefinitionTable({super.tableRelation})
    : super(tableName: 'marker_icon_category') {
    updateTable = MarkerIconCategoryDefinitionUpdateTable(this);
    key = _i1.ColumnString(
      'key',
      this,
    );
    label = _i1.ColumnString(
      'label',
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
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final MarkerIconCategoryDefinitionUpdateTable updateTable;

  late final _i1.ColumnString key;

  late final _i1.ColumnString label;

  late final _i1.ColumnInt sortOrder;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    key,
    label,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}

class MarkerIconCategoryDefinitionInclude extends _i1.IncludeObject {
  MarkerIconCategoryDefinitionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MarkerIconCategoryDefinition.t;
}

class MarkerIconCategoryDefinitionIncludeList extends _i1.IncludeList {
  MarkerIconCategoryDefinitionIncludeList._({
    _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MarkerIconCategoryDefinition.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MarkerIconCategoryDefinition.t;
}

class MarkerIconCategoryDefinitionRepository {
  const MarkerIconCategoryDefinitionRepository._();

  /// Returns a list of [MarkerIconCategoryDefinition]s matching the given query parameters.
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
  Future<List<MarkerIconCategoryDefinition>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCategoryDefinitionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerIconCategoryDefinitionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MarkerIconCategoryDefinition>(
      where: where?.call(MarkerIconCategoryDefinition.t),
      orderBy: orderBy?.call(MarkerIconCategoryDefinition.t),
      orderByList: orderByList?.call(MarkerIconCategoryDefinition.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MarkerIconCategoryDefinition] matching the given query parameters.
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
  Future<MarkerIconCategoryDefinition?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>? where,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCategoryDefinitionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerIconCategoryDefinitionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MarkerIconCategoryDefinition>(
      where: where?.call(MarkerIconCategoryDefinition.t),
      orderBy: orderBy?.call(MarkerIconCategoryDefinition.t),
      orderByList: orderByList?.call(MarkerIconCategoryDefinition.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MarkerIconCategoryDefinition] by its [id] or null if no such row exists.
  Future<MarkerIconCategoryDefinition?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MarkerIconCategoryDefinition>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MarkerIconCategoryDefinition]s in the list and returns the inserted rows.
  ///
  /// The returned [MarkerIconCategoryDefinition]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MarkerIconCategoryDefinition>> insert(
    _i1.DatabaseSession session,
    List<MarkerIconCategoryDefinition> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MarkerIconCategoryDefinition>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MarkerIconCategoryDefinition] and returns the inserted row.
  ///
  /// The returned [MarkerIconCategoryDefinition] will have its `id` field set.
  Future<MarkerIconCategoryDefinition> insertRow(
    _i1.DatabaseSession session,
    MarkerIconCategoryDefinition row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MarkerIconCategoryDefinition>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MarkerIconCategoryDefinition]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MarkerIconCategoryDefinition>> update(
    _i1.DatabaseSession session,
    List<MarkerIconCategoryDefinition> rows, {
    _i1.ColumnSelections<MarkerIconCategoryDefinitionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MarkerIconCategoryDefinition>(
      rows,
      columns: columns?.call(MarkerIconCategoryDefinition.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MarkerIconCategoryDefinition]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MarkerIconCategoryDefinition> updateRow(
    _i1.DatabaseSession session,
    MarkerIconCategoryDefinition row, {
    _i1.ColumnSelections<MarkerIconCategoryDefinitionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MarkerIconCategoryDefinition>(
      row,
      columns: columns?.call(MarkerIconCategoryDefinition.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MarkerIconCategoryDefinition] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MarkerIconCategoryDefinition?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MarkerIconCategoryDefinitionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MarkerIconCategoryDefinition>(
      id,
      columnValues: columnValues(MarkerIconCategoryDefinition.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MarkerIconCategoryDefinition]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MarkerIconCategoryDefinition>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MarkerIconCategoryDefinitionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>
    where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCategoryDefinitionTable>? orderBy,
    _i1.OrderByListBuilder<MarkerIconCategoryDefinitionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MarkerIconCategoryDefinition>(
      columnValues: columnValues(MarkerIconCategoryDefinition.t.updateTable),
      where: where(MarkerIconCategoryDefinition.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MarkerIconCategoryDefinition.t),
      orderByList: orderByList?.call(MarkerIconCategoryDefinition.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MarkerIconCategoryDefinition]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MarkerIconCategoryDefinition>> delete(
    _i1.DatabaseSession session,
    List<MarkerIconCategoryDefinition> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MarkerIconCategoryDefinition>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MarkerIconCategoryDefinition].
  Future<MarkerIconCategoryDefinition> deleteRow(
    _i1.DatabaseSession session,
    MarkerIconCategoryDefinition row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MarkerIconCategoryDefinition>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MarkerIconCategoryDefinition>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>
    where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MarkerIconCategoryDefinition>(
      where: where(MarkerIconCategoryDefinition.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MarkerIconCategoryDefinition>(
      where: where?.call(MarkerIconCategoryDefinition.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MarkerIconCategoryDefinition] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MarkerIconCategoryDefinitionTable>
    where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MarkerIconCategoryDefinition>(
      where: where(MarkerIconCategoryDefinition.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
