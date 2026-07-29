import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../routing/providers/routing_session_provider.dart';
import '../../routing/presentation/start_routing_follow.dart';
import '../providers/route_follow_nautical_mode_provider.dart';
import '../providers/route_follow_provider.dart';
import '../utils/route_follow_progress.dart';

/// Compact guidance card while following a line or evac route.
class MapRouteFollowHud extends ConsumerWidget {
  const MapRouteFollowHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final follow = ref.watch(routeFollowProvider);
    if (!follow.active) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final units = ref.watch(measurementUnitsProvider);
    final nautical = ref.watch(routeFollowNauticalModeProvider);
    final progress = follow.progress;

    final remainingText = progress == null
        ? '—'
        : formatLineDistance(progress.remainingMeters, units);
    final offRouteText = progress == null
        ? null
        : formatLineDistance(progress.offRouteMeters, units);
    final eta = progress == null
        ? null
        : formatEvacDuration(
            evacRouteDuration(
              lengthMeters: progress.remainingMeters,
              mode: follow.mode,
            ),
          );
    final namedInstruction = progress == null
        ? null
        : currentRouteFollowNamedInstruction(
            follow.namedInstructions,
            progress.traveledMeters,
          );
    final guidanceText = progress == null || progress.completed
        ? null
        : namedInstruction != null
        ? namedInstruction.text
        : _formatManeuverGuidance(
            l10n: l10n,
            units: units,
            kind: progress.nextManeuver,
            meters: progress.metersToNextManeuver,
            turnDegrees: progress.turnDegrees,
            nautical: nautical,
          );

    final offRoute = follow.offRoute;
    final completed = follow.completed;
    final statusColor = completed
        ? theme.colorScheme.primary
        : offRoute
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              completed
                  ? Icons.flag
                  : offRoute
                  ? Icons.warning_amber_rounded
                  : Icons.navigation,
              size: 18,
              color: statusColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    completed
                        ? l10n.routeFollowCompleted
                        : offRoute
                        ? l10n.routeFollowOffRoute(offRouteText ?? '—')
                        : l10n.routeFollowActive(follow.routeName),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      ?guidanceText,
                      l10n.routeFollowRemaining(remainingText),
                      if (eta != null) l10n.routeFollowEta(eta),
                    ].join(' · '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: nautical
                  ? l10n.routeFollowNauticalModeDisable
                  : l10n.routeFollowNauticalModeEnable,
              onPressed: () {
                unawaited(
                  ref.read(routeFollowNauticalModeProvider.notifier).toggle(),
                );
              },
              icon: Icon(
                Icons.sailing,
                color: nautical ? theme.colorScheme.primary : null,
              ),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: follow.simulating
                  ? l10n.routeFollowStopSimulate
                  : l10n.routeFollowSimulate,
              onPressed: () {
                final notifier = ref.read(routeFollowProvider.notifier);
                if (follow.simulating) {
                  notifier.stopSimulation();
                  return;
                }
                // Prefer the latest Route here geometry when present so
                // Simulate never keeps walking a superseded path.
                if (ref.read(routingSessionProvider).hasRoute) {
                  unawaited(
                    startFollowFromRoutingSession(
                      ProviderScope.containerOf(context),
                      simulate: true,
                    ),
                  );
                } else {
                  unawaited(notifier.startSimulation());
                }
              },
              icon: Icon(
                follow.simulating ? Icons.pause : Icons.fast_forward,
              ),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: l10n.routeFollowStop,
              onPressed: () => ref.read(routeFollowProvider.notifier).stop(),
              icon: const Icon(Icons.close),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatManeuverGuidance({
  required AppLocalizations l10n,
  required MeasurementUnits units,
  required RouteFollowManeuverKind kind,
  required double meters,
  required double turnDegrees,
  required bool nautical,
}) {
  final distance = formatLineDistance(meters, units);
  final degrees = turnDegrees.round().clamp(1, 180);
  return switch (kind) {
    RouteFollowManeuverKind.turnLeft =>
      nautical
          ? l10n.routeFollowTurnPortIn(distance, degrees)
          : l10n.routeFollowTurnLeftIn(distance),
    RouteFollowManeuverKind.turnRight =>
      nautical
          ? l10n.routeFollowTurnStarboardIn(distance, degrees)
          : l10n.routeFollowTurnRightIn(distance),
    RouteFollowManeuverKind.continueStraight => l10n.routeFollowContinueFor(
      distance,
    ),
    RouteFollowManeuverKind.arrive => l10n.routeFollowArriveIn(distance),
  };
}
