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

abstract class GeocodeContribution implements _i1.SerializableModel {
  GeocodeContribution._({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.countryCode,
    required this.contentKey,
    bool? importedFromCrowd,
    required this.createdAt,
    required this.updatedAt,
  }) : importedFromCrowd = importedFromCrowd ?? false;

  factory GeocodeContribution({
    int? id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? countryCode,
    required String contentKey,
    bool? importedFromCrowd,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GeocodeContributionImpl;

  factory GeocodeContribution.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodeContribution(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      notes: jsonSerialization['notes'] as String?,
      countryCode: jsonSerialization['countryCode'] as String?,
      contentKey: jsonSerialization['contentKey'] as String,
      importedFromCrowd: jsonSerialization['importedFromCrowd'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['importedFromCrowd'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  double latitude;

  double longitude;

  String? notes;

  String? countryCode;

  String contentKey;

  bool importedFromCrowd;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [GeocodeContribution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodeContribution copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? notes,
    String? countryCode,
    String? contentKey,
    bool? importedFromCrowd,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodeContribution',
      if (id != null) 'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      if (countryCode != null) 'countryCode': countryCode,
      'contentKey': contentKey,
      'importedFromCrowd': importedFromCrowd,
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

class _GeocodeContributionImpl extends GeocodeContribution {
  _GeocodeContributionImpl({
    int? id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? countryCode,
    required String contentKey,
    bool? importedFromCrowd,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         latitude: latitude,
         longitude: longitude,
         notes: notes,
         countryCode: countryCode,
         contentKey: contentKey,
         importedFromCrowd: importedFromCrowd,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [GeocodeContribution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodeContribution copyWith({
    Object? id = _Undefined,
    String? name,
    double? latitude,
    double? longitude,
    Object? notes = _Undefined,
    Object? countryCode = _Undefined,
    String? contentKey,
    bool? importedFromCrowd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeocodeContribution(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes is String? ? notes : this.notes,
      countryCode: countryCode is String? ? countryCode : this.countryCode,
      contentKey: contentKey ?? this.contentKey,
      importedFromCrowd: importedFromCrowd ?? this.importedFromCrowd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
