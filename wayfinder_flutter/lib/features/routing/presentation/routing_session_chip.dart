import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../providers/routing_session_provider.dart';

/// Compact chip showing the active computed route's distance/ETA with a
/// button to clear it. Shown near the follow HUD when a routing session
/// exists but isn't (yet) being actively followed.
class RoutingSessionChip extends ConsumerWidget {
  const RoutingSessionChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(routingSessionProvider);
    final result = session.result;
    if (result == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final units = ref.watch(measurementUnitsProvider);
    final distance = formatLineDistance(result.distanceMeters, units);
    final duration = formatEvacDuration(
      Duration(milliseconds: result.timeMs),
    );

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              session.destinationLabel == null
                  ? l10n.routingRouteSummary(distance, duration)
                  : '${session.destinationLabel} · '
                        '${l10n.routingRouteSummary(distance, duration)}',
              style: theme.textTheme.labelMedium,
            ),
            IconButton(
              tooltip: l10n.routingClearRouteAction,
              onPressed: () =>
                  ref.read(routingSessionProvider.notifier).clear(),
              icon: const Icon(Icons.close),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
