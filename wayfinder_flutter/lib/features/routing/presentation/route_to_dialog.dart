import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/device_location_provider.dart';
import '../data/routing_repository.dart';
import '../models/routing_models.dart';
import '../providers/routing_session_provider.dart';
import 'routing_profile_picker.dart';
import 'start_routing_follow.dart';

/// Computes a route from the device's current GPS fix to
/// ([latitude], [longitude]) using the configured routing server, stores it
/// in [routingSessionProvider] for the map overlay, and offers to start
/// route-follow guidance via a snackbar action.
///
/// Asks for foot / bike / car before routing, remembering the last choice.
///
/// Mirrors [startRouteFollowFromDetails]: captures [messenger]/[l10n] before
/// popping the details dialog, then only touches those captured references
/// (never `context`) for the remainder of the async flow.
Future<void> routeToMapPoint({
  required BuildContext context,
  required WidgetRef ref,
  required String destinationLabel,
  required double latitude,
  required double longitude,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final units = ref.read(measurementUnitsProvider);

  final repository = ref.read(routingRepositoryProvider);
  if (!repository.isConfigured) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.routingNotConfigured)),
    );
    return;
  }

  bool reachable;
  try {
    reachable = await ref.read(routingServerReachableProvider.future);
  } catch (_) {
    reachable = false;
  }
  if (!reachable) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.routingServerUnreachable)),
    );
    return;
  }

  RoutingStatus status;
  try {
    status = await ref.read(routingStatusProvider.future);
  } catch (_) {
    status = RoutingStatus.unconfigured;
  }
  if (!status.ready) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.routingNotReady)));
    return;
  }

  final preferred = await loadPreferredRoutingProfile();
  if (!context.mounted) {
    return;
  }
  final profile = await showRoutingProfilePicker(
    context: context,
    initial: preferred,
  );
  if (profile == null || !context.mounted) {
    return;
  }
  unawaited(savePreferredRoutingProfile(profile));

  Navigator.of(context).pop();

  var position = ref.read(deviceLocationProvider).position;
  if (position == null) {
    await ref.read(deviceLocationProvider.notifier).locateAndFollow();
    position = ref.read(deviceLocationProvider).position;
  }
  if (position == null) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.routeFollowGpsRequired)),
    );
    return;
  }

  try {
    final result = await repository.route(
      from: RoutingPoint(lat: position.latitude, lon: position.longitude),
      to: RoutingPoint(lat: latitude, lon: longitude),
      profile: profile,
    );
    ref
        .read(routingSessionProvider.notifier)
        .setRoute(
          result: result,
          profile: profile,
          destinationLabel: destinationLabel,
        );

    final distanceText = formatLineDistance(result.distanceMeters, units);
    final durationText = formatEvacDuration(
      Duration(milliseconds: result.timeMs),
    );
    final profileText = routingProfileLabel(l10n, profile);
    final summary = l10n.routingRouteSummaryWithProfile(
      profileText,
      distanceText,
      durationText,
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text(summary),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: l10n.routeFollowButton,
          onPressed: () {
            unawaited(startFollowFromRoutingSession(ref));
          },
        ),
      ),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.routingRouteRequestFailed(error.toString())),
      ),
    );
  }
}
