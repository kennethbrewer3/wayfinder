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
import '../comms/comms_plan.dart' as _i2;
import 'package:wayfinder_client/src/protocol/protocol.dart' as _i3;

abstract class CommsPlanChange implements _i1.SerializableModel {
  CommsPlanChange._({
    required this.type,
    this.plan,
    this.planId,
  });

  factory CommsPlanChange({
    required String type,
    _i2.CommsPlan? plan,
    _i1.UuidValue? planId,
  }) = _CommsPlanChangeImpl;

  factory CommsPlanChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return CommsPlanChange(
      type: jsonSerialization['type'] as String,
      plan: jsonSerialization['plan'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.CommsPlan>(
              jsonSerialization['plan'],
            ),
      planId: jsonSerialization['planId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['planId']),
    );
  }

  /// One of: created, updated, deleted, bulk
  String type;

  _i2.CommsPlan? plan;

  _i1.UuidValue? planId;

  /// Returns a shallow copy of this [CommsPlanChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CommsPlanChange copyWith({
    String? type,
    _i2.CommsPlan? plan,
    _i1.UuidValue? planId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CommsPlanChange',
      'type': type,
      if (plan != null) 'plan': plan?.toJson(),
      if (planId != null) 'planId': planId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CommsPlanChangeImpl extends CommsPlanChange {
  _CommsPlanChangeImpl({
    required String type,
    _i2.CommsPlan? plan,
    _i1.UuidValue? planId,
  }) : super._(
         type: type,
         plan: plan,
         planId: planId,
       );

  /// Returns a shallow copy of this [CommsPlanChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CommsPlanChange copyWith({
    String? type,
    Object? plan = _Undefined,
    Object? planId = _Undefined,
  }) {
    return CommsPlanChange(
      type: type ?? this.type,
      plan: plan is _i2.CommsPlan? ? plan : this.plan?.copyWith(),
      planId: planId is _i1.UuidValue? ? planId : this.planId,
    );
  }
}
