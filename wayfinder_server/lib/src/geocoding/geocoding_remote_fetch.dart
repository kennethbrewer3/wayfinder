import 'dart:io';

/// Downloads remote geocoding datasets over HTTP(S).
abstract final class GeocodingRemoteFetch {
  static const _userAgent = 'Wayfinder/1.0 (geocoding-importer)';

  static Future<T> withDownload<T>(
    String url,
    Future<T> Function(HttpClientResponse response) process,
  ) async {
    final uri = Uri.parse(url);
    final client = HttpClient()
      ..connectionTimeout = const Duration(minutes: 5)
      ..idleTimeout = const Duration(minutes: 10);

    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to fetch geocoding file (HTTP ${response.statusCode}).',
          uri: uri,
        );
      }

      return await process(response);
    } on HttpException {
      rethrow;
    } catch (error) {
      throw HttpException(
        'Failed to fetch geocoding file: $error',
        uri: uri,
      );
    } finally {
      client.close(force: true);
    }
  }
}
