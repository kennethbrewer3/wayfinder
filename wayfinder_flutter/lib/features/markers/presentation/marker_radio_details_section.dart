import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_radio.dart';
import '../providers/markers_provider.dart';
import 'marker_radio_editor.dart';

class MarkerRadioDetailsSection extends ConsumerWidget {
  const MarkerRadioDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  MapMarker _resolvedMarker(WidgetRef ref) {
    final markers = ref.watch(markersProvider).valueOrNull;
    if (markers == null) {
      return marker;
    }
    for (final candidate in markers) {
      if (candidate.id == marker.id) {
        return candidate;
      }
    }
    return marker;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final contact = MarkerRadioContact.fromMarkerRadioJson(
      _resolvedMarker(ref).radioJson,
    );
    if (contact.isEmpty) {
      return const SizedBox.shrink();
    }

    final freq = formatRadioFrequencyMHz(contact.frequencyMHz);
    final rows = <(String, String)>[
      if (contact.callsign.isNotEmpty)
        (l10n.markerRadioCallsignLabel, contact.callsign),
      (l10n.markerRadioRoleLabel, markerRadioRoleLabel(l10n, contact.role)),
      if (contact.netName != null)
        (l10n.markerRadioNetNameLabel, contact.netName!),
      if (freq.isNotEmpty) (l10n.markerRadioFrequencyLabel, '$freq MHz'),
      (l10n.markerRadioModeLabel, markerRadioModeLabel(l10n, contact.mode)),
      if (contact.toneHz != null)
        (
          l10n.markerRadioToneLabel,
          '${formatRadioFrequencyMHz(contact.toneHz)} Hz',
        ),
      if (contact.offsetMHz != null)
        (
          l10n.markerRadioOffsetLabel,
          '${formatRadioFrequencyMHz(contact.offsetMHz)} MHz',
        ),
      if (contact.notes != null) (l10n.markerRadioNotesLabel, contact.notes!),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.markerRadioTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.markerRadioStructuredHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final (index, row) in rows.indexed) ...[
                if (index > 0) const SizedBox(height: 6),
                Text(
                  row.$1,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(row.$2, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
