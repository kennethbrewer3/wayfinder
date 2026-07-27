/// Import/build status reported by GET /api/routing/status.
enum RoutingImportStatus {
  idle,
  downloading,
  building,
  ready,
  failed,
  cancelled,
  unknown;

  static RoutingImportStatus fromWire(String? value) {
    return switch (value) {
      'idle' => RoutingImportStatus.idle,
      'downloading' => RoutingImportStatus.downloading,
      'building' => RoutingImportStatus.building,
      'ready' => RoutingImportStatus.ready,
      'failed' => RoutingImportStatus.failed,
      'cancelled' => RoutingImportStatus.cancelled,
      _ => RoutingImportStatus.unknown,
    };
  }
}

/// Snapshot of the routing server's import/build pipeline and reachability.
class RoutingStatus {
  const RoutingStatus({
    required this.status,
    required this.progress,
    required this.ready,
    required this.graphhopperUp,
    required this.importInProgress,
    this.message,
    this.sourceUrl,
    this.error,
  });

  final RoutingImportStatus status;
  final double progress;
  final bool ready;
  final bool graphhopperUp;
  final bool importInProgress;
  final String? message;
  final String? sourceUrl;
  final String? error;

  static const unconfigured = RoutingStatus(
    status: RoutingImportStatus.idle,
    progress: 0,
    ready: false,
    graphhopperUp: false,
    importInProgress: false,
  );

  factory RoutingStatus.fromJson(Map<String, dynamic> json) {
    return RoutingStatus(
      status: RoutingImportStatus.fromWire(json['status'] as String?),
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      ready: json['ready'] as bool? ?? false,
      graphhopperUp: json['graphhopperUp'] as bool? ?? false,
      importInProgress: json['importInProgress'] as bool? ?? false,
      message: json['message'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// A selectable pre-configured OSM extract from GET /api/routing/regions.
class RoutingRegion {
  const RoutingRegion({
    required this.id,
    required this.name,
    this.sourceUrl,
    this.description,
  });

  final String id;
  final String name;
  final String? sourceUrl;
  final String? description;

  factory RoutingRegion.fromJson(Map<String, dynamic> json) {
    return RoutingRegion(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}

class RoutingPoint {
  const RoutingPoint({required this.lat, required this.lon});

  final double lat;
  final double lon;

  factory RoutingPoint.fromJson(Map<String, dynamic> json) {
    return RoutingPoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};
}

/// One turn-by-turn step from GraphHopper, with its span over `points`.
class RoutingInstruction {
  const RoutingInstruction({
    required this.text,
    required this.distanceMeters,
    required this.timeMs,
    this.streetName,
    this.sign,
    this.interval,
  });

  final String text;
  final String? streetName;
  final double distanceMeters;
  final int timeMs;
  final int? sign;

  /// `[startPointIndex, endPointIndex]` into the route's `points` array.
  final List<int>? interval;

  factory RoutingInstruction.fromJson(Map<String, dynamic> json) {
    final rawInterval = json['interval'];
    return RoutingInstruction(
      text: json['text'] as String? ?? '',
      streetName: json['streetName'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      timeMs: (json['timeMs'] as num?)?.toInt() ?? 0,
      sign: (json['sign'] as num?)?.toInt(),
      interval: rawInterval is List
          ? [for (final value in rawInterval) (value as num).toInt()]
          : null,
    );
  }
}

class RoutingResult {
  const RoutingResult({
    required this.distanceMeters,
    required this.timeMs,
    required this.points,
    required this.instructions,
  });

  final double distanceMeters;
  final int timeMs;
  final List<RoutingPoint> points;
  final List<RoutingInstruction> instructions;

  factory RoutingResult.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    final rawInstructions = json['instructions'];
    return RoutingResult(
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      timeMs: (json['timeMs'] as num?)?.toInt() ?? 0,
      points: rawPoints is List
          ? [
              for (final item in rawPoints)
                if (item is Map<String, dynamic>) RoutingPoint.fromJson(item),
            ]
          : const [],
      instructions: rawInstructions is List
          ? [
              for (final item in rawInstructions)
                if (item is Map<String, dynamic>)
                  RoutingInstruction.fromJson(item),
            ]
          : const [],
    );
  }
}

/// Travel profile sent to POST /api/routing/route.
enum RoutingProfile {
  foot('foot'),
  bike('bike'),
  car('car');

  const RoutingProfile(this.apiValue);

  final String apiValue;
}
