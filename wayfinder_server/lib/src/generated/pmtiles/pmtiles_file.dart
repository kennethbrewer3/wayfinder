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

abstract class PmtilesFile
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  PmtilesFile._({
    _i1.UuidValue? id,
    required this.name,
    required this.sizeBytes,
    required this.isActive,
    required this.addedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory PmtilesFile({
    _i1.UuidValue? id,
    required String name,
    required int sizeBytes,
    required bool isActive,
    required DateTime addedAt,
  }) = _PmtilesFileImpl;

  factory PmtilesFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return PmtilesFile(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
    );
  }

  static final t = PmtilesFileTable();

  static const db = PmtilesFileRepository._();

  @override
  _i1.UuidValue id;

  String name;

  int sizeBytes;

  bool isActive;

  DateTime addedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [PmtilesFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesFile copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sizeBytes,
    bool? isActive,
    DateTime? addedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PmtilesFile',
      'id': id.toJson(),
      'name': name,
      'sizeBytes': sizeBytes,
      'isActive': isActive,
      'addedAt': addedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PmtilesFile',
      'id': id.toJson(),
      'name': name,
      'sizeBytes': sizeBytes,
      'isActive': isActive,
      'addedAt': addedAt.toJson(),
    };
  }

  static PmtilesFileInclude include() {
    return PmtilesFileInclude._();
  }

  static PmtilesFileIncludeList includeList({
    _i1.WhereExpressionBuilder<PmtilesFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesFileTable>? orderByList,
    PmtilesFileInclude? include,
  }) {
    return PmtilesFileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PmtilesFile.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PmtilesFile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PmtilesFileImpl extends PmtilesFile {
  _PmtilesFileImpl({
    _i1.UuidValue? id,
    required String name,
    required int sizeBytes,
    required bool isActive,
    required DateTime addedAt,
  }) : super._(
         id: id,
         name: name,
         sizeBytes: sizeBytes,
         isActive: isActive,
         addedAt: addedAt,
       );

  /// Returns a shallow copy of this [PmtilesFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PmtilesFile copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sizeBytes,
    bool? isActive,
    DateTime? addedAt,
  }) {
    return PmtilesFile(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isActive: isActive ?? this.isActive,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class PmtilesFileUpdateTable extends _i1.UpdateTable<PmtilesFileTable> {
  PmtilesFileUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> sizeBytes(int value) => _i1.ColumnValue(
    table.sizeBytes,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> addedAt(DateTime value) =>
      _i1.ColumnValue(
        table.addedAt,
        value,
      );
}

class PmtilesFileTable extends _i1.Table<_i1.UuidValue> {
  PmtilesFileTable({super.tableRelation}) : super(tableName: 'pmtiles_file') {
    updateTable = PmtilesFileUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    sizeBytes = _i1.ColumnInt(
      'sizeBytes',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
    addedAt = _i1.ColumnDateTime(
      'addedAt',
      this,
    );
  }

  late final PmtilesFileUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnInt sizeBytes;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime addedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    sizeBytes,
    isActive,
    addedAt,
  ];
}

class PmtilesFileInclude extends _i1.IncludeObject {
  PmtilesFileInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => PmtilesFile.t;
}

class PmtilesFileIncludeList extends _i1.IncludeList {
  PmtilesFileIncludeList._({
    _i1.WhereExpressionBuilder<PmtilesFileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PmtilesFile.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => PmtilesFile.t;
}

class PmtilesFileRepository {
  const PmtilesFileRepository._();

  /// Returns a list of [PmtilesFile]s matching the given query parameters.
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
  Future<List<PmtilesFile>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesFileTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PmtilesFile>(
      where: where?.call(PmtilesFile.t),
      orderBy: orderBy?.call(PmtilesFile.t),
      orderByList: orderByList?.call(PmtilesFile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PmtilesFile] matching the given query parameters.
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
  Future<PmtilesFile?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesFileTable>? where,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PmtilesFileTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PmtilesFile>(
      where: where?.call(PmtilesFile.t),
      orderBy: orderBy?.call(PmtilesFile.t),
      orderByList: orderByList?.call(PmtilesFile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PmtilesFile] by its [id] or null if no such row exists.
  Future<PmtilesFile?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PmtilesFile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PmtilesFile]s in the list and returns the inserted rows.
  ///
  /// The returned [PmtilesFile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PmtilesFile>> insert(
    _i1.DatabaseSession session,
    List<PmtilesFile> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PmtilesFile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PmtilesFile] and returns the inserted row.
  ///
  /// The returned [PmtilesFile] will have its `id` field set.
  Future<PmtilesFile> insertRow(
    _i1.DatabaseSession session,
    PmtilesFile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PmtilesFile>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PmtilesFile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PmtilesFile>> update(
    _i1.DatabaseSession session,
    List<PmtilesFile> rows, {
    _i1.ColumnSelections<PmtilesFileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PmtilesFile>(
      rows,
      columns: columns?.call(PmtilesFile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PmtilesFile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PmtilesFile> updateRow(
    _i1.DatabaseSession session,
    PmtilesFile row, {
    _i1.ColumnSelections<PmtilesFileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PmtilesFile>(
      row,
      columns: columns?.call(PmtilesFile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PmtilesFile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PmtilesFile?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PmtilesFileUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PmtilesFile>(
      id,
      columnValues: columnValues(PmtilesFile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PmtilesFile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PmtilesFile>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PmtilesFileUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PmtilesFileTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PmtilesFileTable>? orderBy,
    _i1.OrderByListBuilder<PmtilesFileTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PmtilesFile>(
      columnValues: columnValues(PmtilesFile.t.updateTable),
      where: where(PmtilesFile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PmtilesFile.t),
      orderByList: orderByList?.call(PmtilesFile.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PmtilesFile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PmtilesFile>> delete(
    _i1.DatabaseSession session,
    List<PmtilesFile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PmtilesFile>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PmtilesFile].
  Future<PmtilesFile> deleteRow(
    _i1.DatabaseSession session,
    PmtilesFile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PmtilesFile>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PmtilesFile>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PmtilesFileTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PmtilesFile>(
      where: where(PmtilesFile.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PmtilesFileTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PmtilesFile>(
      where: where?.call(PmtilesFile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PmtilesFile] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PmtilesFileTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PmtilesFile>(
      where: where(PmtilesFile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
