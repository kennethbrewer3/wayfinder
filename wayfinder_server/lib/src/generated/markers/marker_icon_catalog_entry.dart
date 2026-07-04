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

abstract class MarkerIconCatalogEntry
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MarkerIconCatalogEntry._({
    _i1.UuidValue? id,
    required this.key,
    required this.label,
    String? category,
    this.materialIcon,
    required this.coloredAsset,
    required this.glyphScale,
    required this.hasCustomSvg,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       category = category ?? 'custom';

  factory MarkerIconCatalogEntry({
    _i1.UuidValue? id,
    required String key,
    required String label,
    String? category,
    String? materialIcon,
    required bool coloredAsset,
    required double glyphScale,
    required bool hasCustomSvg,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarkerIconCatalogEntryImpl;

  factory MarkerIconCatalogEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MarkerIconCatalogEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
      category: jsonSerialization['category'] as String?,
      materialIcon: jsonSerialization['materialIcon'] as String?,
      coloredAsset: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['coloredAsset'],
      ),
      glyphScale: (jsonSerialization['glyphScale'] as num).toDouble(),
      hasCustomSvg: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasCustomSvg'],
      ),
      sortOrder: jsonSerialization['sortOrder'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = MarkerIconCatalogEntryTable();

  static const db = MarkerIconCatalogEntryRepository._();

  @override
  _i1.UuidValue id;

  String key;

  String label;

  String category;

  String? materialIcon;

  bool coloredAsset;

  double glyphScale;

  bool hasCustomSvg;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MarkerIconCatalogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkerIconCatalogEntry copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    String? category,
    String? materialIcon,
    bool? coloredAsset,
    double? glyphScale,
    bool? hasCustomSvg,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarkerIconCatalogEntry',
      'id': id.toJson(),
      'key': key,
      'label': label,
      'category': category,
      if (materialIcon != null) 'materialIcon': materialIcon,
      'coloredAsset': coloredAsset,
      'glyphScale': glyphScale,
      'hasCustomSvg': hasCustomSvg,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MarkerIconCatalogEntry',
      'id': id.toJson(),
      'key': key,
      'label': label,
      'category': category,
      if (materialIcon != null) 'materialIcon': materialIcon,
      'coloredAsset': coloredAsset,
      'glyphScale': glyphScale,
      'hasCustomSvg': hasCustomSvg,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MarkerIconCatalogEntryInclude include() {
    return MarkerIconCatalogEntryInclude._();
  }

  static MarkerIconCatalogEntryIncludeList includeList({
    _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCatalogEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerIconCatalogEntryTable>? orderByList,
    MarkerIconCatalogEntryInclude? include,
  }) {
    return MarkerIconCatalogEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MarkerIconCatalogEntry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MarkerIconCatalogEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MarkerIconCatalogEntryImpl extends MarkerIconCatalogEntry {
  _MarkerIconCatalogEntryImpl({
    _i1.UuidValue? id,
    required String key,
    required String label,
    String? category,
    String? materialIcon,
    required bool coloredAsset,
    required double glyphScale,
    required bool hasCustomSvg,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         label: label,
         category: category,
         materialIcon: materialIcon,
         coloredAsset: coloredAsset,
         glyphScale: glyphScale,
         hasCustomSvg: hasCustomSvg,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MarkerIconCatalogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkerIconCatalogEntry copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    String? category,
    Object? materialIcon = _Undefined,
    bool? coloredAsset,
    double? glyphScale,
    bool? hasCustomSvg,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarkerIconCatalogEntry(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
      category: category ?? this.category,
      materialIcon: materialIcon is String? ? materialIcon : this.materialIcon,
      coloredAsset: coloredAsset ?? this.coloredAsset,
      glyphScale: glyphScale ?? this.glyphScale,
      hasCustomSvg: hasCustomSvg ?? this.hasCustomSvg,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MarkerIconCatalogEntryUpdateTable
    extends _i1.UpdateTable<MarkerIconCatalogEntryTable> {
  MarkerIconCatalogEntryUpdateTable(super.table);

  _i1.ColumnValue<String, String> key(String value) => _i1.ColumnValue(
    table.key,
    value,
  );

  _i1.ColumnValue<String, String> label(String value) => _i1.ColumnValue(
    table.label,
    value,
  );

  _i1.ColumnValue<String, String> category(String value) => _i1.ColumnValue(
    table.category,
    value,
  );

  _i1.ColumnValue<String, String> materialIcon(String? value) =>
      _i1.ColumnValue(
        table.materialIcon,
        value,
      );

  _i1.ColumnValue<bool, bool> coloredAsset(bool value) => _i1.ColumnValue(
    table.coloredAsset,
    value,
  );

  _i1.ColumnValue<double, double> glyphScale(double value) => _i1.ColumnValue(
    table.glyphScale,
    value,
  );

  _i1.ColumnValue<bool, bool> hasCustomSvg(bool value) => _i1.ColumnValue(
    table.hasCustomSvg,
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

class MarkerIconCatalogEntryTable extends _i1.Table<_i1.UuidValue> {
  MarkerIconCatalogEntryTable({super.tableRelation})
    : super(tableName: 'marker_icon_catalog') {
    updateTable = MarkerIconCatalogEntryUpdateTable(this);
    key = _i1.ColumnString(
      'key',
      this,
    );
    label = _i1.ColumnString(
      'label',
      this,
    );
    category = _i1.ColumnString(
      'category',
      this,
      hasDefault: true,
    );
    materialIcon = _i1.ColumnString(
      'materialIcon',
      this,
    );
    coloredAsset = _i1.ColumnBool(
      'coloredAsset',
      this,
    );
    glyphScale = _i1.ColumnDouble(
      'glyphScale',
      this,
    );
    hasCustomSvg = _i1.ColumnBool(
      'hasCustomSvg',
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

  late final MarkerIconCatalogEntryUpdateTable updateTable;

  late final _i1.ColumnString key;

  late final _i1.ColumnString label;

  late final _i1.ColumnString category;

  late final _i1.ColumnString materialIcon;

  late final _i1.ColumnBool coloredAsset;

  late final _i1.ColumnDouble glyphScale;

  late final _i1.ColumnBool hasCustomSvg;

  late final _i1.ColumnInt sortOrder;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    key,
    label,
    category,
    materialIcon,
    coloredAsset,
    glyphScale,
    hasCustomSvg,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}

class MarkerIconCatalogEntryInclude extends _i1.IncludeObject {
  MarkerIconCatalogEntryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MarkerIconCatalogEntry.t;
}

class MarkerIconCatalogEntryIncludeList extends _i1.IncludeList {
  MarkerIconCatalogEntryIncludeList._({
    _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MarkerIconCatalogEntry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MarkerIconCatalogEntry.t;
}

class MarkerIconCatalogEntryRepository {
  const MarkerIconCatalogEntryRepository._();

  /// Returns a list of [MarkerIconCatalogEntry]s matching the given query parameters.
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
  Future<List<MarkerIconCatalogEntry>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCatalogEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerIconCatalogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MarkerIconCatalogEntry>(
      where: where?.call(MarkerIconCatalogEntry.t),
      orderBy: orderBy?.call(MarkerIconCatalogEntry.t),
      orderByList: orderByList?.call(MarkerIconCatalogEntry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MarkerIconCatalogEntry] matching the given query parameters.
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
  Future<MarkerIconCatalogEntry?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable>? where,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCatalogEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MarkerIconCatalogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MarkerIconCatalogEntry>(
      where: where?.call(MarkerIconCatalogEntry.t),
      orderBy: orderBy?.call(MarkerIconCatalogEntry.t),
      orderByList: orderByList?.call(MarkerIconCatalogEntry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MarkerIconCatalogEntry] by its [id] or null if no such row exists.
  Future<MarkerIconCatalogEntry?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MarkerIconCatalogEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MarkerIconCatalogEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [MarkerIconCatalogEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MarkerIconCatalogEntry>> insert(
    _i1.DatabaseSession session,
    List<MarkerIconCatalogEntry> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MarkerIconCatalogEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MarkerIconCatalogEntry] and returns the inserted row.
  ///
  /// The returned [MarkerIconCatalogEntry] will have its `id` field set.
  Future<MarkerIconCatalogEntry> insertRow(
    _i1.DatabaseSession session,
    MarkerIconCatalogEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MarkerIconCatalogEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MarkerIconCatalogEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MarkerIconCatalogEntry>> update(
    _i1.DatabaseSession session,
    List<MarkerIconCatalogEntry> rows, {
    _i1.ColumnSelections<MarkerIconCatalogEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MarkerIconCatalogEntry>(
      rows,
      columns: columns?.call(MarkerIconCatalogEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MarkerIconCatalogEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MarkerIconCatalogEntry> updateRow(
    _i1.DatabaseSession session,
    MarkerIconCatalogEntry row, {
    _i1.ColumnSelections<MarkerIconCatalogEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MarkerIconCatalogEntry>(
      row,
      columns: columns?.call(MarkerIconCatalogEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MarkerIconCatalogEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MarkerIconCatalogEntry?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MarkerIconCatalogEntryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MarkerIconCatalogEntry>(
      id,
      columnValues: columnValues(MarkerIconCatalogEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MarkerIconCatalogEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MarkerIconCatalogEntry>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MarkerIconCatalogEntryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MarkerIconCatalogEntryTable>? orderBy,
    _i1.OrderByListBuilder<MarkerIconCatalogEntryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MarkerIconCatalogEntry>(
      columnValues: columnValues(MarkerIconCatalogEntry.t.updateTable),
      where: where(MarkerIconCatalogEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MarkerIconCatalogEntry.t),
      orderByList: orderByList?.call(MarkerIconCatalogEntry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MarkerIconCatalogEntry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MarkerIconCatalogEntry>> delete(
    _i1.DatabaseSession session,
    List<MarkerIconCatalogEntry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MarkerIconCatalogEntry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MarkerIconCatalogEntry].
  Future<MarkerIconCatalogEntry> deleteRow(
    _i1.DatabaseSession session,
    MarkerIconCatalogEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MarkerIconCatalogEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MarkerIconCatalogEntry>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MarkerIconCatalogEntry>(
      where: where(MarkerIconCatalogEntry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MarkerIconCatalogEntry>(
      where: where?.call(MarkerIconCatalogEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MarkerIconCatalogEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MarkerIconCatalogEntryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MarkerIconCatalogEntry>(
      where: where(MarkerIconCatalogEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
