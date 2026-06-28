import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/app_globals.dart';
import '../providers/app_build_info_provider.dart';

class SettingsAboutTab extends ConsumerWidget {
  const SettingsAboutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final buildInfoAsync = ref.watch(appBuildInfoProvider);

    return buildInfoAsync.when(
      loading: () => Center(child: Text(l10n.settingsAboutLoading)),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.settingsAboutLoadFailed(error.toString())),
        ),
      ),
      data: (buildInfo) {
        final appName = buildInfo.appName.trim().isEmpty
            ? l10n.appTitle
            : buildInfo.appName;

        return SelectionArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.settingsAboutTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsAboutDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/manual'),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(l10n.settingsAboutOpenManual),
                ),
              ),
              const SizedBox(height: 24),
              _InfoSection(
                title: l10n.settingsAboutAppSection,
                rows: [
                  _InfoRow(label: l10n.settingsAboutAppName, value: appName),
                  _InfoRow(
                    label: l10n.settingsAboutVersion,
                    value: buildInfo.versionLabel,
                  ),
                  if (buildInfo.gitCommit != null &&
                      buildInfo.gitCommit != 'dev')
                    _InfoRow(
                      label: l10n.settingsAboutGitCommit,
                      value: buildInfo.gitCommit!,
                      monospace: true,
                    )
                  else
                    _InfoRow(
                      label: l10n.settingsAboutGitCommit,
                      value: l10n.settingsAboutGitCommitUnavailable,
                    ),
                  if (buildInfo.buildTime != null)
                    _InfoRow(
                      label: l10n.settingsAboutBuildTime,
                      value: buildInfo.buildTime!,
                    ),
                  _InfoRow(
                    label: l10n.settingsAboutPlatform,
                    value: buildInfo.platformLabel,
                  ),
                  _InfoRow(
                    label: l10n.settingsAboutPackage,
                    value: buildInfo.packageName,
                    monospace: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _InfoSection(
                title: l10n.settingsAboutDeploymentSection,
                rows: [
                  if (buildInfo.dockerImageId != null)
                    _InfoRow(
                      label: l10n.settingsAboutDockerImageId,
                      value: buildInfo.dockerImageId!,
                      monospace: true,
                    )
                  else
                    _InfoRow(
                      label: l10n.settingsAboutDockerImageId,
                      value: l10n.settingsAboutDockerImageIdUnavailable,
                    ),
                  if (buildInfo.dockerImageRef != null)
                    _InfoRow(
                      label: l10n.settingsAboutDockerImageRef,
                      value: buildInfo.dockerImageRef!,
                      monospace: true,
                    ),
                  if (buildInfo.containerStartedAt != null)
                    _InfoRow(
                      label: l10n.settingsAboutContainerStarted,
                      value: buildInfo.containerStartedAt!,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _InfoSection(
                title: l10n.settingsAboutConnectionSection,
                rows: [
                  _InfoRow(
                    label: l10n.settingsAboutApiServer,
                    value: appServerConfig.apiUrl,
                    monospace: true,
                  ),
                  _InfoRow(
                    label: l10n.settingsAboutWebServer,
                    value: appServerConfig.webUrl,
                    monospace: true,
                  ),
                  _InfoRow(
                    label: l10n.settingsAboutGeocodingServer,
                    value: appServerConfig.geocodingWebUrl ??
                        l10n.settingsAboutGeocodingServerNotConfigured,
                    monospace: appServerConfig.geocodingWebUrl != null,
                  ),
                ],
              ),
              if (buildInfo.shortGitCommit != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.settingsAboutCommitHint(buildInfo.shortGitCommit!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (buildInfo.shortDockerImageId != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.settingsAboutDockerImageIdHint(
                    buildInfo.shortDockerImageId!,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  l10n.settingsAboutDockerImageIdHintUnavailable,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final valueStyle = monospace
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            )
        : Theme.of(context).textTheme.bodyMedium;

    return ListTile(
      title: Text(label),
      subtitle: Text(value, style: valueStyle),
      dense: true,
    );
  }
}
