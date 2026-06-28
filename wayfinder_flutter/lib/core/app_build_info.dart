import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Compile-time metadata injected during CI/Docker builds.
const appBuildCommit = String.fromEnvironment(
  'APP_BUILD_COMMIT',
  defaultValue: '',
);

const appBuildTime = String.fromEnvironment(
  'APP_BUILD_TIME',
  defaultValue: '',
);

class AppBuildInfo {
  const AppBuildInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
    required this.platformLabel,
    this.gitCommit,
    this.buildTime,
    this.dockerImageId,
    this.dockerImageRef,
    this.containerStartedAt,
  });

  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;
  final String platformLabel;
  final String? gitCommit;
  final String? buildTime;
  final String? dockerImageId;
  final String? dockerImageRef;
  final String? containerStartedAt;

  String get versionLabel => '$version+$buildNumber';

  String? get shortGitCommit {
    final commit = gitCommit?.trim();
    if (commit == null || commit.isEmpty || commit == 'dev') {
      return null;
    }
    return commit.length <= 7 ? commit : commit.substring(0, 7);
  }

  String? get shortDockerImageId {
    final imageId = dockerImageId?.trim();
    if (imageId == null || imageId.isEmpty) {
      return null;
    }
    final normalized = imageId.startsWith('sha256:')
        ? imageId.substring('sha256:'.length)
        : imageId;
    return normalized.length <= 12 ? normalized : normalized.substring(0, 12);
  }

  static Future<AppBuildInfo> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final serverBuild = await _loadJsonFromWeb('build-info.json');
    final runtime = await _loadJsonFromWeb('runtime-info.json');

    final embeddedCommit = appBuildCommit.trim();
    final embeddedBuiltAt = appBuildTime.trim();
    final serverCommit = _readString(serverBuild, 'gitCommit');
    final serverBuiltAt = _readString(serverBuild, 'buildTime');
    final dockerImageId = _readString(runtime, 'dockerImageId');
    final dockerImageRef = _readString(runtime, 'dockerImageRef');
    final containerStartedAt = _readString(runtime, 'containerStartedAt');

    return AppBuildInfo(
      appName: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
      platformLabel: _platformLabel(),
      gitCommit: _firstMeaningfulCommit([serverCommit, embeddedCommit]),
      buildTime: _firstNonEmpty([serverBuiltAt, embeddedBuiltAt]),
      dockerImageId: dockerImageId,
      dockerImageRef: dockerImageRef,
      containerStartedAt: containerStartedAt,
    );
  }

  static String? _firstMeaningfulCommit(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty || trimmed == 'dev') {
        continue;
      }
      return trimmed;
    }
    return null;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  static String? _readString(Map<String, dynamic>? json, String key) {
    final value = json?[key];
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Future<Map<String, dynamic>?> _loadJsonFromWeb(String path) async {
    if (!kIsWeb) {
      return null;
    }

    try {
      final response = await http
          .get(Uri.base.resolve(path))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        return null;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String _platformLabel() {
    if (kIsWeb) {
      return 'Web';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }
}
