import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/format/locale_count_format.dart';
import '../models/geocoding_models.dart';

String geocodingImportPhaseTitle(
  AppLocalizations l10n,
  GeocodingImportPhase phase, {
  required bool isAddresses,
}) {
  return switch (phase) {
    GeocodingImportPhase.downloading =>
      l10n.geocodingImportPhaseDownloadingTitle,
    GeocodingImportPhase.importing => isAddresses
        ? l10n.geocodingImportPhaseImportingAddressesTitle
        : l10n.geocodingImportPhaseImportingTitle,
    GeocodingImportPhase.finalizing =>
      l10n.geocodingImportPhaseFinalizingTitle,
    GeocodingImportPhase.committing =>
      l10n.geocodingImportPhaseCommittingTitle,
    GeocodingImportPhase.idle => '',
  };
}

String geocodingImportPhaseDetail(
  AppLocalizations l10n,
  GeocodingImportPhase phase, {
  required bool isAddresses,
  required String formattedCount,
  required String rowLabel,
}) {
  return switch (phase) {
    GeocodingImportPhase.downloading =>
      l10n.geocodingImportPhaseDownloadingDetail,
    GeocodingImportPhase.importing => isAddresses
        ? l10n.geocodingImportPhaseImportingAddressesDetail
        : l10n.geocodingImportPhaseImportingDetail,
    GeocodingImportPhase.finalizing =>
      l10n.geocodingImportPhaseFinalizingDetail,
    GeocodingImportPhase.committing =>
      l10n.geocodingImportPhaseCommittingDetail(formattedCount, rowLabel),
    GeocodingImportPhase.idle => '',
  };
}

class GeocodingImportDoNotRestartWarning extends StatelessWidget {
  const GeocodingImportDoNotRestartWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.geocodingImportDoNotRestartTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.geocodingImportDoNotRestartMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeocodingImportPhaseSteps extends StatelessWidget {
  const GeocodingImportPhaseSteps({
    super.key,
    required this.currentPhase,
    required this.isAddresses,
  });

  final GeocodingImportPhase currentPhase;
  final bool isAddresses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const phases = [
      GeocodingImportPhase.downloading,
      GeocodingImportPhase.importing,
      GeocodingImportPhase.finalizing,
      GeocodingImportPhase.committing,
    ];
    final currentIndex = phases.indexOf(currentPhase);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < phases.length; index++) ...[
          if (index > 0) const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                index < currentIndex
                    ? Icons.check_circle_outline
                    : index == currentIndex
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                size: 18,
                color: index <= currentIndex
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  geocodingImportPhaseTitle(
                    l10n,
                    phases[index],
                    isAddresses: isAddresses,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: index == currentIndex
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: index == currentIndex
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class GeocodingImportProgressPanel extends StatelessWidget {
  const GeocodingImportProgressPanel({
    super.key,
    required this.importStatus,
    required this.progress,
    required this.importedRowCount,
    required this.rowLabel,
    required this.isAddresses,
    this.onAbort,
    this.isCancelling = false,
    this.showTopSpacing = true,
  });

  final String importStatus;
  final double progress;
  final int importedRowCount;
  final String rowLabel;
  final bool isAddresses;
  final VoidCallback? onAbort;
  final bool isCancelling;
  final bool showTopSpacing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phase = resolveGeocodingImportPhase(
      isRunning: true,
      status: importStatus,
      progress: progress,
    );
    final isCommitPhase = phase == GeocodingImportPhase.committing;
    final showDoNotRestart = phase == GeocodingImportPhase.committing ||
        phase == GeocodingImportPhase.finalizing;
    final canAbort = onAbort != null &&
        phase != GeocodingImportPhase.committing &&
        phase != GeocodingImportPhase.finalizing;
    final progressPercent =
        (progress * 100).clamp(0, 100).toStringAsFixed(1);
    final formattedCount = formatLocaleCount(
      importedRowCount,
      Localizations.localeOf(context).toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTopSpacing) const SizedBox(height: 12),
        GeocodingImportPhaseSteps(
          currentPhase: phase,
          isAddresses: isAddresses,
        ),
        const SizedBox(height: 12),
        Text(
          geocodingImportPhaseTitle(l10n, phase, isAddresses: isAddresses),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          geocodingImportPhaseDetail(
            l10n,
            phase,
            isAddresses: isAddresses,
            formattedCount: formattedCount,
            rowLabel: rowLabel,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: isCommitPhase ? null : progress),
        if (!isCommitPhase) ...[
          const SizedBox(height: 4),
          Text(
            l10n.geocodingImportProgress(
              progressPercent,
              formattedCount,
              rowLabel,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (showDoNotRestart) ...[
          const SizedBox(height: 12),
          const GeocodingImportDoNotRestartWarning(),
        ],
        if (canAbort) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: isCancelling ? null : onAbort,
              icon: isCancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.stop_circle_outlined),
              label: Text(
                isCancelling ? l10n.actionAborting : l10n.geocodingAbortImport,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
