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

abstract class GeocodeHousenumber implements _i1.SerializableModel {
  GeocodeHousenumber._({
    this.id,
    required this.streetId,
    required this.street,
    required this.housenumber,
    required this.latitude,
    required this.longitude,
  });

  factory GeocodeHousenumber({
    int? id,
    required String streetId,
    required String street,
    required String housenumber,
    required double latitude,
    required double longitude,
  }) = _GeocodeHousenumberImpl;

  factory GeocodeHousenumber.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodeHousenumber(
      id: jsonSerialization['id'] as int?,
      streetId: jsonSerialization['streetId'] as String,
      street: jsonSerialization['street'] as String,
      housenumber: jsonSerialization['housenumber'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String streetId;

  String street;

  String housenumber;

  double latitude;

  double longitude;

  /// Returns a shallow copy of this [GeocodeHousenumber]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodeHousenumber copyWith({
    int? id,
    String? streetId,
    String? street,
    String? housenumber,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodeHousenumber',
      if (id != null) 'id': id,
      'streetId': streetId,
      'street': street,
      'housenumber': housenumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodeHousenumberImpl extends GeocodeHousenumber {
  _GeocodeHousenumberImpl({
    int? id,
    required String streetId,
    required String street,
    required String housenumber,
    required double latitude,
    required double longitude,
  }) : super._(
         id: id,
         streetId: streetId,
         street: street,
         housenumber: housenumber,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [GeocodeHousenumber]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodeHousenumber copyWith({
    Object? id = _Undefined,
    String? streetId,
    String? street,
    String? housenumber,
    double? latitude,
    double? longitude,
  }) {
    return GeocodeHousenumber(
      id: id is int? ? id : this.id,
      streetId: streetId ?? this.streetId,
      street: street ?? this.street,
      housenumber: housenumber ?? this.housenumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
