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

abstract class MapLayer
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MapLayer._({
    _i1.UuidValue? id,
    required this.name,
    required this.sortOrder,
    bool? visible,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       visible = visible ?? true;

  factory MapLayer({
    _i1.UuidValue? id,
    required String name,
    required int sortOrder,
    bool? visible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MapLayerImpl;

  factory MapLayer.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapLayer(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      visible: jsonSerialization['visible'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = MapLayerTable();

  static const db = MapLayerRepository._();

  @override
  _i1.UuidValue id;

  String name;

  int sortOrder;

  bool visible;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MapLayer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapLayer copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapLayer',
      'id': id.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'visible': visible,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MapLayer',
      'id': id.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'visible': visible,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MapLayerInclude include() {
    return MapLayerInclude._();
  }

  static MapLayerIncludeList includeList({
    _i1.WhereExpressionBuilder<MapLayerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapLayerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapLayerTable>? orderByList,
    MapLayerInclude? include,
  }) {
    return MapLayerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapLayer.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MapLayer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MapLayerImpl extends MapLayer {
  _MapLayerImpl({
    _i1.UuidValue? id,
    required String name,
    required int sortOrder,
    bool? visible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         sortOrder: sortOrder,
         visible: visible,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MapLayer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapLayer copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MapLayerUpdateTable extends _i1.UpdateTable<MapLayerTable> {
  MapLayerUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<bool, bool> visible(bool value) => _i1.ColumnValue(
    table.visible,
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

class MapLayerTable extends _i1.Table<_i1.UuidValue> {
  MapLayerTable({super.tableRelation}) : super(tableName: 'map_layer') {
    updateTable = MapLayerUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    visible = _i1.ColumnBool(
      'visible',
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

  late final MapLayerUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnInt sortOrder;

  late final _i1.ColumnBool visible;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    sortOrder,
    visible,
    createdAt,
    updatedAt,
  ];
}

class MapLayerInclude extends _i1.IncludeObject {
  MapLayerInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapLayer.t;
}

class MapLayerIncludeList extends _i1.IncludeList {
  MapLayerIncludeList._({
    _i1.WhereExpressionBuilder<MapLayerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MapLayer.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapLayer.t;
}

class MapLayerRepository {
  const MapLayerRepository._();

  /// Returns a list of [MapLayer]s matching the given query parameters.
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
  Future<List<MapLayer>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapLayerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapLayerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapLayerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MapLayer>(
      where: where?.call(MapLayer.t),
      orderBy: orderBy?.call(MapLayer.t),
      orderByList: orderByList?.call(MapLayer.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MapLayer] matching the given query parameters.
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
  Future<MapLayer?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapLayerTable>? where,
    int? offset,
    _i1.OrderByBuilder<MapLayerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapLayerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MapLayer>(
      where: where?.call(MapLayer.t),
      orderBy: orderBy?.call(MapLayer.t),
      orderByList: orderByList?.call(MapLayer.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MapLayer] by its [id] or null if no such row exists.
  Future<MapLayer?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MapLayer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MapLayer]s in the list and returns the inserted rows.
  ///
  /// The returned [MapLayer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MapLayer>> insert(
    _i1.DatabaseSession session,
    List<MapLayer> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MapLayer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MapLayer] and returns the inserted row.
  ///
  /// The returned [MapLayer] will have its `id` field set.
  Future<MapLayer> insertRow(
    _i1.DatabaseSession session,
    MapLayer row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MapLayer>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MapLayer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MapLayer>> update(
    _i1.DatabaseSession session,
    List<MapLayer> rows, {
    _i1.ColumnSelections<MapLayerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MapLayer>(
      rows,
      columns: columns?.call(MapLayer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapLayer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MapLayer> updateRow(
    _i1.DatabaseSession session,
    MapLayer row, {
    _i1.ColumnSelections<MapLayerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MapLayer>(
      row,
      columns: columns?.call(MapLayer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapLayer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MapLayer?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MapLayerUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MapLayer>(
      id,
      columnValues: columnValues(MapLayer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MapLayer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MapLayer>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MapLayerUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MapLayerTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapLayerTable>? orderBy,
    _i1.OrderByListBuilder<MapLayerTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MapLayer>(
      columnValues: columnValues(MapLayer.t.updateTable),
      where: where(MapLayer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapLayer.t),
      orderByList: orderByList?.call(MapLayer.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MapLayer]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MapLayer>> delete(
    _i1.DatabaseSession session,
    List<MapLayer> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MapLayer>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MapLayer].
  Future<MapLayer> deleteRow(
    _i1.DatabaseSession session,
    MapLayer row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MapLayer>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MapLayer>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapLayerTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MapLayer>(
      where: where(MapLayer.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapLayerTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MapLayer>(
      where: where?.call(MapLayer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MapLayer] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapLayerTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MapLayer>(
      where: where(MapLayer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
