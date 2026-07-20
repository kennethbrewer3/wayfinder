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
import '../tides/tide_station_info.dart' as _i2;
import '../tides/tide_sample.dart' as _i3;
import '../tides/tide_extreme.dart' as _i4;
import 'package:wayfinder_server/src/generated/protocol.dart' as _i5;

abstract class TideQueryResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TideQueryResult._({
    required this.station,
    required this.datum,
    required this.units,
    required this.samples,
    required this.extremes,
    required this.approximate,
    this.message,
  });

  factory TideQueryResult({
    required _i2.TideStationInfo station,
    required String datum,
    required String units,
    required List<_i3.TideSample> samples,
    required List<_i4.TideExtreme> extremes,
    required bool approximate,
    String? message,
  }) = _TideQueryResultImpl;

  factory TideQueryResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return TideQueryResult(
      station: _i5.Protocol().deserialize<_i2.TideStationInfo>(
        jsonSerialization['station'],
      ),
      datum: jsonSerialization['datum'] as String,
      units: jsonSerialization['units'] as String,
      samples: _i5.Protocol().deserialize<List<_i3.TideSample>>(
        jsonSerialization['samples'],
      ),
      extremes: _i5.Protocol().deserialize<List<_i4.TideExtreme>>(
        jsonSerialization['extremes'],
      ),
      approximate: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['approximate'],
      ),
      message: jsonSerialization['message'] as String?,
    );
  }

  _i2.TideStationInfo station;

  String datum;

  String units;

  List<_i3.TideSample> samples;

  List<_i4.TideExtreme> extremes;

  bool approximate;

  String? message;

  /// Returns a shallow copy of this [TideQueryResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TideQueryResult copyWith({
    _i2.TideStationInfo? station,
    String? datum,
    String? units,
    List<_i3.TideSample>? samples,
    List<_i4.TideExtreme>? extremes,
    bool? approximate,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TideQueryResult',
      'station': station.toJson(),
      'datum': datum,
      'units': units,
      'samples': samples.toJson(valueToJson: (v) => v.toJson()),
      'extremes': extremes.toJson(valueToJson: (v) => v.toJson()),
      'approximate': approximate,
      if (message != null) 'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TideQueryResult',
      'station': station.toJsonForProtocol(),
      'datum': datum,
      'units': units,
      'samples': samples.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'extremes': extremes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'approximate': approximate,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TideQueryResultImpl extends TideQueryResult {
  _TideQueryResultImpl({
    required _i2.TideStationInfo station,
    required String datum,
    required String units,
    required List<_i3.TideSample> samples,
    required List<_i4.TideExtreme> extremes,
    required bool approximate,
    String? message,
  }) : super._(
         station: station,
         datum: datum,
         units: units,
         samples: samples,
         extremes: extremes,
         approximate: approximate,
         message: message,
       );

  /// Returns a shallow copy of this [TideQueryResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TideQueryResult copyWith({
    _i2.TideStationInfo? station,
    String? datum,
    String? units,
    List<_i3.TideSample>? samples,
    List<_i4.TideExtreme>? extremes,
    bool? approximate,
    Object? message = _Undefined,
  }) {
    return TideQueryResult(
      station: station ?? this.station.copyWith(),
      datum: datum ?? this.datum,
      units: units ?? this.units,
      samples: samples ?? this.samples.map((e0) => e0.copyWith()).toList(),
      extremes: extremes ?? this.extremes.map((e0) => e0.copyWith()).toList(),
      approximate: approximate ?? this.approximate,
      message: message is String? ? message : this.message,
    );
  }
}
