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

abstract class SeasonalOverlay
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  SeasonalOverlay._({
    _i1.UuidValue? id,
    required this.name,
    required this.color,
    required this.borderColor,
    required this.fillColor,
    bool? visible,
    this.notes,
    required this.dateMode,
    required this.dateWindowsJson,
    required this.geometryJson,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       visible = visible ?? true;

  factory SeasonalOverlay({
    _i1.UuidValue? id,
    required String name,
    required String color,
    required String borderColor,
    required String fillColor,
    bool? visible,
    String? notes,
    required String dateMode,
    required String dateWindowsJson,
    required String geometryJson,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SeasonalOverlayImpl;

  factory SeasonalOverlay.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeasonalOverlay(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      color: jsonSerialization['color'] as String,
      borderColor: jsonSerialization['borderColor'] as String,
      fillColor: jsonSerialization['fillColor'] as String,
      visible: jsonSerialization['visible'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
      notes: jsonSerialization['notes'] as String?,
      dateMode: jsonSerialization['dateMode'] as String,
      dateWindowsJson: jsonSerialization['dateWindowsJson'] as String,
      geometryJson: jsonSerialization['geometryJson'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = SeasonalOverlayTable();

  static const db = SeasonalOverlayRepository._();

  @override
  _i1.UuidValue id;

  String name;

  String color;

  String borderColor;

  String fillColor;

  bool visible;

  String? notes;

  /// One of: absolute, recurring
  String dateMode;

  /// JSON list of date windows (shape depends on dateMode)
  String dateWindowsJson;

  /// Polygon geometry JSON (same shape as MapZone polygon geometryJson)
  String geometryJson;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [SeasonalOverlay]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SeasonalOverlay copyWith({
    _i1.UuidValue? id,
    String? name,
    String? color,
    String? borderColor,
    String? fillColor,
    bool? visible,
    String? notes,
    String? dateMode,
    String? dateWindowsJson,
    String? geometryJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeasonalOverlay',
      'id': id.toJson(),
      'name': name,
      'color': color,
      'borderColor': borderColor,
      'fillColor': fillColor,
      'visible': visible,
      if (notes != null) 'notes': notes,
      'dateMode': dateMode,
      'dateWindowsJson': dateWindowsJson,
      'geometryJson': geometryJson,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SeasonalOverlay',
      'id': id.toJson(),
      'name': name,
      'color': color,
      'borderColor': borderColor,
      'fillColor': fillColor,
      'visible': visible,
      if (notes != null) 'notes': notes,
      'dateMode': dateMode,
      'dateWindowsJson': dateWindowsJson,
      'geometryJson': geometryJson,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static SeasonalOverlayInclude include() {
    return SeasonalOverlayInclude._();
  }

  static SeasonalOverlayIncludeList includeList({
    _i1.WhereExpressionBuilder<SeasonalOverlayTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SeasonalOverlayTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SeasonalOverlayTable>? orderByList,
    SeasonalOverlayInclude? include,
  }) {
    return SeasonalOverlayIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SeasonalOverlay.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SeasonalOverlay.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeasonalOverlayImpl extends SeasonalOverlay {
  _SeasonalOverlayImpl({
    _i1.UuidValue? id,
    required String name,
    required String color,
    required String borderColor,
    required String fillColor,
    bool? visible,
    String? notes,
    required String dateMode,
    required String dateWindowsJson,
    required String geometryJson,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         color: color,
         borderColor: borderColor,
         fillColor: fillColor,
         visible: visible,
         notes: notes,
         dateMode: dateMode,
         dateWindowsJson: dateWindowsJson,
         geometryJson: geometryJson,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SeasonalOverlay]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SeasonalOverlay copyWith({
    _i1.UuidValue? id,
    String? name,
    String? color,
    String? borderColor,
    String? fillColor,
    bool? visible,
    Object? notes = _Undefined,
    String? dateMode,
    String? dateWindowsJson,
    String? geometryJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeasonalOverlay(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      fillColor: fillColor ?? this.fillColor,
      visible: visible ?? this.visible,
      notes: notes is String? ? notes : this.notes,
      dateMode: dateMode ?? this.dateMode,
      dateWindowsJson: dateWindowsJson ?? this.dateWindowsJson,
      geometryJson: geometryJson ?? this.geometryJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SeasonalOverlayUpdateTable extends _i1.UpdateTable<SeasonalOverlayTable> {
  SeasonalOverlayUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> color(String value) => _i1.ColumnValue(
    table.color,
    value,
  );

  _i1.ColumnValue<String, String> borderColor(String value) => _i1.ColumnValue(
    table.borderColor,
    value,
  );

  _i1.ColumnValue<String, String> fillColor(String value) => _i1.ColumnValue(
    table.fillColor,
    value,
  );

  _i1.ColumnValue<bool, bool> visible(bool value) => _i1.ColumnValue(
    table.visible,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<String, String> dateMode(String value) => _i1.ColumnValue(
    table.dateMode,
    value,
  );

  _i1.ColumnValue<String, String> dateWindowsJson(String value) =>
      _i1.ColumnValue(
        table.dateWindowsJson,
        value,
      );

  _i1.ColumnValue<String, String> geometryJson(String value) => _i1.ColumnValue(
    table.geometryJson,
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

class SeasonalOverlayTable extends _i1.Table<_i1.UuidValue> {
  SeasonalOverlayTable({super.tableRelation})
    : super(tableName: 'seasonal_overlay') {
    updateTable = SeasonalOverlayUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    color = _i1.ColumnString(
      'color',
      this,
    );
    borderColor = _i1.ColumnString(
      'borderColor',
      this,
    );
    fillColor = _i1.ColumnString(
      'fillColor',
      this,
    );
    visible = _i1.ColumnBool(
      'visible',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    dateMode = _i1.ColumnString(
      'dateMode',
      this,
    );
    dateWindowsJson = _i1.ColumnString(
      'dateWindowsJson',
      this,
    );
    geometryJson = _i1.ColumnString(
      'geometryJson',
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

  late final SeasonalOverlayUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString color;

  late final _i1.ColumnString borderColor;

  late final _i1.ColumnString fillColor;

  late final _i1.ColumnBool visible;

  late final _i1.ColumnString notes;

  /// One of: absolute, recurring
  late final _i1.ColumnString dateMode;

  /// JSON list of date windows (shape depends on dateMode)
  late final _i1.ColumnString dateWindowsJson;

  /// Polygon geometry JSON (same shape as MapZone polygon geometryJson)
  late final _i1.ColumnString geometryJson;

  late final _i1.ColumnInt sortOrder;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    color,
    borderColor,
    fillColor,
    visible,
    notes,
    dateMode,
    dateWindowsJson,
    geometryJson,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}

class SeasonalOverlayInclude extends _i1.IncludeObject {
  SeasonalOverlayInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => SeasonalOverlay.t;
}

class SeasonalOverlayIncludeList extends _i1.IncludeList {
  SeasonalOverlayIncludeList._({
    _i1.WhereExpressionBuilder<SeasonalOverlayTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SeasonalOverlay.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => SeasonalOverlay.t;
}

class SeasonalOverlayRepository {
  const SeasonalOverlayRepository._();

  /// Returns a list of [SeasonalOverlay]s matching the given query parameters.
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
  Future<List<SeasonalOverlay>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SeasonalOverlayTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SeasonalOverlayTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SeasonalOverlayTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SeasonalOverlay>(
      where: where?.call(SeasonalOverlay.t),
      orderBy: orderBy?.call(SeasonalOverlay.t),
      orderByList: orderByList?.call(SeasonalOverlay.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SeasonalOverlay] matching the given query parameters.
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
  Future<SeasonalOverlay?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SeasonalOverlayTable>? where,
    int? offset,
    _i1.OrderByBuilder<SeasonalOverlayTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SeasonalOverlayTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SeasonalOverlay>(
      where: where?.call(SeasonalOverlay.t),
      orderBy: orderBy?.call(SeasonalOverlay.t),
      orderByList: orderByList?.call(SeasonalOverlay.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SeasonalOverlay] by its [id] or null if no such row exists.
  Future<SeasonalOverlay?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SeasonalOverlay>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SeasonalOverlay]s in the list and returns the inserted rows.
  ///
  /// The returned [SeasonalOverlay]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<SeasonalOverlay>> insert(
    _i1.DatabaseSession session,
    List<SeasonalOverlay> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SeasonalOverlay>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SeasonalOverlay] and returns the inserted row.
  ///
  /// The returned [SeasonalOverlay] will have its `id` field set.
  Future<SeasonalOverlay> insertRow(
    _i1.DatabaseSession session,
    SeasonalOverlay row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SeasonalOverlay>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SeasonalOverlay]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SeasonalOverlay>> update(
    _i1.DatabaseSession session,
    List<SeasonalOverlay> rows, {
    _i1.ColumnSelections<SeasonalOverlayTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SeasonalOverlay>(
      rows,
      columns: columns?.call(SeasonalOverlay.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SeasonalOverlay]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SeasonalOverlay> updateRow(
    _i1.DatabaseSession session,
    SeasonalOverlay row, {
    _i1.ColumnSelections<SeasonalOverlayTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SeasonalOverlay>(
      row,
      columns: columns?.call(SeasonalOverlay.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SeasonalOverlay] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SeasonalOverlay?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SeasonalOverlayUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SeasonalOverlay>(
      id,
      columnValues: columnValues(SeasonalOverlay.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SeasonalOverlay]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SeasonalOverlay>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SeasonalOverlayUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<SeasonalOverlayTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SeasonalOverlayTable>? orderBy,
    _i1.OrderByListBuilder<SeasonalOverlayTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SeasonalOverlay>(
      columnValues: columnValues(SeasonalOverlay.t.updateTable),
      where: where(SeasonalOverlay.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SeasonalOverlay.t),
      orderByList: orderByList?.call(SeasonalOverlay.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SeasonalOverlay]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SeasonalOverlay>> delete(
    _i1.DatabaseSession session,
    List<SeasonalOverlay> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SeasonalOverlay>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SeasonalOverlay].
  Future<SeasonalOverlay> deleteRow(
    _i1.DatabaseSession session,
    SeasonalOverlay row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SeasonalOverlay>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SeasonalOverlay>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SeasonalOverlayTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SeasonalOverlay>(
      where: where(SeasonalOverlay.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SeasonalOverlayTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SeasonalOverlay>(
      where: where?.call(SeasonalOverlay.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SeasonalOverlay] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SeasonalOverlayTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SeasonalOverlay>(
      where: where(SeasonalOverlay.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
