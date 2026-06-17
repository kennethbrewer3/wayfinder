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

abstract class MapMarker
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MapMarker._({
    _i1.UuidValue? id,
    required this.name,
    this.notes,
    required this.latitude,
    required this.longitude,
    double? elevation,
    required this.color,
    required this.icon,
    required this.visible,
    this.layerId,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       elevation = elevation ?? 0.0;

  factory MapMarker({
    _i1.UuidValue? id,
    required String name,
    String? notes,
    required double latitude,
    required double longitude,
    double? elevation,
    required String color,
    required String icon,
    required bool visible,
    _i1.UuidValue? layerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MapMarkerImpl;

  factory MapMarker.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapMarker(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      notes: jsonSerialization['notes'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      elevation: (jsonSerialization['elevation'] as num?)?.toDouble(),
      color: jsonSerialization['color'] as String,
      icon: jsonSerialization['icon'] as String,
      visible: _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
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

  static final t = MapMarkerTable();

  static const db = MapMarkerRepository._();

  @override
  _i1.UuidValue id;

  String name;

  String? notes;

  double latitude;

  double longitude;

  double elevation;

  String color;

  String icon;

  bool visible;

  _i1.UuidValue? layerId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MapMarker]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapMarker copyWith({
    _i1.UuidValue? id,
    String? name,
    String? notes,
    double? latitude,
    double? longitude,
    double? elevation,
    String? color,
    String? icon,
    bool? visible,
    _i1.UuidValue? layerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapMarker',
      'id': id.toJson(),
      'name': name,
      if (notes != null) 'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'color': color,
      'icon': icon,
      'visible': visible,
      if (layerId != null) 'layerId': layerId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MapMarker',
      'id': id.toJson(),
      'name': name,
      if (notes != null) 'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'color': color,
      'icon': icon,
      'visible': visible,
      if (layerId != null) 'layerId': layerId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MapMarkerInclude include() {
    return MapMarkerInclude._();
  }

  static MapMarkerIncludeList includeList({
    _i1.WhereExpressionBuilder<MapMarkerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapMarkerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapMarkerTable>? orderByList,
    MapMarkerInclude? include,
  }) {
    return MapMarkerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapMarker.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MapMarker.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapMarkerImpl extends MapMarker {
  _MapMarkerImpl({
    _i1.UuidValue? id,
    required String name,
    String? notes,
    required double latitude,
    required double longitude,
    double? elevation,
    required String color,
    required String icon,
    required bool visible,
    _i1.UuidValue? layerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         notes: notes,
         latitude: latitude,
         longitude: longitude,
         elevation: elevation,
         color: color,
         icon: icon,
         visible: visible,
         layerId: layerId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MapMarker]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapMarker copyWith({
    _i1.UuidValue? id,
    String? name,
    Object? notes = _Undefined,
    double? latitude,
    double? longitude,
    double? elevation,
    String? color,
    String? icon,
    bool? visible,
    Object? layerId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapMarker(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes is String? ? notes : this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      visible: visible ?? this.visible,
      layerId: layerId is _i1.UuidValue? ? layerId : this.layerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MapMarkerUpdateTable extends _i1.UpdateTable<MapMarkerTable> {
  MapMarkerUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<double, double> latitude(double value) => _i1.ColumnValue(
    table.latitude,
    value,
  );

  _i1.ColumnValue<double, double> longitude(double value) => _i1.ColumnValue(
    table.longitude,
    value,
  );

  _i1.ColumnValue<double, double> elevation(double value) => _i1.ColumnValue(
    table.elevation,
    value,
  );

  _i1.ColumnValue<String, String> color(String value) => _i1.ColumnValue(
    table.color,
    value,
  );

  _i1.ColumnValue<String, String> icon(String value) => _i1.ColumnValue(
    table.icon,
    value,
  );

  _i1.ColumnValue<bool, bool> visible(bool value) => _i1.ColumnValue(
    table.visible,
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

class MapMarkerTable extends _i1.Table<_i1.UuidValue> {
  MapMarkerTable({super.tableRelation}) : super(tableName: 'map_marker') {
    updateTable = MapMarkerUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    latitude = _i1.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _i1.ColumnDouble(
      'longitude',
      this,
    );
    elevation = _i1.ColumnDouble(
      'elevation',
      this,
      hasDefault: true,
    );
    color = _i1.ColumnString(
      'color',
      this,
    );
    icon = _i1.ColumnString(
      'icon',
      this,
    );
    visible = _i1.ColumnBool(
      'visible',
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

  late final MapMarkerUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString notes;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnDouble elevation;

  late final _i1.ColumnString color;

  late final _i1.ColumnString icon;

  late final _i1.ColumnBool visible;

  late final _i1.ColumnUuid layerId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    notes,
    latitude,
    longitude,
    elevation,
    color,
    icon,
    visible,
    layerId,
    createdAt,
    updatedAt,
  ];
}

class MapMarkerInclude extends _i1.IncludeObject {
  MapMarkerInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapMarker.t;
}

class MapMarkerIncludeList extends _i1.IncludeList {
  MapMarkerIncludeList._({
    _i1.WhereExpressionBuilder<MapMarkerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MapMarker.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MapMarker.t;
}

class MapMarkerRepository {
  const MapMarkerRepository._();

  /// Returns a list of [MapMarker]s matching the given query parameters.
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
  Future<List<MapMarker>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapMarkerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapMarkerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapMarkerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MapMarker>(
      where: where?.call(MapMarker.t),
      orderBy: orderBy?.call(MapMarker.t),
      orderByList: orderByList?.call(MapMarker.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MapMarker] matching the given query parameters.
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
  Future<MapMarker?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapMarkerTable>? where,
    int? offset,
    _i1.OrderByBuilder<MapMarkerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MapMarkerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MapMarker>(
      where: where?.call(MapMarker.t),
      orderBy: orderBy?.call(MapMarker.t),
      orderByList: orderByList?.call(MapMarker.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MapMarker] by its [id] or null if no such row exists.
  Future<MapMarker?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MapMarker>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MapMarker]s in the list and returns the inserted rows.
  ///
  /// The returned [MapMarker]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MapMarker>> insert(
    _i1.DatabaseSession session,
    List<MapMarker> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MapMarker>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MapMarker] and returns the inserted row.
  ///
  /// The returned [MapMarker] will have its `id` field set.
  Future<MapMarker> insertRow(
    _i1.DatabaseSession session,
    MapMarker row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MapMarker>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MapMarker]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MapMarker>> update(
    _i1.DatabaseSession session,
    List<MapMarker> rows, {
    _i1.ColumnSelections<MapMarkerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MapMarker>(
      rows,
      columns: columns?.call(MapMarker.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapMarker]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MapMarker> updateRow(
    _i1.DatabaseSession session,
    MapMarker row, {
    _i1.ColumnSelections<MapMarkerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MapMarker>(
      row,
      columns: columns?.call(MapMarker.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MapMarker] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MapMarker?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MapMarkerUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MapMarker>(
      id,
      columnValues: columnValues(MapMarker.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MapMarker]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MapMarker>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MapMarkerUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MapMarkerTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MapMarkerTable>? orderBy,
    _i1.OrderByListBuilder<MapMarkerTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MapMarker>(
      columnValues: columnValues(MapMarker.t.updateTable),
      where: where(MapMarker.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MapMarker.t),
      orderByList: orderByList?.call(MapMarker.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MapMarker]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MapMarker>> delete(
    _i1.DatabaseSession session,
    List<MapMarker> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MapMarker>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MapMarker].
  Future<MapMarker> deleteRow(
    _i1.DatabaseSession session,
    MapMarker row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MapMarker>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MapMarker>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapMarkerTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MapMarker>(
      where: where(MapMarker.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MapMarkerTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MapMarker>(
      where: where?.call(MapMarker.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MapMarker] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MapMarkerTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MapMarker>(
      where: where(MapMarker.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
