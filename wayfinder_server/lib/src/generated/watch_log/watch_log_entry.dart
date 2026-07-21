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

abstract class WatchLogEntry
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  WatchLogEntry._({
    _i1.UuidValue? id,
    required this.occurredAt,
    this.author,
    required this.severity,
    required this.text,
    this.markerId,
    this.zoneId,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory WatchLogEntry({
    _i1.UuidValue? id,
    required DateTime occurredAt,
    String? author,
    required String severity,
    required String text,
    _i1.UuidValue? markerId,
    _i1.UuidValue? zoneId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WatchLogEntryImpl;

  factory WatchLogEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return WatchLogEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      occurredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      author: jsonSerialization['author'] as String?,
      severity: jsonSerialization['severity'] as String,
      text: jsonSerialization['text'] as String,
      markerId: jsonSerialization['markerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['markerId']),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = WatchLogEntryTable();

  static const db = WatchLogEntryRepository._();

  @override
  _i1.UuidValue id;

  /// Event time (operator-editable; UTC)
  DateTime occurredAt;

  /// Optional freeform operator / callsign
  String? author;

  /// One of: info, notice, warning, critical
  String severity;

  String text;

  /// Soft link to a marker (optional)
  _i1.UuidValue? markerId;

  /// Soft link to a zone (optional)
  _i1.UuidValue? zoneId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [WatchLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WatchLogEntry copyWith({
    _i1.UuidValue? id,
    DateTime? occurredAt,
    String? author,
    String? severity,
    String? text,
    _i1.UuidValue? markerId,
    _i1.UuidValue? zoneId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WatchLogEntry',
      'id': id.toJson(),
      'occurredAt': occurredAt.toJson(),
      if (author != null) 'author': author,
      'severity': severity,
      'text': text,
      if (markerId != null) 'markerId': markerId?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WatchLogEntry',
      'id': id.toJson(),
      'occurredAt': occurredAt.toJson(),
      if (author != null) 'author': author,
      'severity': severity,
      'text': text,
      if (markerId != null) 'markerId': markerId?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static WatchLogEntryInclude include() {
    return WatchLogEntryInclude._();
  }

  static WatchLogEntryIncludeList includeList({
    _i1.WhereExpressionBuilder<WatchLogEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WatchLogEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WatchLogEntryTable>? orderByList,
    WatchLogEntryInclude? include,
  }) {
    return WatchLogEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WatchLogEntry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(WatchLogEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WatchLogEntryImpl extends WatchLogEntry {
  _WatchLogEntryImpl({
    _i1.UuidValue? id,
    required DateTime occurredAt,
    String? author,
    required String severity,
    required String text,
    _i1.UuidValue? markerId,
    _i1.UuidValue? zoneId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         occurredAt: occurredAt,
         author: author,
         severity: severity,
         text: text,
         markerId: markerId,
         zoneId: zoneId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WatchLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WatchLogEntry copyWith({
    _i1.UuidValue? id,
    DateTime? occurredAt,
    Object? author = _Undefined,
    String? severity,
    String? text,
    Object? markerId = _Undefined,
    Object? zoneId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WatchLogEntry(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      author: author is String? ? author : this.author,
      severity: severity ?? this.severity,
      text: text ?? this.text,
      markerId: markerId is _i1.UuidValue? ? markerId : this.markerId,
      zoneId: zoneId is _i1.UuidValue? ? zoneId : this.zoneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WatchLogEntryUpdateTable extends _i1.UpdateTable<WatchLogEntryTable> {
  WatchLogEntryUpdateTable(super.table);

  _i1.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _i1.ColumnValue(
        table.occurredAt,
        value,
      );

  _i1.ColumnValue<String, String> author(String? value) => _i1.ColumnValue(
    table.author,
    value,
  );

  _i1.ColumnValue<String, String> severity(String value) => _i1.ColumnValue(
    table.severity,
    value,
  );

  _i1.ColumnValue<String, String> text(String value) => _i1.ColumnValue(
    table.text,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> markerId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.markerId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> zoneId(_i1.UuidValue? value) =>
      _i1.ColumnValue(
        table.zoneId,
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

class WatchLogEntryTable extends _i1.Table<_i1.UuidValue> {
  WatchLogEntryTable({super.tableRelation})
    : super(tableName: 'watch_log_entry') {
    updateTable = WatchLogEntryUpdateTable(this);
    occurredAt = _i1.ColumnDateTime(
      'occurredAt',
      this,
    );
    author = _i1.ColumnString(
      'author',
      this,
    );
    severity = _i1.ColumnString(
      'severity',
      this,
    );
    text = _i1.ColumnString(
      'text',
      this,
    );
    markerId = _i1.ColumnUuid(
      'markerId',
      this,
    );
    zoneId = _i1.ColumnUuid(
      'zoneId',
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

  late final WatchLogEntryUpdateTable updateTable;

  /// Event time (operator-editable; UTC)
  late final _i1.ColumnDateTime occurredAt;

  /// Optional freeform operator / callsign
  late final _i1.ColumnString author;

  /// One of: info, notice, warning, critical
  late final _i1.ColumnString severity;

  late final _i1.ColumnString text;

  /// Soft link to a marker (optional)
  late final _i1.ColumnUuid markerId;

  /// Soft link to a zone (optional)
  late final _i1.ColumnUuid zoneId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    occurredAt,
    author,
    severity,
    text,
    markerId,
    zoneId,
    createdAt,
    updatedAt,
  ];
}

class WatchLogEntryInclude extends _i1.IncludeObject {
  WatchLogEntryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => WatchLogEntry.t;
}

class WatchLogEntryIncludeList extends _i1.IncludeList {
  WatchLogEntryIncludeList._({
    _i1.WhereExpressionBuilder<WatchLogEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WatchLogEntry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => WatchLogEntry.t;
}

class WatchLogEntryRepository {
  const WatchLogEntryRepository._();

  /// Returns a list of [WatchLogEntry]s matching the given query parameters.
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
  Future<List<WatchLogEntry>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<WatchLogEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WatchLogEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WatchLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WatchLogEntry>(
      where: where?.call(WatchLogEntry.t),
      orderBy: orderBy?.call(WatchLogEntry.t),
      orderByList: orderByList?.call(WatchLogEntry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WatchLogEntry] matching the given query parameters.
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
  Future<WatchLogEntry?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<WatchLogEntryTable>? where,
    int? offset,
    _i1.OrderByBuilder<WatchLogEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WatchLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WatchLogEntry>(
      where: where?.call(WatchLogEntry.t),
      orderBy: orderBy?.call(WatchLogEntry.t),
      orderByList: orderByList?.call(WatchLogEntry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WatchLogEntry] by its [id] or null if no such row exists.
  Future<WatchLogEntry?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WatchLogEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WatchLogEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [WatchLogEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<WatchLogEntry>> insert(
    _i1.DatabaseSession session,
    List<WatchLogEntry> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<WatchLogEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [WatchLogEntry] and returns the inserted row.
  ///
  /// The returned [WatchLogEntry] will have its `id` field set.
  Future<WatchLogEntry> insertRow(
    _i1.DatabaseSession session,
    WatchLogEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<WatchLogEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [WatchLogEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<WatchLogEntry>> update(
    _i1.DatabaseSession session,
    List<WatchLogEntry> rows, {
    _i1.ColumnSelections<WatchLogEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<WatchLogEntry>(
      rows,
      columns: columns?.call(WatchLogEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WatchLogEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WatchLogEntry> updateRow(
    _i1.DatabaseSession session,
    WatchLogEntry row, {
    _i1.ColumnSelections<WatchLogEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<WatchLogEntry>(
      row,
      columns: columns?.call(WatchLogEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WatchLogEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WatchLogEntry?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<WatchLogEntryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<WatchLogEntry>(
      id,
      columnValues: columnValues(WatchLogEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WatchLogEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<WatchLogEntry>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<WatchLogEntryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<WatchLogEntryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WatchLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<WatchLogEntryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<WatchLogEntry>(
      columnValues: columnValues(WatchLogEntry.t.updateTable),
      where: where(WatchLogEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WatchLogEntry.t),
      orderByList: orderByList?.call(WatchLogEntry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [WatchLogEntry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<WatchLogEntry>> delete(
    _i1.DatabaseSession session,
    List<WatchLogEntry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<WatchLogEntry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [WatchLogEntry].
  Future<WatchLogEntry> deleteRow(
    _i1.DatabaseSession session,
    WatchLogEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WatchLogEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<WatchLogEntry>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<WatchLogEntryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<WatchLogEntry>(
      where: where(WatchLogEntry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<WatchLogEntryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<WatchLogEntry>(
      where: where?.call(WatchLogEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WatchLogEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<WatchLogEntryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WatchLogEntry>(
      where: where(WatchLogEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
