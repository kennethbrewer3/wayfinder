import 'dart:convert';
import 'dart:io';

import 'package:wayfinder_routing_server/src/config.dart';

/// Persisted routing appliance status for UI polling.
enum RoutingStatus {
  idle,
  downloading,
  building,
  ready,
  failed,
  cancelled;

  static RoutingStatus fromString(String value) {
    return RoutingStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => RoutingStatus.idle,
    );
  }
}

class RoutingStatusSnapshot {
  RoutingStatusSnapshot({
    required this.status,
    required this.message,
    this.sourceUrl,
    this.progress,
    this.distanceMeters,
    this.ready = false,
    this.error,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc();

  RoutingStatus status;
  String message;
  String? sourceUrl;
  double? progress;
  double? distanceMeters;
  bool ready;
  String? error;
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'message': message,
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
    if (progress != null) 'progress': progress,
    if (distanceMeters != null) 'distanceMeters': distanceMeters,
    'ready': ready,
    if (error != null) 'error': error,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory RoutingStatusSnapshot.fromJson(Map<String, dynamic> json) {
    return RoutingStatusSnapshot(
      status: RoutingStatus.fromString(json['status'] as String? ?? 'idle'),
      message: json['message'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      ready: json['ready'] as bool? ?? false,
      error: json['error'] as String?,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  RoutingStatusSnapshot copy() => RoutingStatusSnapshot(
    status: status,
    message: message,
    sourceUrl: sourceUrl,
    progress: progress,
    distanceMeters: distanceMeters,
    ready: ready,
    error: error,
    updatedAt: updatedAt,
  );
}

class StatusStore {
  StatusStore(this.config);

  final RoutingConfig config;
  RoutingStatusSnapshot _current = RoutingStatusSnapshot(
    status: RoutingStatus.idle,
    message: 'No OSM data imported yet.',
    ready: false,
  );

  RoutingStatusSnapshot get current => _current.copy();

  Future<void> load() async {
    final file = File(config.statusFilePath);
    if (!await file.exists()) {
      return;
    }
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _current = RoutingStatusSnapshot.fromJson(json);
    } on Object {
      // Keep default if status file is corrupt.
    }
  }

  Future<void> update(RoutingStatusSnapshot snapshot) async {
    _current = snapshot.copy();
    await _persist();
  }

  Future<void> _persist() async {
    final dir = Directory(config.dataDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(config.statusFilePath);
    await file.writeAsString(jsonEncode(_current.toJson()));
  }
}
