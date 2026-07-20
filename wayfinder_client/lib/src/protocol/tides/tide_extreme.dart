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

abstract class TideExtreme implements _i1.SerializableModel {
  TideExtreme._({
    required this.time,
    required this.heightMeters,
    required this.type,
  });

  factory TideExtreme({
    required DateTime time,
    required double heightMeters,
    required String type,
  }) = _TideExtremeImpl;

  factory TideExtreme.fromJson(Map<String, dynamic> jsonSerialization) {
    return TideExtreme(
      time: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['time']),
      heightMeters: (jsonSerialization['heightMeters'] as num).toDouble(),
      type: jsonSerialization['type'] as String,
    );
  }

  DateTime time;

  double heightMeters;

  /// One of: high, low
  String type;

  /// Returns a shallow copy of this [TideExtreme]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TideExtreme copyWith({
    DateTime? time,
    double? heightMeters,
    String? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TideExtreme',
      'time': time.toJson(),
      'heightMeters': heightMeters,
      'type': type,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TideExtremeImpl extends TideExtreme {
  _TideExtremeImpl({
    required DateTime time,
    required double heightMeters,
    required String type,
  }) : super._(
         time: time,
         heightMeters: heightMeters,
         type: type,
       );

  /// Returns a shallow copy of this [TideExtreme]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TideExtreme copyWith({
    DateTime? time,
    double? heightMeters,
    String? type,
  }) {
    return TideExtreme(
      time: time ?? this.time,
      heightMeters: heightMeters ?? this.heightMeters,
      type: type ?? this.type,
    );
  }
}
