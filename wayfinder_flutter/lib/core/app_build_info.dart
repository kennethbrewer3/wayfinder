import 'package:flutter/foundation.dart';
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
  });

  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;
  final String platformLabel;
  final String? gitCommit;
  final String? buildTime;

  String get versionLabel => '$version+$buildNumber';

  String? get shortGitCommit {
    final commit = gitCommit?.trim();
    if (commit == null || commit.isEmpty || commit == 'dev') {
      return null;
    }
    return commit.length <= 7 ? commit : commit.substring(0, 7);
  }

  static Future<AppBuildInfo> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final commit = appBuildCommit.trim();
    final builtAt = appBuildTime.trim();

    return AppBuildInfo(
      appName: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
      platformLabel: _platformLabel(),
      gitCommit: commit.isEmpty ? null : commit,
      buildTime: builtAt.isEmpty ? null : builtAt,
    );
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
