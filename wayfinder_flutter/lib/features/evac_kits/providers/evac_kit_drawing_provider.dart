import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/utils/line_snap.dart';
import '../models/evac_kit_geometry.dart';

class EvacKitDrawingState {
  const EvacKitDrawingState({
    this.active = false,
    this.waypoints = const [],
    this.previewPoint,
    this.existingKitId,
    this.existingKitName,
  });

  final bool active;
  final List<EvacWaypoint> waypoints;
  final LatLng? previewPoint;

  /// When set, finishing adds an alternate route to this kit.
  final UuidValue? existingKitId;
  final String? existingKitName;

  bool get canFinish => active && waypoints.length >= 2;

  bool get addingAlternate => existingKitId != null;

  EvacKitDrawingState copyWith({
    bool? active,
    List<EvacWaypoint>? waypoints,
    LatLng? previewPoint,
    UuidValue? existingKitId,
    String? existingKitName,
    bool clearPreviewPoint = false,
    bool clearExistingKit = false,
  }) {
    return EvacKitDrawingState(
      active: active ?? this.active,
      waypoints: waypoints ?? this.waypoints,
      previewPoint: clearPreviewPoint
          ? null
          : previewPoint ?? this.previewPoint,
      existingKitId: clearExistingKit
          ? null
          : existingKitId ?? this.existingKitId,
      existingKitName: clearExistingKit
          ? null
          : existingKitName ?? this.existingKitName,
    );
  }
}

final evacKitDrawingProvider =
    StateNotifierProvider<EvacKitDrawingNotifier, EvacKitDrawingState>(
      (ref) => EvacKitDrawingNotifier(),
    );

class EvacKitDrawingNotifier extends StateNotifier<EvacKitDrawingState> {
  EvacKitDrawingNotifier() : super(const EvacKitDrawingState());

  void beginNewKit({EvacWaypoint? firstWaypoint}) {
    state = EvacKitDrawingState(
      active: true,
      waypoints: firstWaypoint == null ? const [] : [firstWaypoint],
    );
  }

  void beginAlternate({
    required UuidValue kitId,
    required String kitName,
  }) {
    state = EvacKitDrawingState(
      active: true,
      existingKitId: kitId,
      existingKitName: kitName,
    );
  }

  void addPoint(LatLng point, {String? label}) {
    if (!state.active) {
      return;
    }
    final waypoints = state.waypoints;
    if (waypoints.isNotEmpty &&
        areLinePointsTooClose(waypoints.last.point, point, minMeters: 1)) {
      return;
    }
    state = state.copyWith(
      waypoints: [
        ...waypoints,
        EvacWaypoint(
          kind: EvacWaypointKind.point,
          point: point,
          label: label,
        ),
      ],
      clearPreviewPoint: true,
    );
  }

  void addMarkerWaypoint(MapMarker marker) {
    if (!state.active) {
      return;
    }
    final point = LatLng(marker.latitude, marker.longitude);
    final waypoints = state.waypoints;
    if (waypoints.isNotEmpty &&
        areLinePointsTooClose(waypoints.last.point, point, minMeters: 1)) {
      return;
    }
    // Avoid duplicating the same marker consecutively.
    if (waypoints.isNotEmpty &&
        waypoints.last.markerId == marker.id.toString()) {
      return;
    }
    state = state.copyWith(
      waypoints: [
        ...waypoints,
        EvacWaypoint(
          kind: EvacWaypointKind.marker,
          point: point,
          markerId: marker.id.toString(),
          label: marker.name,
        ),
      ],
      clearPreviewPoint: true,
    );
  }

  void undoLastWaypoint() {
    if (!state.active || state.waypoints.isEmpty) {
      return;
    }
    final next = List<EvacWaypoint>.from(state.waypoints)..removeLast();
    state = state.copyWith(waypoints: next);
  }

  void setPreviewPoint(LatLng point) {
    if (!state.active || state.waypoints.isEmpty) {
      return;
    }
    state = state.copyWith(previewPoint: point);
  }

  void reset() {
    state = const EvacKitDrawingState();
  }
}
