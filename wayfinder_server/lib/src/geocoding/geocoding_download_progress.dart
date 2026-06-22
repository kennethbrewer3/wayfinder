import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';

/// Where an import is in its lifecycle for progress weighting.
enum GeocodingImportProgressPhase {
  streaming,
  finalizing,
  committing,
}

/// Tracks byte progress while streaming a remote geocoding dataset and emits
/// periodic logs plus status updates so long downloads do not appear stuck.
class GeocodingDownloadProgress {
  GeocodingDownloadProgress({
    required this.serverpod,
    required this.logLabel,
    required this.totalBytes,
    required this.updateStatus,
  });

  final Serverpod serverpod;
  final String logLabel;
  final int totalBytes;
  final Future<void> Function({
    required String importStatus,
    required int importedRowCount,
    required double importProgress,
  }) updateStatus;

  /// Compressed bytes read from the HTTP response (matches [totalBytes]).
  int processedBytes = 0;
  int processedLines = 0;
  int importedRows = 0;
  int _lastLoggedBytes = 0;
  DateTime _lastLoggedAt = DateTime.now();
  DateTime _lastProgressAt = DateTime.now();

  static const _logByteInterval = 50 * 1024 * 1024;
  static const _logTimeInterval = Duration(seconds: 30);

  void addStreamBytes(int byteCount) {
    processedBytes += byteCount;
  }

  void addProcessedLine() {
    processedLines++;
  }

  Future<void> maybeReport({
    required String importStatus,
    required String phase,
    GeocodingImportProgressPhase progressPhase =
        GeocodingImportProgressPhase.streaming,
  }) async {
    final now = DateTime.now();
    final bytesSinceLog = processedBytes - _lastLoggedBytes;
    final shouldLog = bytesSinceLog >= _logByteInterval ||
        now.difference(_lastLoggedAt) >= _logTimeInterval;
    final shouldUpdateProgress =
        shouldLog || now.difference(_lastProgressAt) >= _logTimeInterval;

    if (!shouldLog && !shouldUpdateProgress) {
      return;
    }

    final progress = computeProgress(phase: progressPhase);
    if (shouldLog) {
      WfLog.info(
        null,
        'geocoding',
        '⬇️ $logLabel $phase '
        'processed=${formatBytes(processedBytes)}/'
        '${totalBytes > 0 ? formatBytes(totalBytes) : 'unknown size'} '
        'lines=$processedLines '
        'progress=${(progress * 100).toStringAsFixed(1)}% '
        'importedRows=$importedRows',
      );
      _lastLoggedBytes = processedBytes;
      _lastLoggedAt = now;
    }

    if (shouldUpdateProgress) {
      await updateStatus(
        importStatus: importStatus,
        importedRowCount: importedRows,
        importProgress: progress,
      );
      _lastProgressAt = now;
    }
  }

  double computeProgress({
    GeocodingImportProgressPhase phase = GeocodingImportProgressPhase.streaming,
  }) {
    return switch (phase) {
      GeocodingImportProgressPhase.streaming => _streamingProgress(),
      GeocodingImportProgressPhase.finalizing => 0.92,
      GeocodingImportProgressPhase.committing => 0.97,
    };
  }

  double _streamingProgress() {
    if (totalBytes > 0) {
      final streamRatio = (processedBytes / totalBytes).clamp(0.0, 1.0);
      // Reserve headroom for final batch flush and DB commit.
      return (streamRatio * 0.88).clamp(0.0, 0.88);
    }

    if (importedRows > 0) {
      // Unknown Content-Length — grow slowly from row volume so the bar still moves.
      final rowProgress = 1 - (1 / (1 + importedRows / 250000));
      return (rowProgress * 0.85).clamp(0.0, 0.85);
    }

    if (processedBytes > 0) {
      return 0.02;
    }

    return 0;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KiB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GiB';
  }
}
