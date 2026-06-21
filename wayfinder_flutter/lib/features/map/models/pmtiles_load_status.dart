class PmtilesLoadStatus {
  const PmtilesLoadStatus({
    required this.isReady,
    required this.isLoading,
    this.enabledCount = 0,
    this.loadedCount = 0,
    this.activeLayerName,
    this.loadingLayerName,
    this.statusMessage,
    this.failureMessage,
  });

  final bool isReady;
  final bool isLoading;
  final int enabledCount;
  final int loadedCount;
  final String? activeLayerName;
  final String? loadingLayerName;
  final String? statusMessage;
  final String? failureMessage;

  static const initial = PmtilesLoadStatus(
    isReady: false,
    isLoading: true,
    statusMessage: 'Checking map tiles…',
  );

  static const noLayers = PmtilesLoadStatus(
    isReady: false,
    isLoading: false,
    statusMessage: 'No map tiles are visible. Enable a layer in Settings.',
  );

  PmtilesLoadStatus copyWith({
    bool? isReady,
    bool? isLoading,
    int? enabledCount,
    int? loadedCount,
    String? activeLayerName,
    String? loadingLayerName,
    String? statusMessage,
    String? failureMessage,
  }) {
    return PmtilesLoadStatus(
      isReady: isReady ?? this.isReady,
      isLoading: isLoading ?? this.isLoading,
      enabledCount: enabledCount ?? this.enabledCount,
      loadedCount: loadedCount ?? this.loadedCount,
      activeLayerName: activeLayerName ?? this.activeLayerName,
      loadingLayerName: loadingLayerName ?? this.loadingLayerName,
      statusMessage: statusMessage ?? this.statusMessage,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }
}
