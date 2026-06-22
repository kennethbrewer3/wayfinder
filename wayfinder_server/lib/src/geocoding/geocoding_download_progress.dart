import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';

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

  int processedBytes = 0;
  int importedRows = 0;
  int _lastLoggedBytes = 0;
  DateTime _lastLoggedAt = DateTime.now();
  DateTime _lastProgressAt = DateTime.now();

  static const _logByteInterval = 50 * 1024 * 1024;
  static const _logTimeInterval = Duration(seconds: 30);

  void addLineBytes(int lineLength) {
    processedBytes += lineLength + 1;
  }

  Future<void> maybeReport({
    required String importStatus,
    required String phase,
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

    final progress = computeProgress();
    if (shouldLog) {
      WfLog.info(
        null,
        'geocoding',
        '⬇️ $logLabel $phase '
        'processed=${formatBytes(processedBytes)}/'
        '${totalBytes > 0 ? formatBytes(totalBytes) : 'unknown size'} '
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

  double computeProgress() {
    if (totalBytes > 0) {
      return (processedBytes / totalBytes).clamp(0, 0.99);
    }
    if (importedRows <= 0) {
      return 0;
    }
    return 0.5;
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
