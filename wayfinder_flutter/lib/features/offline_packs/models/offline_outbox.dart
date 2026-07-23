import 'package:wayfinder_client/wayfinder_client.dart';

enum OfflineOutboxOpType {
  createMarker,
  updateMarker,
  createWatchLogEntry,
  upsertTrackZone,
}

/// Queued mutation to flush when the server returns.
class OfflineOutboxOp {
  const OfflineOutboxOp({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final OfflineOutboxOpType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OfflineOutboxOp.fromJson(Map<String, dynamic> json) {
    return OfflineOutboxOp(
      id: json['id'] as String,
      type: OfflineOutboxOpType.values.byName(json['type'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static OfflineOutboxOp createMarker(MapMarker marker) {
    return OfflineOutboxOp(
      id: const Uuid().v4obj().uuid,
      type: OfflineOutboxOpType.createMarker,
      payload: marker.toJson(),
      createdAt: DateTime.now().toUtc(),
    );
  }

  static OfflineOutboxOp updateMarker(MapMarker marker) {
    return OfflineOutboxOp(
      id: const Uuid().v4obj().uuid,
      type: OfflineOutboxOpType.updateMarker,
      payload: marker.toJson(),
      createdAt: DateTime.now().toUtc(),
    );
  }

  static OfflineOutboxOp createWatchLogEntry(WatchLogEntry entry) {
    return OfflineOutboxOp(
      id: const Uuid().v4obj().uuid,
      type: OfflineOutboxOpType.createWatchLogEntry,
      payload: entry.toJson(),
      createdAt: DateTime.now().toUtc(),
    );
  }

  static OfflineOutboxOp upsertTrackZone(MapZone zone) {
    return OfflineOutboxOp(
      id: const Uuid().v4obj().uuid,
      type: OfflineOutboxOpType.upsertTrackZone,
      payload: zone.toJson(),
      createdAt: DateTime.now().toUtc(),
    );
  }
}
