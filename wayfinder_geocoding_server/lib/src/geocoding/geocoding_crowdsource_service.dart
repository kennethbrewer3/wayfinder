import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'geocoding_contribution_content_key.dart';
import 'geocoding_contribution_service.dart';
import 'geocoding_settings_store.dart';

const geocodeCrowdsourceBundleVersion = 1;
const geocodeCrowdsourceBundleType = 'geocode_crowdsource';

class GeocodingCrowdsourceSubmitResult {
  const GeocodingCrowdsourceSubmitResult({
    required this.submittedCount,
    required this.uploadedToGit,
    this.bundleJson,
    this.message,
  });

  final int submittedCount;
  final bool uploadedToGit;
  final String? bundleJson;
  final String? message;
}

abstract final class GeocodingCrowdsourceService {
  static const _userAgent = 'Wayfinder/1.0 (geocoding-crowdsource)';

  static Future<int> importFromUrl(
    Session session, {
    String? sourceUrl,
  }) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);
    final url = (sourceUrl ?? settings.crowdsourceSourceUrl).trim();
    if (url.isEmpty) {
      throw const FormatException('Crowdsource source URL is required.');
    }

    final jsonText = await _fetchText(url);
    return importBundle(
      session,
      jsonText,
      markImportedFromCrowd: true,
    );
  }

  static Future<int> importBundle(
    Session session,
    String bundleJson, {
    required bool markImportedFromCrowd,
  }) async {
    final body = _decodeBundleObject(bundleJson);
    _validateBundle(body);

    final entries = _parseAnonymousEntries(body['entries']);
    final now = DateTime.now().toUtc();
    final rows = [
      for (final entry in entries)
        GeocodeContribution(
          name: entry.name,
          latitude: entry.latitude,
          longitude: entry.longitude,
          notes: entry.notes,
          countryCode: entry.countryCode,
          contentKey: entry.contentKey,
          importedFromCrowd: markImportedFromCrowd,
          createdAt: now,
          updatedAt: now,
        ),
    ];

    return GeocodingContributionService.mergeContributions(
      session,
      rows,
      markImportedFromCrowd: markImportedFromCrowd,
    );
  }

  static Future<GeocodingCrowdsourceSubmitResult> submitAnonymous(
    Session session, {
    bool onlyLocalContributions = true,
  }) async {
    final rows = await GeocodingContributionService.listForAnonymousExport(
      session,
      onlyLocal: onlyLocalContributions,
    );
    if (rows.isEmpty) {
      return const GeocodingCrowdsourceSubmitResult(
        submittedCount: 0,
        uploadedToGit: false,
        message: 'No local contributions to submit.',
      );
    }

    final bundleJson = buildAnonymousBundle(rows);
    final token = Platform.environment['GEOCODING_CROWDSOURCE_GITHUB_TOKEN']
        ?.trim();
    if (token == null || token.isEmpty) {
      return GeocodingCrowdsourceSubmitResult(
        submittedCount: rows.length,
        uploadedToGit: false,
        bundleJson: bundleJson,
        message:
            'GitHub token not configured on server. Download the bundle and open a pull request manually.',
      );
    }

    await _uploadBundleToGitHub(bundleJson, token: token);
    return GeocodingCrowdsourceSubmitResult(
      submittedCount: rows.length,
      uploadedToGit: true,
      message: 'Contributions uploaded anonymously to the crowdsource repository.',
    );
  }

  static String buildAnonymousBundle(List<GeocodeContribution> rows) {
    final entries = [
      for (final row in rows)
        {
          'contentKey': row.contentKey,
          'name': row.name,
          'latitude': row.latitude,
          'longitude': row.longitude,
          if (row.notes != null && row.notes!.isNotEmpty) 'notes': row.notes,
          if (row.countryCode != null && row.countryCode!.isNotEmpty)
            'countryCode': row.countryCode,
        },
    ];

    return jsonEncode({
      'version': geocodeCrowdsourceBundleVersion,
      'type': geocodeCrowdsourceBundleType,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'entries': entries,
    });
  }

  static Future<String> _fetchText(String url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(minutes: 2)
      ..idleTimeout = const Duration(minutes: 5);
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to fetch crowdsource data (HTTP ${response.statusCode}).',
          uri: uri,
        );
      }
      return await response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }

  static Future<void> _uploadBundleToGitHub(
    String bundleJson, {
    required String token,
  }) async {
    final repo = Platform.environment['GEOCODING_CROWDSOURCE_GITHUB_REPO']
            ?.trim() ??
        'kennethbrewer3/wayfinder';
    final filePath =
        Platform.environment['GEOCODING_CROWDSOURCE_GITHUB_FILE']?.trim() ??
            'geocoding-crowdsource/contributions.json';

    final parts = repo.split('/');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      throw FormatException('Invalid GEOCODING_CROWDSOURCE_GITHUB_REPO: $repo');
    }

    final owner = parts[0];
    final repoName = parts[1];
    final existing = await _fetchGitHubFile(
      owner: owner,
      repo: repoName,
      path: filePath,
      token: token,
    );

    final mergedBundle = _mergeBundles(existing?.content, bundleJson);
    await _putGitHubFile(
      owner: owner,
      repo: repoName,
      path: filePath,
      token: token,
      content: mergedBundle,
      sha: existing?.sha,
      message: 'Add anonymous geocoding contributions',
    );
  }

  static String _mergeBundles(String? existingJson, String incomingJson) {
    final existingEntries = existingJson == null || existingJson.trim().isEmpty
        ? <_AnonymousEntry>[]
        : _parseAnonymousEntries(
            _decodeBundleObject(existingJson)['entries'],
          );
    final incomingEntries = _parseAnonymousEntries(
      _decodeBundleObject(incomingJson)['entries'],
    );

    final byKey = <String, _AnonymousEntry>{};
    for (final entry in existingEntries) {
      byKey[entry.contentKey] = entry;
    }
    for (final entry in incomingEntries) {
      byKey[entry.contentKey] = entry;
    }

    final sorted = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return jsonEncode({
      'version': geocodeCrowdsourceBundleVersion,
      'type': geocodeCrowdsourceBundleType,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'entries': [
        for (final entry in sorted) entry.toJson(),
      ],
    });
  }

  static Map<String, dynamic> _decodeBundleObject(String bundleJson) {
    final trimmed = bundleJson.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Crowdsource bundle is empty.');
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Crowdsource bundle must be a JSON object.');
    }
    return decoded;
  }

  static void _validateBundle(Map<String, dynamic> body) {
    final version = body['version'];
    if (version is! int || version != geocodeCrowdsourceBundleVersion) {
      throw FormatException(
        'Unsupported crowdsource version: $version (expected $geocodeCrowdsourceBundleVersion).',
      );
    }

    final type = body['type'];
    if (type != geocodeCrowdsourceBundleType) {
      throw FormatException(
        'Unsupported crowdsource type: $type (expected $geocodeCrowdsourceBundleType).',
      );
    }
  }

  static List<_AnonymousEntry> _parseAnonymousEntries(Object? raw) {
    if (raw is! List) {
      throw const FormatException('Crowdsource field "entries" must be an array.');
    }

    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          _parseAnonymousEntry(entry)
        else
          throw const FormatException(
            'Each crowdsource entry must be a JSON object.',
          ),
    ];
  }

  static _AnonymousEntry _parseAnonymousEntry(Map<String, dynamic> entry) {
    final name = (entry['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw const FormatException('Each crowdsource entry requires a "name".');
    }

    final latitude = (entry['latitude'] as num?)?.toDouble();
    final longitude = (entry['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      throw const FormatException(
        'Each crowdsource entry requires "latitude" and "longitude".',
      );
    }

    final contentKey =
        (entry['contentKey'] as String?)?.trim() ??
        GeocodingContributionContentKey.compute(
          name: name,
          latitude: latitude,
          longitude: longitude,
        );

    final notes = (entry['notes'] as String?)?.trim();
    final countryCode = (entry['countryCode'] as String?)?.trim().toUpperCase();

    return _AnonymousEntry(
      contentKey: contentKey,
      name: name,
      latitude: latitude,
      longitude: longitude,
      notes: notes == null || notes.isEmpty ? null : notes,
      countryCode:
          countryCode != null && countryCode.length == 2 ? countryCode : null,
    );
  }

  static Future<_GitHubFile?> _fetchGitHubFile({
    required String owner,
    required String repo,
    required String path,
    required String token,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(minutes: 2)
      ..idleTimeout = const Duration(minutes: 5);
    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/contents/$path',
      );
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close();
      if (response.statusCode == HttpStatus.notFound) {
        return null;
      }
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to read crowdsource file from GitHub (HTTP ${response.statusCode}).',
          uri: uri,
        );
      }

      final body = jsonDecode(await response.transform(utf8.decoder).join());
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Unexpected GitHub API response.');
      }

      final encoded = body['content'] as String?;
      final sha = body['sha'] as String?;
      if (encoded == null || sha == null) {
        throw const FormatException('GitHub file response missing content or sha.');
      }

      final normalized = encoded.replaceAll('\n', '');
      final content = utf8.decode(base64.decode(normalized));
      return _GitHubFile(content: content, sha: sha);
    } finally {
      client.close(force: true);
    }
  }

  static Future<void> _putGitHubFile({
    required String owner,
    required String repo,
    required String path,
    required String token,
    required String content,
    required String message,
    String? sha,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(minutes: 2)
      ..idleTimeout = const Duration(minutes: 5);
    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/contents/$path',
      );
      final request = await client.putUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.write(
        jsonEncode({
          'message': message,
          'content': base64Encode(utf8.encode(content)),
          'sha': ?sha,
        }),
      );
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.created) {
        final responseBody = await response.transform(utf8.decoder).join();
        WfLog.warn(
          null,
          'geocoding',
          'Crowdsource GitHub upload failed HTTP ${response.statusCode}: $responseBody',
        );
        throw HttpException(
          'Failed to upload crowdsource file to GitHub (HTTP ${response.statusCode}).',
          uri: uri,
        );
      }
    } finally {
      client.close(force: true);
    }
  }
}

class _GitHubFile {
  const _GitHubFile({required this.content, required this.sha});

  final String content;
  final String sha;
}

class _AnonymousEntry {
  const _AnonymousEntry({
    required this.contentKey,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.countryCode,
  });

  final String contentKey;
  final String name;
  final double latitude;
  final double longitude;
  final String? notes;
  final String? countryCode;

  Map<String, Object?> toJson() {
    return {
      'contentKey': contentKey,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (countryCode != null && countryCode!.isNotEmpty)
        'countryCode': countryCode,
    };
  }
}
