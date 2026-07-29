import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../models/routing_models.dart';
import '../providers/routing_session_provider.dart';
import 'routing_profile_picker.dart';
import 'start_routing_follow.dart';

/// Sidebar section listing turn-by-turn steps for the active Route here session.
class RoutingSessionSidebarSection extends ConsumerWidget {
  const RoutingSessionSidebarSection({super.key});

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
    final profileText = routingProfileLabel(l10n, session.profile);
    final distance = formatLineDistance(result.distanceMeters, units);
    final duration = formatEvacDuration(
      Duration(milliseconds: result.timeMs),
    );
    final summary = session.destinationLabel == null
        ? l10n.routingRouteSummaryWithProfile(profileText, distance, duration)
        : '${session.destinationLabel} · '
              '${l10n.routingRouteSummaryWithProfile(profileText, distance, duration)}';
    final steps = [
      for (final instruction in result.instructions)
        if (instruction.text.trim().isNotEmpty) instruction,
    ];
    final canFollow = result.points.length >= 2;
    final container = ProviderScope.containerOf(context);

    return ExpansionTile(
      initiallyExpanded: true,
      leading: Icon(routingProfileIcon(session.profile)),
      title: Text(l10n.routingDirectionsTitle),
      subtitle: Text(summary, style: theme.textTheme.bodySmall),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: !canFollow
                    ? null
                    : () {
                        unawaited(startFollowFromRoutingSession(container));
                      },
                icon: const Icon(Icons.navigation, size: 18),
                label: Text(l10n.routeFollowButton),
              ),
              TextButton.icon(
                onPressed: !canFollow
                    ? null
                    : () {
                        unawaited(
                          startFollowFromRoutingSession(
                            container,
                            simulate: true,
                          ),
                        );
                      },
                icon: const Icon(Icons.fast_forward, size: 18),
                label: Text(l10n.routeFollowSimulate),
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(routingSessionProvider.notifier).clear();
                },
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.routingClearRouteAction),
              ),
            ],
          ),
        ),
        if (steps.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(l10n.routingDirectionsEmpty),
          )
        else
          for (var index = 0; index < steps.length; index++)
            _DirectionStepTile(
              index: index + 1,
              instruction: steps[index],
              units: units,
            ),
      ],
    );
  }
}

class _DirectionStepTile extends StatelessWidget {
  const _DirectionStepTile({
    required this.index,
    required this.instruction,
    required this.units,
  });

  final int index;
  final RoutingInstruction instruction;
  final MeasurementUnits units;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = formatLineDistance(instruction.distanceMeters, units);
    final street = instruction.streetName?.trim();

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 12,
        child: Text(
          '$index',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(instruction.text),
      subtitle: Text(
        street == null || street.isEmpty ? distance : '$street · $distance',
      ),
    );
  }
}
