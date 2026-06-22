import 'dart:io';

import '../core/wayfinder_log.dart';
import 'geocoding_download_progress.dart';

/// Downloads remote geocoding datasets over HTTP(S).
abstract final class GeocodingRemoteFetch {
  static const _userAgent = 'Wayfinder/1.0 (geocoding-importer)';

  static Future<T> withDownload<T>(
    String url,
    Future<T> Function(HttpClientResponse response) process, {
    void Function(HttpClient client)? onClientCreated,
    String logLabel = 'dataset',
  }) async {
    final uri = Uri.parse(url);
    WfLog.info(
      null,
      'geocoding',
      '⬇️ Connecting to $logLabel download host=${uri.host} path=${uri.path}',
    );

    final client = HttpClient()
      ..connectionTimeout = const Duration(minutes: 5)
      ..idleTimeout = const Duration(minutes: 10);

    onClientCreated?.call(client);

    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');

      WfLog.info(
        null,
        'geocoding',
        '⬇️ $logLabel HTTP request sent, waiting for response…',
      );

      final response = await request.close();
      final contentLength = response.contentLength;
      final contentEncoding = response.headers.value(HttpHeaders.contentEncodingHeader);
      WfLog.info(
        null,
        'geocoding',
        '⬇️ $logLabel HTTP ${response.statusCode} '
        'contentLength=${contentLength >= 0 ? GeocodingDownloadProgress.formatBytes(contentLength) : 'unknown (chunked)'} '
        'contentEncoding=${contentEncoding ?? 'none'}',
      );

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to fetch geocoding file (HTTP ${response.statusCode}).',
          uri: uri,
        );
      }

      WfLog.info(
        null,
        'geocoding',
        '⬇️ $logLabel download stream open — processing compressed data',
      );

      return await process(response);
    } on HttpException {
      rethrow;
    } catch (error) {
      WfLog.error(
        null,
        'geocoding',
        '⬇️ $logLabel download failed url=$url',
        error: error,
      );
      throw HttpException(
        'Failed to fetch geocoding file: $error',
        uri: uri,
      );
    } finally {
      client.close(force: true);
      WfLog.debug(null, 'geocoding', '⬇️ $logLabel HTTP client closed');
    }
  }
}
