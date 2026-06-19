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

abstract class GeocodePlace
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  GeocodePlace._({
    this.id,
    required this.name,
    this.displayName,
    required this.latitude,
    required this.longitude,
    required this.placeRank,
    required this.importance,
    this.countryCode,
    this.featureClass,
    this.featureType,
  });

  factory GeocodePlace({
    int? id,
    required String name,
    String? displayName,
    required double latitude,
    required double longitude,
    required int placeRank,
    required double importance,
    String? countryCode,
    String? featureClass,
    String? featureType,
  }) = _GeocodePlaceImpl;

  factory GeocodePlace.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodePlace(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      displayName: jsonSerialization['displayName'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      placeRank: jsonSerialization['placeRank'] as int,
      importance: (jsonSerialization['importance'] as num).toDouble(),
      countryCode: jsonSerialization['countryCode'] as String?,
      featureClass: jsonSerialization['featureClass'] as String?,
      featureType: jsonSerialization['featureType'] as String?,
    );
  }

  static final t = GeocodePlaceTable();

  static const db = GeocodePlaceRepository._();

  @override
  int? id;

  String name;

  String? displayName;

  double latitude;

  double longitude;

  int placeRank;

  double importance;

  String? countryCode;

  String? featureClass;

  String? featureType;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GeocodePlace]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodePlace copyWith({
    int? id,
    String? name,
    String? displayName,
    double? latitude,
    double? longitude,
    int? placeRank,
    double? importance,
    String? countryCode,
    String? featureClass,
    String? featureType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodePlace',
      if (id != null) 'id': id,
      'name': name,
      if (displayName != null) 'displayName': displayName,
      'latitude': latitude,
      'longitude': longitude,
      'placeRank': placeRank,
      'importance': importance,
      if (countryCode != null) 'countryCode': countryCode,
      if (featureClass != null) 'featureClass': featureClass,
      if (featureType != null) 'featureType': featureType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeocodePlace',
      if (id != null) 'id': id,
      'name': name,
      if (displayName != null) 'displayName': displayName,
      'latitude': latitude,
      'longitude': longitude,
      'placeRank': placeRank,
      'importance': importance,
      if (countryCode != null) 'countryCode': countryCode,
      if (featureClass != null) 'featureClass': featureClass,
      if (featureType != null) 'featureType': featureType,
    };
  }

  static GeocodePlaceInclude include() {
    return GeocodePlaceInclude._();
  }

  static GeocodePlaceIncludeList includeList({
    _i1.WhereExpressionBuilder<GeocodePlaceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodePlaceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodePlaceTable>? orderByList,
    GeocodePlaceInclude? include,
  }) {
    return GeocodePlaceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodePlace.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GeocodePlace.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodePlaceImpl extends GeocodePlace {
  _GeocodePlaceImpl({
    int? id,
    required String name,
    String? displayName,
    required double latitude,
    required double longitude,
    required int placeRank,
    required double importance,
    String? countryCode,
    String? featureClass,
    String? featureType,
  }) : super._(
         id: id,
         name: name,
         displayName: displayName,
         latitude: latitude,
         longitude: longitude,
         placeRank: placeRank,
         importance: importance,
         countryCode: countryCode,
         featureClass: featureClass,
         featureType: featureType,
       );

  /// Returns a shallow copy of this [GeocodePlace]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodePlace copyWith({
    Object? id = _Undefined,
    String? name,
    Object? displayName = _Undefined,
    double? latitude,
    double? longitude,
    int? placeRank,
    double? importance,
    Object? countryCode = _Undefined,
    Object? featureClass = _Undefined,
    Object? featureType = _Undefined,
  }) {
    return GeocodePlace(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      displayName: displayName is String? ? displayName : this.displayName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeRank: placeRank ?? this.placeRank,
      importance: importance ?? this.importance,
      countryCode: countryCode is String? ? countryCode : this.countryCode,
      featureClass: featureClass is String? ? featureClass : this.featureClass,
      featureType: featureType is String? ? featureType : this.featureType,
    );
  }
}

