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

abstract class PmtilesFileGroupLink
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  PmtilesFileGroupLink._({
    _i1.UuidValue? id,
    required this.fileId,
    required this.groupId,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory PmtilesFileGroupLink({
    _i1.UuidValue? id,
    required _i1.UuidValue fileId,
    required _i1.UuidValue groupId,
  }) = _PmtilesFileGroupLinkImpl;

  factory PmtilesFileGroupLink.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PmtilesFileGroupLink(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      fileId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['fileId']),
      groupId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupId'],
      ),
    );
  }

  static final t = PmtilesFileGroupLinkTable();

  static const db = PmtilesFileGroupLinkRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue fileId;

  _i1.UuidValue groupId;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [PmtilesFileGroupLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesFileGroupLink copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? fileId,
    _i1.UuidValue? groupId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PmtilesFileGroupLink',
      'id': id.toJson(),
      'fileId': fileId.toJson(),
      'groupId': groupId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PmtilesFileGroupLink',
      'id': id.toJson(),
      'fileId': fileId.toJson(),
      'groupId': groupId.toJson(),
    };
  }

  static PmtilesFileGroupLinkInclude include() {
    return PmtilesFileGroupLinkInclude._();
  }

  static PmtilesFileGroupLinkIncludeList includeList({
    _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileGroupLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesFileGroupLinkTable>? orderByList,
    PmtilesFileGroupLinkInclude? include,
  }) {
    return PmtilesFileGroupLinkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PmtilesFileGroupLink.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PmtilesFileGroupLink.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PmtilesFileGroupLinkImpl extends PmtilesFileGroupLink {
  _PmtilesFileGroupLinkImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue fileId,
    required _i1.UuidValue groupId,
  }) : super._(
         id: id,
         fileId: fileId,
         groupId: groupId,
       );

  /// Returns a shallow copy of this [PmtilesFileGroupLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PmtilesFileGroupLink copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? fileId,
    _i1.UuidValue? groupId,
  }) {
    return PmtilesFileGroupLink(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      groupId: groupId ?? this.groupId,
    );
  }
}

class PmtilesFileGroupLinkUpdateTable
    extends _i1.UpdateTable<PmtilesFileGroupLinkTable> {
  PmtilesFileGroupLinkUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> fileId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.fileId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> groupId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.groupId,
        value,
      );
}

class PmtilesFileGroupLinkTable extends _i1.Table<_i1.UuidValue> {
  PmtilesFileGroupLinkTable({super.tableRelation})
    : super(tableName: 'pmtiles_file_group') {
    updateTable = PmtilesFileGroupLinkUpdateTable(this);
    fileId = _i1.ColumnUuid(
      'fileId',
      this,
    );
    groupId = _i1.ColumnUuid(
      'groupId',
      this,
    );
  }

  late final PmtilesFileGroupLinkUpdateTable updateTable;

  late final _i1.ColumnUuid fileId;

  late final _i1.ColumnUuid groupId;

  @override
  List<_i1.Column> get columns => [
    id,
    fileId,
    groupId,
  ];
}

class PmtilesFileGroupLinkInclude extends _i1.IncludeObject {
  PmtilesFileGroupLinkInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => PmtilesFileGroupLink.t;
}

class PmtilesFileGroupLinkIncludeList extends _i1.IncludeList {
  PmtilesFileGroupLinkIncludeList._({
    _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PmtilesFileGroupLink.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => PmtilesFileGroupLink.t;
}

class PmtilesFileGroupLinkRepository {
  const PmtilesFileGroupLinkRepository._();

  /// Returns a list of [PmtilesFileGroupLink]s matching the given query parameters.
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
  Future<List<PmtilesFileGroupLink>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileGroupLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesFileGroupLinkTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PmtilesFileGroupLink>(
      where: where?.call(PmtilesFileGroupLink.t),
      orderBy: orderBy?.call(PmtilesFileGroupLink.t),
      orderByList: orderByList?.call(PmtilesFileGroupLink.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PmtilesFileGroupLink] matching the given query parameters.
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
  Future<PmtilesFileGroupLink?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable>? where,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileGroupLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesFileGroupLinkTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PmtilesFileGroupLink>(
      where: where?.call(PmtilesFileGroupLink.t),
      orderBy: orderBy?.call(PmtilesFileGroupLink.t),
      orderByList: orderByList?.call(PmtilesFileGroupLink.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PmtilesFileGroupLink] by its [id] or null if no such row exists.
  Future<PmtilesFileGroupLink?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PmtilesFileGroupLink>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PmtilesFileGroupLink]s in the list and returns the inserted rows.
  ///
  /// The returned [PmtilesFileGroupLink]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PmtilesFileGroupLink>> insert(
    _i1.DatabaseSession session,
    List<PmtilesFileGroupLink> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PmtilesFileGroupLink>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PmtilesFileGroupLink] and returns the inserted row.
  ///
  /// The returned [PmtilesFileGroupLink] will have its `id` field set.
  Future<PmtilesFileGroupLink> insertRow(
    _i1.DatabaseSession session,
    PmtilesFileGroupLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PmtilesFileGroupLink>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PmtilesFileGroupLink]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PmtilesFileGroupLink>> update(
    _i1.DatabaseSession session,
    List<PmtilesFileGroupLink> rows, {
    _i1.ColumnSelections<PmtilesFileGroupLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PmtilesFileGroupLink>(
      rows,
      columns: columns?.call(PmtilesFileGroupLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PmtilesFileGroupLink]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PmtilesFileGroupLink> updateRow(
    _i1.DatabaseSession session,
    PmtilesFileGroupLink row, {
    _i1.ColumnSelections<PmtilesFileGroupLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PmtilesFileGroupLink>(
      row,
      columns: columns?.call(PmtilesFileGroupLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PmtilesFileGroupLink] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PmtilesFileGroupLink?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PmtilesFileGroupLinkUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PmtilesFileGroupLink>(
      id,
      columnValues: columnValues(PmtilesFileGroupLink.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PmtilesFileGroupLink]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PmtilesFileGroupLink>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PmtilesFileGroupLinkUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileGroupLinkTable>? orderBy,
    _i1.OrderByListBuilder<PmtilesFileGroupLinkTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PmtilesFileGroupLink>(
      columnValues: columnValues(PmtilesFileGroupLink.t.updateTable),
      where: where(PmtilesFileGroupLink.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PmtilesFileGroupLink.t),
      orderByList: orderByList?.call(PmtilesFileGroupLink.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PmtilesFileGroupLink]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PmtilesFileGroupLink>> delete(
    _i1.DatabaseSession session,
    List<PmtilesFileGroupLink> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PmtilesFileGroupLink>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PmtilesFileGroupLink].
  Future<PmtilesFileGroupLink> deleteRow(
    _i1.DatabaseSession session,
    PmtilesFileGroupLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PmtilesFileGroupLink>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PmtilesFileGroupLink>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PmtilesFileGroupLink>(
      where: where(PmtilesFileGroupLink.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PmtilesFileGroupLink>(
      where: where?.call(PmtilesFileGroupLink.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PmtilesFileGroupLink] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PmtilesFileGroupLinkTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PmtilesFileGroupLink>(
      where: where(PmtilesFileGroupLink.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
