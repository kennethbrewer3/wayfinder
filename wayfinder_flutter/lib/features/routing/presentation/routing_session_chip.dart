import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../route_follow/providers/route_follow_provider.dart';
import '../providers/routing_session_provider.dart';
import 'start_routing_follow.dart';

/// Compact chip showing the active computed route's distance/ETA with
/// Follow / Simulate / Clear actions. Shown near the follow HUD when a
/// routing session exists.
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
    final follow = ref.watch(routeFollowProvider);
    final distance = formatLineDistance(result.distanceMeters, units);
    final duration = formatEvacDuration(
      Duration(milliseconds: result.timeMs),
    );
    final canFollow = result.points.length >= 2;

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
            Flexible(
              child: Text(
                session.destinationLabel == null
                    ? l10n.routingRouteSummary(distance, duration)
                    : '${session.destinationLabel} · '
                          '${l10n.routingRouteSummary(distance, duration)}',
                style: theme.textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!follow.active) ...[
              IconButton(
                tooltip: l10n.routeFollowButton,
                onPressed: !canFollow
                    ? null
                    : () {
                        unawaited(startFollowFromRoutingSession(ref));
                      },
                icon: const Icon(Icons.navigation),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: l10n.routeFollowSimulate,
                onPressed: !canFollow
                    ? null
                    : () {
                        unawaited(
                          startFollowFromRoutingSession(ref, simulate: true),
                        );
                      },
                icon: const Icon(Icons.fast_forward),
                visualDensity: VisualDensity.compact,
              ),
            ],
            IconButton(
              tooltip: l10n.routingClearRouteAction,
              onPressed: () {
                ref.read(routingSessionProvider.notifier).clear();
              },
              icon: const Icon(Icons.close),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