class GeocodePlaceUpdateTable extends _i1.UpdateTable<GeocodePlaceTable> {
  GeocodePlaceUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> displayName(String? value) => _i1.ColumnValue(
    table.displayName,
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

  _i1.ColumnValue<int, int> placeRank(int value) => _i1.ColumnValue(
    table.placeRank,
    value,
  );

  _i1.ColumnValue<double, double> importance(double value) => _i1.ColumnValue(
    table.importance,
    value,
  );

  _i1.ColumnValue<String, String> countryCode(String? value) => _i1.ColumnValue(
    table.countryCode,
    value,
  );

  _i1.ColumnValue<String, String> featureClass(String? value) =>
      _i1.ColumnValue(
        table.featureClass,
        value,
      );

  _i1.ColumnValue<String, String> featureType(String? value) => _i1.ColumnValue(
    table.featureType,
    value,
  );
}

class GeocodePlaceTable extends _i1.Table<int?> {
  GeocodePlaceTable({super.tableRelation}) : super(tableName: 'geocode_place') {
    updateTable = GeocodePlaceUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    displayName = _i1.ColumnString(
      'displayName',
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
    placeRank = _i1.ColumnInt(
      'placeRank',
      this,
    );
    importance = _i1.ColumnDouble(
      'importance',
      this,
    );
    countryCode = _i1.ColumnString(
      'countryCode',
      this,
    );
    featureClass = _i1.ColumnString(
      'featureClass',
      this,
    );
    featureType = _i1.ColumnString(
      'featureType',
      this,
    );
  }

  late final GeocodePlaceUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString displayName;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnInt placeRank;

  late final _i1.ColumnDouble importance;

  late final _i1.ColumnString countryCode;

  late final _i1.ColumnString featureClass;

  late final _i1.ColumnString featureType;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    displayName,
    latitude,
    longitude,
    placeRank,
    importance,
    countryCode,
    featureClass,
    featureType,
  ];
}

class GeocodePlaceInclude extends _i1.IncludeObject {
  GeocodePlaceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => GeocodePlace.t;
}

class GeocodePlaceIncludeList extends _i1.IncludeList {
  GeocodePlaceIncludeList._({
    _i1.WhereExpressionBuilder<GeocodePlaceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GeocodePlace.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GeocodePlace.t;
}

class GeocodePlaceRepository {
  const GeocodePlaceRepository._();

  /// Returns a list of [GeocodePlace]s matching the given query parameters.
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
  Future<List<GeocodePlace>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodePlaceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodePlaceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodePlaceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GeocodePlace>(
      where: where?.call(GeocodePlace.t),
      orderBy: orderBy?.call(GeocodePlace.t),
      orderByList: orderByList?.call(GeocodePlace.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GeocodePlace] matching the given query parameters.
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
  Future<GeocodePlace?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodePlaceTable>? where,
    int? offset,
    _i1.OrderByBuilder<GeocodePlaceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodePlaceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GeocodePlace>(
      where: where?.call(GeocodePlace.t),
      orderBy: orderBy?.call(GeocodePlace.t),
      orderByList: orderByList?.call(GeocodePlace.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GeocodePlace] by its [id] or null if no such row exists.
  Future<GeocodePlace?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GeocodePlace>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GeocodePlace]s in the list and returns the inserted rows.
  ///
  /// The returned [GeocodePlace]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<GeocodePlace>> insert(
    _i1.DatabaseSession session,
    List<GeocodePlace> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GeocodePlace>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GeocodePlace] and returns the inserted row.
  ///
  /// The returned [GeocodePlace] will have its `id` field set.
  Future<GeocodePlace> insertRow(
    _i1.DatabaseSession session,
    GeocodePlace row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GeocodePlace>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GeocodePlace]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GeocodePlace>> update(
    _i1.DatabaseSession session,
    List<GeocodePlace> rows, {
    _i1.ColumnSelections<GeocodePlaceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GeocodePlace>(
      rows,
      columns: columns?.call(GeocodePlace.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodePlace]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GeocodePlace> updateRow(
    _i1.DatabaseSession session,
    GeocodePlace row, {
    _i1.ColumnSelections<GeocodePlaceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GeocodePlace>(
      row,
      columns: columns?.call(GeocodePlace.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodePlace] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GeocodePlace?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<GeocodePlaceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GeocodePlace>(
      id,
      columnValues: columnValues(GeocodePlace.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GeocodePlace]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GeocodePlace>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<GeocodePlaceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<GeocodePlaceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodePlaceTable>? orderBy,
    _i1.OrderByListBuilder<GeocodePlaceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GeocodePlace>(
      columnValues: columnValues(GeocodePlace.t.updateTable),
      where: where(GeocodePlace.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodePlace.t),
      orderByList: orderByList?.call(GeocodePlace.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GeocodePlace]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GeocodePlace>> delete(
    _i1.DatabaseSession session,
    List<GeocodePlace> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GeocodePlace>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GeocodePlace].
  Future<GeocodePlace> deleteRow(
    _i1.DatabaseSession session,
    GeocodePlace row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GeocodePlace>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GeocodePlace>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodePlaceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GeocodePlace>(
      where: where(GeocodePlace.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodePlaceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GeocodePlace>(
      where: where?.call(GeocodePlace.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GeocodePlace] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodePlaceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GeocodePlace>(
      where: where(GeocodePlace.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
