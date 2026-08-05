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

abstract class CommsPlan
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  CommsPlan._({
    _i1.UuidValue? id,
    required this.name,
    this.notes,
    String? timezoneIana,
    bool? active,
    required this.channelsJson,
    this.challengeTableJson,
    this.oneTimePadJson,
    this.cardOfTheDayJson,
    int? sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       timezoneIana = timezoneIana ?? 'UTC',
       active = active ?? true,
       sortOrder = sortOrder ?? 0;

  factory CommsPlan({
    _i1.UuidValue? id,
    required String name,
    String? notes,
    String? timezoneIana,
    bool? active,
    required String channelsJson,
    String? challengeTableJson,
    String? oneTimePadJson,
    String? cardOfTheDayJson,
    int? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CommsPlanImpl;

  factory CommsPlan.fromJson(Map<String, dynamic> jsonSerialization) {
    return CommsPlan(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      notes: jsonSerialization['notes'] as String?,
      timezoneIana: jsonSerialization['timezoneIana'] as String?,
      active: jsonSerialization['active'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['active']),
      channelsJson: jsonSerialization['channelsJson'] as String,
      challengeTableJson: jsonSerialization['challengeTableJson'] as String?,
      oneTimePadJson: jsonSerialization['oneTimePadJson'] as String?,
      cardOfTheDayJson: jsonSerialization['cardOfTheDayJson'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CommsPlanTable();

  static const db = CommsPlanRepository._();

  @override
  _i1.UuidValue id;

  String name;

  String? notes;

  /// IANA timezone for net schedules (e.g. America/New_York)
  String timezoneIana;

  /// When true, this plan is the operational board shown in the TOC
  bool active;

  /// JSON list of CommsPlanChannel objects
  String channelsJson;

  /// JSON radio challenge authentication table (matrix), or null when none
  String? challengeTableJson;

  /// JSON one-time pad sheets (29×4 groups of 5 letters), or null when none
  String? oneTimePadJson;

  /// JSON card-of-the-day sheets (date + code words + digit key), or null when none
  String? cardOfTheDayJson;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [CommsPlan]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CommsPlan copyWith({
    _i1.UuidValue? id,
    String? name,
    String? notes,
    String? timezoneIana,
    bool? active,
    String? channelsJson,
    String? challengeTableJson,
    String? oneTimePadJson,
    String? cardOfTheDayJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CommsPlan',
      'id': id.toJson(),
      'name': name,
      if (notes != null) 'notes': notes,
      'timezoneIana': timezoneIana,
      'active': active,
      'channelsJson': channelsJson,
      if (challengeTableJson != null) 'challengeTableJson': challengeTableJson,
      if (oneTimePadJson != null) 'oneTimePadJson': oneTimePadJson,
      if (cardOfTheDayJson != null) 'cardOfTheDayJson': cardOfTheDayJson,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CommsPlan',
      'id': id.toJson(),
      'name': name,
      if (notes != null) 'notes': notes,
      'timezoneIana': timezoneIana,
      'active': active,
      'channelsJson': channelsJson,
      if (challengeTableJson != null) 'challengeTableJson': challengeTableJson,
      if (oneTimePadJson != null) 'oneTimePadJson': oneTimePadJson,
      if (cardOfTheDayJson != null) 'cardOfTheDayJson': cardOfTheDayJson,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static CommsPlanInclude include() {
    return CommsPlanInclude._();
  }

  static CommsPlanIncludeList includeList({
    _i1.WhereExpressionBuilder<CommsPlanTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CommsPlanTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CommsPlanTable>? orderByList,
    CommsPlanInclude? include,
  }) {
    return CommsPlanIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CommsPlan.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CommsPlan.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CommsPlanImpl extends CommsPlan {
  _CommsPlanImpl({
    _i1.UuidValue? id,
    required String name,
    String? notes,
    String? timezoneIana,
    bool? active,
    required String channelsJson,
    String? challengeTableJson,
    String? oneTimePadJson,
    String? cardOfTheDayJson,
    int? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         notes: notes,
         timezoneIana: timezoneIana,
         active: active,
         channelsJson: channelsJson,
         challengeTableJson: challengeTableJson,
         oneTimePadJson: oneTimePadJson,
         cardOfTheDayJson: cardOfTheDayJson,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CommsPlan]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CommsPlan copyWith({
    _i1.UuidValue? id,
    String? name,
    Object? notes = _Undefined,
    String? timezoneIana,
    bool? active,
    String? channelsJson,
    Object? challengeTableJson = _Undefined,
    Object? oneTimePadJson = _Undefined,
    Object? cardOfTheDayJson = _Undefined,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommsPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes is String? ? notes : this.notes,
      timezoneIana: timezoneIana ?? this.timezoneIana,
      active: active ?? this.active,
      channelsJson: channelsJson ?? this.channelsJson,
      challengeTableJson: challengeTableJson is String?
          ? challengeTableJson
          : this.challengeTableJson,
      oneTimePadJson: oneTimePadJson is String?
          ? oneTimePadJson
          : this.oneTimePadJson,
      cardOfTheDayJson: cardOfTheDayJson is String?
          ? cardOfTheDayJson
          : this.cardOfTheDayJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommsPlanUpdateTable extends _i1.UpdateTable<CommsPlanTable> {
  CommsPlanUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<String, String> timezoneIana(String value) => _i1.ColumnValue(
    table.timezoneIana,
    value,
  );

  _i1.ColumnValue<bool, bool> active(bool value) => _i1.ColumnValue(
    table.active,
    value,
  );

  _i1.ColumnValue<String, String> channelsJson(String value) => _i1.ColumnValue(
    table.channelsJson,
    value,
  );

  _i1.ColumnValue<String, String> challengeTableJson(String? value) =>
      _i1.ColumnValue(
        table.challengeTableJson,
        value,
      );

  _i1.ColumnValue<String, String> oneTimePadJson(String? value) =>
      _i1.ColumnValue(
        table.oneTimePadJson,
        value,
      );

  _i1.ColumnValue<String, String> cardOfTheDayJson(String? value) =>
      _i1.ColumnValue(
        table.cardOfTheDayJson,
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

class CommsPlanTable extends _i1.Table<_i1.UuidValue> {
  CommsPlanTable({super.tableRelation}) : super(tableName: 'comms_plan') {
    updateTable = CommsPlanUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    timezoneIana = _i1.ColumnString(
      'timezoneIana',
      this,
      hasDefault: true,
    );
    active = _i1.ColumnBool(
      'active',
      this,
      hasDefault: true,
    );
    channelsJson = _i1.ColumnString(
      'channelsJson',
      this,
    );
    challengeTableJson = _i1.ColumnString(
      'challengeTableJson',
      this,
    );
    oneTimePadJson = _i1.ColumnString(
      'oneTimePadJson',
      this,
    );
    cardOfTheDayJson = _i1.ColumnString(
      'cardOfTheDayJson',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
      hasDefault: true,
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

  late final CommsPlanUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString notes;

  /// IANA timezone for net schedules (e.g. America/New_York)
  late final _i1.ColumnString timezoneIana;

  /// When true, this plan is the operational board shown in the TOC
  late final _i1.ColumnBool active;

  /// JSON list of CommsPlanChannel objects
  late final _i1.ColumnString channelsJson;

  /// JSON radio challenge authentication table (matrix), or null when none
  late final _i1.ColumnString challengeTableJson;

  /// JSON one-time pad sheets (29×4 groups of 5 letters), or null when none
  late final _i1.ColumnString oneTimePadJson;

  /// JSON card-of-the-day sheets (date + code words + digit key), or null when none
  late final _i1.ColumnString cardOfTheDayJson;

  late final _i1.ColumnInt sortOrder;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    notes,
    timezoneIana,
    active,
    channelsJson,
    challengeTableJson,
    oneTimePadJson,
    cardOfTheDayJson,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}

class CommsPlanInclude extends _i1.IncludeObject {
  CommsPlanInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => CommsPlan.t;
}

class CommsPlanIncludeList extends _i1.IncludeList {
  CommsPlanIncludeList._({
    _i1.WhereExpressionBuilder<CommsPlanTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CommsPlan.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => CommsPlan.t;
}

class CommsPlanRepository {
  const CommsPlanRepository._();

  /// Returns a list of [CommsPlan]s matching the given query parameters.
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
  Future<List<CommsPlan>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CommsPlanTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CommsPlanTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CommsPlanTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CommsPlan>(
      where: where?.call(CommsPlan.t),
      orderBy: orderBy?.call(CommsPlan.t),
      orderByList: orderByList?.call(CommsPlan.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CommsPlan] matching the given query parameters.
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
  Future<CommsPlan?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CommsPlanTable>? where,
    int? offset,
    _i1.OrderByBuilder<CommsPlanTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CommsPlanTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CommsPlan>(
      where: where?.call(CommsPlan.t),
      orderBy: orderBy?.call(CommsPlan.t),
      orderByList: orderByList?.call(CommsPlan.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CommsPlan] by its [id] or null if no such row exists.
  Future<CommsPlan?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CommsPlan>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CommsPlan]s in the list and returns the inserted rows.
  ///
  /// The returned [CommsPlan]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CommsPlan>> insert(
    _i1.DatabaseSession session,
    List<CommsPlan> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CommsPlan>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CommsPlan] and returns the inserted row.
  ///
  /// The returned [CommsPlan] will have its `id` field set.
  Future<CommsPlan> insertRow(
    _i1.DatabaseSession session,
    CommsPlan row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CommsPlan>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CommsPlan]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CommsPlan>> update(
    _i1.DatabaseSession session,
    List<CommsPlan> rows, {
    _i1.ColumnSelections<CommsPlanTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CommsPlan>(
      rows,
      columns: columns?.call(CommsPlan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CommsPlan]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CommsPlan> updateRow(
    _i1.DatabaseSession session,
    CommsPlan row, {
    _i1.ColumnSelections<CommsPlanTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CommsPlan>(
      row,
      columns: columns?.call(CommsPlan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CommsPlan] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CommsPlan?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<CommsPlanUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CommsPlan>(
      id,
      columnValues: columnValues(CommsPlan.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CommsPlan]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CommsPlan>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CommsPlanUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CommsPlanTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CommsPlanTable>? orderBy,
    _i1.OrderByListBuilder<CommsPlanTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CommsPlan>(
      columnValues: columnValues(CommsPlan.t.updateTable),
      where: where(CommsPlan.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CommsPlan.t),
      orderByList: orderByList?.call(CommsPlan.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CommsPlan]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CommsPlan>> delete(
    _i1.DatabaseSession session,
    List<CommsPlan> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CommsPlan>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CommsPlan].
  Future<CommsPlan> deleteRow(
    _i1.DatabaseSession session,
    CommsPlan row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CommsPlan>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CommsPlan>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CommsPlanTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CommsPlan>(
      where: where(CommsPlan.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CommsPlanTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CommsPlan>(
      where: where?.call(CommsPlan.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CommsPlan] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CommsPlanTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CommsPlan>(
      where: where(CommsPlan.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
