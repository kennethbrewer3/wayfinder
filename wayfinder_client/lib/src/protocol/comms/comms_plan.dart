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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class CommsPlan implements _i1.SerializableModel {
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

  /// The id of the object.
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
