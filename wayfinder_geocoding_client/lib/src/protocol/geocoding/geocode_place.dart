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

abstract class GeocodePlace implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
