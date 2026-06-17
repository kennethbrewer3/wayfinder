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

abstract class MapZone
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MapZone._({
    _i1.UuidValue? id,
    required this.name,
    required this.type,
    required this.color,
    required this.borderColor,
    required this.borderPattern,
    required this.fillColor,
    required this.visible,
    required this.geometryJson,
    this.layerId,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MapZone({
    _i1.UuidValue? id,
    required String name,
    required String type,
    required String color,
    required String borderColor,
    required String borderPattern,
    required String fillColor,
    required bool visible,
    required String geometryJson,
    _i1.UuidValue? layerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MapZoneImpl;

  factory MapZone.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapZone(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      type: jsonSerialization['type'] as String,
      color: jsonSerialization['color'] as String,
      borderColor: jsonSerialization['borderColor'] as String,
      borderPattern: jsonSerialization['borderPattern'] as String,
      fillColor: jsonSerialization['fillColor'] as String,
      visible: _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
      geometryJson: jsonSerialization['geometryJson'] as String,
      layerId: jsonSerialization['layerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['layerId']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = MapZoneTable();

  static const db = MapZoneRepository._();

  @override
  _i1.UuidValue id;

  String name;

  String type;

  String color;

  String borderColor;

  String borderPattern;

  String fillColor;

  bool visible;

  String geometryJson;

  _i1.UuidValue? layerId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MapZone]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapZone copyWith({
    _i1.UuidValue? id,
    String? name,
    String? type,
    String? color,
    String? borderColor,
    String? borderPattern,
    String? fillColor,
    bool? visible,
    String? geometryJson,
    _i1.UuidValue? layerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapZone',
      'id': id.toJson(),
      'name': name,
      'type': type,
      'color': color,
      'borderColor': borderColor,
      'borderPattern': borderPattern,
      'fillColor': fillColor,
      'visible': visible,
      'geometryJson': geometryJson,
      if (layerId != null) 'layerId': layerId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MapZone',
      'id': id.toJson(),
      'name': name,
      'type': type,
      'color': color,
      'borderColor': borderColor,
      'borderPattern': borderPattern,
      'fillColor': fillColor,
      'visible': visible,
      'geometryJson': geometryJson,
      if (layerId != null) 'layerId': layerId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MapZoneInclude include() {
    return MapZoneInclude._();
  }

  static MapZoneIncludeList includeList({
    _i1.WhereExpressionBuilder<MapZoneTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapZoneTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapZoneTable>? orderByList,
    MapZoneInclude? include,
  }) {
    return MapZoneIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapZone.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MapZone.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapZoneImpl extends MapZone {
  _MapZoneImpl({
    _i1.UuidValue? id,
    required String name,
    required String type,
    required String color,
    required String borderColor,
    required String borderPattern,
    required String fillColor,
    required bool visible,
    required String geometryJson,
    _i1.UuidValue? layerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         type: type,
         color: color,
         borderColor: borderColor,
         borderPattern: borderPattern,
         fillColor: fillColor,
         visible: visible,
         geometryJson: geometryJson,
         layerId: layerId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MapZone]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapZone copyWith({
    _i1.UuidValue? id,
    String? name,
    String? type,
    String? color,
    String? borderColor,
    String? borderPattern,
    String? fillColor,
    bool? visible,
    String? geometryJson,
    Object? layerId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapZone(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      borderPattern: borderPattern ?? this.borderPattern,
      fillColor: fillColor ?? this.fillColor,
      visible: visible ?? this.visible,
      geometryJson: geometryJson ?? this.geometryJson,
      layerId: layerId is _i1.UuidValue? ? layerId : this.layerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MapZoneUpdateTable extends _i1.UpdateTable<MapZoneTable> {
  MapZoneUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> type(String value) => _i1.ColumnValue(
    table.type,
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

  _i1.ColumnValue<String, String> borderPattern(String value) =>
      _i1.ColumnValue(
        table.borderPattern,
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

  _i1.ColumnValue<String, String> geometryJson(String value) => _i1.ColumnValue(
    table.geometryJson,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> layerId(_i1.UuidValue? value) =>
      _i1.ColumnValue(
        table.layerId,
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

class MapZoneTable extends _i1.Table<_i1.UuidValue> {
  MapZoneTable({super.tableRelation}) : super(tableName: 'map_zone') {
    updateTable = MapZoneUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    type = _i1.ColumnString(
      'type',
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
    borderPattern = _i1.ColumnString(
      'borderPattern',
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
    geometryJson = _i1.ColumnString(
      'geometryJson',
      this,
    );
    layerId = _i1.ColumnUuid(
      'layerId',
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

  late final MapZoneUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString type;

  late final _i1.ColumnString color;

  late final _i1.ColumnString borderColor;

  late final _i1.ColumnString borderPattern;

  late final _i1.ColumnString fillColor;

  late final _i1.ColumnBool visible;

  late final _i1.ColumnString geometryJson;

  late final _i1.ColumnUuid layerId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    type,
    color,
    borderColor,
    borderPattern,
    fillColor,
    visible,
    geometryJson,
    layerId,
    createdAt,
    updatedAt,
  ];
}

class MapZoneInclude extends _i1.IncludeObject {
  MapZoneInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapZone.t;
}

class MapZoneIncludeList extends _i1.IncludeList {
  MapZoneIncludeList._({
    _i1.WhereExpressionBuilder<MapZoneTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MapZone.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapZone.t;
}

class MapZoneRepository {
  const MapZoneRepository._();

  /// Returns a list of [MapZone]s matching the given query parameters.
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
  Future<List<MapZone>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapZoneTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapZoneTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapZoneTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MapZone>(
      where: where?.call(MapZone.t),
      orderBy: orderBy?.call(MapZone.t),
      orderByList: orderByList?.call(MapZone.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MapZone] matching the given query parameters.
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
  Future<MapZone?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapZoneTable>? where,
    int? offset,
    _i1.OrderByBuilder<MapZoneTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapZoneTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MapZone>(
      where: where?.call(MapZone.t),
      orderBy: orderBy?.call(MapZone.t),
      orderByList: orderByList?.call(MapZone.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MapZone] by its [id] or null if no such row exists.
  Future<MapZone?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MapZone>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MapZone]s in the list and returns the inserted rows.
  ///
  /// The returned [MapZone]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MapZone>> insert(
    _i1.DatabaseSession session,
    List<MapZone> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MapZone>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MapZone] and returns the inserted row.
  ///
  /// The returned [MapZone] will have its `id` field set.
  Future<MapZone> insertRow(
    _i1.DatabaseSession session,
    MapZone row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MapZone>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MapZone]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MapZone>> update(
    _i1.DatabaseSession session,
    List<MapZone> rows, {
    _i1.ColumnSelections<MapZoneTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MapZone>(
      rows,
      columns: columns?.call(MapZone.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapZone]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MapZone> updateRow(
    _i1.DatabaseSession session,
    MapZone row, {
    _i1.ColumnSelections<MapZoneTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MapZone>(
      row,
      columns: columns?.call(MapZone.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapZone] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MapZone?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MapZoneUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MapZone>(
      id,
      columnValues: columnValues(MapZone.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MapZone]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MapZone>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MapZoneUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MapZoneTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapZoneTable>? orderBy,
    _i1.OrderByListBuilder<MapZoneTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MapZone>(
      columnValues: columnValues(MapZone.t.updateTable),
      where: where(MapZone.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapZone.t),
      orderByList: orderByList?.call(MapZone.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MapZone]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MapZone>> delete(
    _i1.DatabaseSession session,
    List<MapZone> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MapZone>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MapZone].
  Future<MapZone> deleteRow(
    _i1.DatabaseSession session,
    MapZone row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MapZone>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MapZone>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapZoneTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MapZone>(
      where: where(MapZone.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapZoneTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MapZone>(
      where: where?.call(MapZone.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MapZone] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapZoneTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MapZone>(
      where: where(MapZone.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
