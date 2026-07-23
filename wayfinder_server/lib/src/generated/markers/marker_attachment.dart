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

abstract class MarkerAttachment
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MarkerAttachment._({
    _i1.UuidValue? id,
    required this.markerId,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.storageId,
    required this.addedAt,
    required this.sortOrder,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MarkerAttachment({
    _i1.UuidValue? id,
    required _i1.UuidValue markerId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required String storageId,
    required DateTime addedAt,
    required int sortOrder,
  }) = _MarkerAttachmentImpl;

  factory MarkerAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return MarkerAttachment(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      markerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['markerId'],
      ),
      fileName: jsonSerialization['fileName'] as String,
      contentType: jsonSerialization['contentType'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      storageId: jsonSerialization['storageId'] as String,
      addedAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  static final t = MarkerAttachmentTable();

  static const db = MarkerAttachmentRepository._();

  @override
  _i1.UuidValue id;

  /// Soft link to the owning marker
  _i1.UuidValue markerId;

  String fileName;

  String contentType;

  int sizeBytes;

  /// Basename under marker-attachment storage (same as id for new uploads)
  String storageId;

  DateTime addedAt;

  int sortOrder;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MarkerAttachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkerAttachment copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? markerId,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    String? storageId,
    DateTime? addedAt,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarkerAttachment',
      'id': id.toJson(),
      'markerId': markerId.toJson(),
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'storageId': storageId,
      'addedAt': addedAt.toJson(),
      'sortOrder': sortOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MarkerAttachment',
      'id': id.toJson(),
      'markerId': markerId.toJson(),
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'storageId': storageId,
      'addedAt': addedAt.toJson(),
      'sortOrder': sortOrder,
    };
  }

  static MarkerAttachmentInclude include() {
    return MarkerAttachmentInclude._();
  }

  static MarkerAttachmentIncludeList includeList({
    _i1.WhereExpressionBuilder<MarkerAttachmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerAttachmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerAttachmentTable>? orderByList,
    MarkerAttachmentInclude? include,
  }) {
    return MarkerAttachmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MarkerAttachment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MarkerAttachment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MarkerAttachmentImpl extends MarkerAttachment {
  _MarkerAttachmentImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue markerId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required String storageId,
    required DateTime addedAt,
    required int sortOrder,
  }) : super._(
         id: id,
         markerId: markerId,
         fileName: fileName,
         contentType: contentType,
         sizeBytes: sizeBytes,
         storageId: storageId,
         addedAt: addedAt,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [MarkerAttachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkerAttachment copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? markerId,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    String? storageId,
    DateTime? addedAt,
    int? sortOrder,
  }) {
    return MarkerAttachment(
      id: id ?? this.id,
      markerId: markerId ?? this.markerId,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storageId: storageId ?? this.storageId,
      addedAt: addedAt ?? this.addedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class MarkerAttachmentUpdateTable
    extends _i1.UpdateTable<MarkerAttachmentTable> {
  MarkerAttachmentUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> markerId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.markerId,
        value,
      );

  _i1.ColumnValue<String, String> fileName(String value) => _i1.ColumnValue(
    table.fileName,
    value,
  );

  _i1.ColumnValue<String, String> contentType(String value) => _i1.ColumnValue(
    table.contentType,
    value,
  );

  _i1.ColumnValue<int, int> sizeBytes(int value) => _i1.ColumnValue(
    table.sizeBytes,
    value,
  );

  _i1.ColumnValue<String, String> storageId(String value) => _i1.ColumnValue(
    table.storageId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> addedAt(DateTime value) =>
      _i1.ColumnValue(
        table.addedAt,
        value,
      );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );
}

class MarkerAttachmentTable extends _i1.Table<_i1.UuidValue> {
  MarkerAttachmentTable({super.tableRelation})
    : super(tableName: 'marker_attachment') {
    updateTable = MarkerAttachmentUpdateTable(this);
    markerId = _i1.ColumnUuid(
      'markerId',
      this,
    );
    fileName = _i1.ColumnString(
      'fileName',
      this,
    );
    contentType = _i1.ColumnString(
      'contentType',
      this,
    );
    sizeBytes = _i1.ColumnInt(
      'sizeBytes',
      this,
    );
    storageId = _i1.ColumnString(
      'storageId',
      this,
    );
    addedAt = _i1.ColumnDateTime(
      'addedAt',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
  }

  late final MarkerAttachmentUpdateTable updateTable;

  /// Soft link to the owning marker
  late final _i1.ColumnUuid markerId;

  late final _i1.ColumnString fileName;

  late final _i1.ColumnString contentType;

  late final _i1.ColumnInt sizeBytes;

  /// Basename under marker-attachment storage (same as id for new uploads)
  late final _i1.ColumnString storageId;

  late final _i1.ColumnDateTime addedAt;

  late final _i1.ColumnInt sortOrder;

  @override
  List<_i1.Column> get columns => [
    id,
    markerId,
    fileName,
    contentType,
    sizeBytes,
    storageId,
    addedAt,
    sortOrder,
  ];
}

class MarkerAttachmentInclude extends _i1.IncludeObject {
  MarkerAttachmentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MarkerAttachment.t;
}

class MarkerAttachmentIncludeList extends _i1.IncludeList {
  MarkerAttachmentIncludeList._({
    _i1.WhereExpressionBuilder<MarkerAttachmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MarkerAttachment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MarkerAttachment.t;
}

class MarkerAttachmentRepository {
  const MarkerAttachmentRepository._();

  /// Returns a list of [MarkerAttachment]s matching the given query parameters.
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
  Future<List<MarkerAttachment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerAttachmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerAttachmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerAttachmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MarkerAttachment>(
      where: where?.call(MarkerAttachment.t),
      orderBy: orderBy?.call(MarkerAttachment.t),
      orderByList: orderByList?.call(MarkerAttachment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MarkerAttachment] matching the given query parameters.
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
  Future<MarkerAttachment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerAttachmentTable>? where,
    int? offset,
    _i1.OrderByBuilder<MarkerAttachmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerAttachmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MarkerAttachment>(
      where: where?.call(MarkerAttachment.t),
      orderBy: orderBy?.call(MarkerAttachment.t),
      orderByList: orderByList?.call(MarkerAttachment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MarkerAttachment] by its [id] or null if no such row exists.
  Future<MarkerAttachment?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MarkerAttachment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MarkerAttachment]s in the list and returns the inserted rows.
  ///
  /// The returned [MarkerAttachment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MarkerAttachment>> insert(
    _i1.DatabaseSession session,
    List<MarkerAttachment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MarkerAttachment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MarkerAttachment] and returns the inserted row.
  ///
  /// The returned [MarkerAttachment] will have its `id` field set.
  Future<MarkerAttachment> insertRow(
    _i1.DatabaseSession session,
    MarkerAttachment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MarkerAttachment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MarkerAttachment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MarkerAttachment>> update(
    _i1.DatabaseSession session,
    List<MarkerAttachment> rows, {
    _i1.ColumnSelections<MarkerAttachmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MarkerAttachment>(
      rows,
      columns: columns?.call(MarkerAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MarkerAttachment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MarkerAttachment> updateRow(
    _i1.DatabaseSession session,
    MarkerAttachment row, {
    _i1.ColumnSelections<MarkerAttachmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MarkerAttachment>(
      row,
      columns: columns?.call(MarkerAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MarkerAttachment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MarkerAttachment?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MarkerAttachmentUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MarkerAttachment>(
      id,
      columnValues: columnValues(MarkerAttachment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MarkerAttachment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MarkerAttachment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MarkerAttachmentUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MarkerAttachmentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerAttachmentTable>? orderBy,
    _i1.OrderByListBuilder<MarkerAttachmentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MarkerAttachment>(
      columnValues: columnValues(MarkerAttachment.t.updateTable),
      where: where(MarkerAttachment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MarkerAttachment.t),
      orderByList: orderByList?.call(MarkerAttachment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MarkerAttachment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MarkerAttachment>> delete(
    _i1.DatabaseSession session,
    List<MarkerAttachment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MarkerAttachment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MarkerAttachment].
  Future<MarkerAttachment> deleteRow(
    _i1.DatabaseSession session,
    MarkerAttachment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MarkerAttachment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MarkerAttachment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MarkerAttachmentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MarkerAttachment>(
      where: where(MarkerAttachment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerAttachmentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MarkerAttachment>(
      where: where?.call(MarkerAttachment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MarkerAttachment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MarkerAttachmentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MarkerAttachment>(
      where: where(MarkerAttachment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
