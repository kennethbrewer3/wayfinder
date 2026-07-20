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

abstract class TideSample implements _i1.SerializableModel {
  TideSample._({
    required this.time,
    required this.heightMeters,
  });

  factory TideSample({
    required DateTime time,
    required double heightMeters,
  }) = _TideSampleImpl;

  factory TideSample.fromJson(Map<String, dynamic> jsonSerialization) {
    return TideSample(
      time: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['time']),
      heightMeters: (jsonSerialization['heightMeters'] as num).toDouble(),
    );
  }

  DateTime time;

  double heightMeters;

  /// Returns a shallow copy of this [TideSample]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TideSample copyWith({
    DateTime? time,
    double? heightMeters,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TideSample',
      'time': time.toJson(),
      'heightMeters': heightMeters,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TideSampleImpl extends TideSample {
  _TideSampleImpl({
    required DateTime time,
    required double heightMeters,
  }) : super._(
         time: time,
         heightMeters: heightMeters,
       );

  /// Returns a shallow copy of this [TideSample]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TideSample copyWith({
    DateTime? time,
    double? heightMeters,
  }) {
    return TideSample(
      time: time ?? this.time,
      heightMeters: heightMeters ?? this.heightMeters,
    );
  }
}
