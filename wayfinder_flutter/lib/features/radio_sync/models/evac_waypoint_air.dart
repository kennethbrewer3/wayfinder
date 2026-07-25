import 'package:freezed_annotation/freezed_annotation.dart';

part 'evac_waypoint_air.freezed.dart';

/// Compact waypoint carried inside [EvacRouteUpsertEvent] over radio.
@freezed
abstract class EvacWaypointAir with _$EvacWaypointAir {
  const factory EvacWaypointAir({
    /// `marker` | `point` | `control` (see design doc).
    required int kind,
    required int latE7,
    required int lonE7,
    String? markerId,
    String? label,
  }) = _EvacWaypointAir;
}

/// Wire kind codes for [EvacWaypointAir.kind].
abstract final class EvacWaypointAirKind {
  static const int marker = 0;
  static const int point = 1;
  static const int control = 2;
}
