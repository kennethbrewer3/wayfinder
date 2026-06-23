import 'dart:async';
import 'dart:io';

import '../core/wayfinder_log.dart';
import 'geocoding_download_progress.dart';

/// Downloads remote geocoding datasets over HTTP(S).
abstract final class GeocodingRemoteFetch {
  static const _userAgent = 'Wayfinder/1.0 (geocoding-importer)';
  static const _maxAttempts = 5;

  static Future<T> withDownload<T>(
    String url,
    Future<T> Function(Stream<List<int>> byteStream, int contentLength) process, {
    void Function(HttpClient client)? onClientCreated,
    void Function(int bytesReceived, int? totalBytes)? onDownloadProgress,
    String logLabel = 'dataset',
  }) async {
    final tempFile = await _downloadToTempFile(
      url,
      logLabel: logLabel,
      onClientCreated: onClientCreated,
      onDownloadProgress: onDownloadProgress,
    );
    try {
      final contentLength = await tempFile.length();
      WfLog.info(
        null,
        'geocoding',
        '⬇️ $logLabel download complete '
        'size=${GeocodingDownloadProgress.formatBytes(contentLength)} — parsing',
      );
      return await process(tempFile.openRead(), contentLength);
    } finally {
      try {
        await tempFile.parent.delete(recursive: true);
      } catch (_) {
        // Best-effort cleanup of temp storage.
      }
    }
  }

  static Future<File> _downloadToTempFile(
    String url, {
    required String logLabel,
    void Function(HttpClient client)? onClientCreated,
    void Function(int bytesReceived, int? totalBytes)? onDownloadProgress,
  }) async {
    final dir = await Directory.systemTemp.createTemp('wayfinder-$logLabel-');
    final file = File('${dir.path}/dataset.gz');

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      HttpClient? client;
      IOSink? sink;
      try {
        final resumeFrom = file.existsSync() ? await file.length() : 0;
        client = _createClient();
        onClientCreated?.call(client);

        final uri = Uri.parse(url);
        WfLog.info(
          null,
          'geocoding',
          '⬇️ Connecting to $logLabel download host=${uri.host} '
          'attempt=$attempt/$_maxAttempts '
          'resumeFrom=${GeocodingDownloadProgress.formatBytes(resumeFrom)}',
        );

        final request = await client.getUrl(uri);
        request.followRedirects = true;
        request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
        request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        if (resumeFrom > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$resumeFrom-');
        }

        final response = await request.close();
        if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
          await file.writeAsBytes([]);
          throw HttpException(
            'Download range no longer valid; restarting from beginning.',
            uri: uri,
          );
        }

        if (response.statusCode != HttpStatus.ok &&
            response.statusCode != HttpStatus.partialContent) {
          throw HttpException(
            'Failed to fetch geocoding file (HTTP ${response.statusCode}).',
            uri: uri,
          );
        }

        final append = response.statusCode == HttpStatus.partialContent;
        if (!append && resumeFrom > 0) {
          await file.writeAsBytes([]);
        }

        final totalBytes = _totalBytes(response, resumeFrom: append ? resumeFrom : 0);
        WfLog.info(
          null,
          'geocoding',
          '⬇️ $logLabel HTTP ${response.statusCode} '
          'totalBytes=${totalBytes == null ? 'unknown' : GeocodingDownloadProgress.formatBytes(totalBytes)}',
        );

        sink = file.openWrite(mode: append ? FileMode.append : FileMode.write);
        var received = append ? resumeFrom : 0;
        onDownloadProgress?.call(received, totalBytes);

        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          onDownloadProgress?.call(received, totalBytes);
        }
        await sink.close();
        sink = null;

        if (totalBytes != null && received < totalBytes) {
          throw HttpException(
            'Connection closed before download completed '
            '(${GeocodingDownloadProgress.formatBytes(received)}/'
            '${GeocodingDownloadProgress.formatBytes(totalBytes)}).',
            uri: uri,
          );
        }

        return file;
      } catch (error, stackTrace) {
        await sink?.close();
        if (attempt >= _maxAttempts || !_isRetryable(error)) {
          WfLog.error(
            null,
            'geocoding',
            '⬇️ $logLabel download failed url=$url',
            error: error,
            stackTrace: stackTrace,
          );
          rethrow;
        }

        WfLog.warn(
          null,
          'geocoding',
          '⬇️ $logLabel download interrupted on attempt $attempt/$_maxAttempts; '
          'retrying in ${attempt * 5}s ($error)',
        );
        await Future<void>.delayed(Duration(seconds: attempt * 5));
      } finally {
        client?.close(force: true);
      }
    }

    throw StateError('Failed to download $logLabel after $_maxAttempts attempts.');
  }

  static HttpClient _createClient() {
    return HttpClient()
      ..connectionTimeout = const Duration(minutes: 5)
      ..idleTimeout = const Duration(minutes: 30);
  }

  static int? _totalBytes(
    HttpClientResponse response, {
    required int resumeFrom,
  }) {
    final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
    if (contentRange != null) {
      final slash = contentRange.lastIndexOf('/');
      if (slash >= 0) {
        final total = int.tryParse(contentRange.substring(slash + 1));
        if (total != null && total > 0) {
          return total;
        }
      }
    }

    final contentLength = response.contentLength;
    if (contentLength < 0) {
      return null;
    }
    return resumeFrom + contentLength;
  }

  static bool _isRetryable(Object error) {
    if (error is SocketException) {
      return true;
    }
    if (error is TimeoutException) {
      return true;
    }
    if (error is HttpException) {
      final message = error.message.toLowerCase();
      return message.contains('connection closed') ||
          message.contains('connection reset') ||
          message.contains('broken pipe') ||
          message.contains('timed out') ||
          message.contains('before download completed');
    }
    return false;
  }
}
