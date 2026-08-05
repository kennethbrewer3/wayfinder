import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/device_location_provider.dart';
import '../../offline_packs/providers/offline_snapshot_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../data/routing_repository.dart';
import '../models/routing_models.dart';
import '../providers/routing_session_provider.dart';
import 'routing_profile_picker.dart';
import 'start_routing_follow.dart';

/// Snackbars for routing stay until the user dismisses them (close icon or
/// action). Auto-hide is too short to read GraphHopper errors.
SnackBar _persistentRoutingSnackBar({
  required Widget content,
  SnackBarAction? action,
}) {
  return SnackBar(
    content: content,
    duration: const Duration(days: 365),
    showCloseIcon: true,
    action: action,
  );
}

void _offerFollowSnackbar({
  required ScaffoldMessengerState messenger,
  required ProviderContainer container,
  required AppLocalizations l10n,
  required String summary,
}) {
  messenger.showSnackBar(
    _persistentRoutingSnackBar(
      content: Text(summary),
      action: SnackBarAction(
        label: l10n.routeFollowButton,
        onPressed: () {
          unawaited(startFollowFromRoutingSession(container));
        },
      ),
    ),
  );
}

/// Computes a route from the device's current GPS fix to
/// ([latitude], [longitude]) using the configured routing server, stores it
/// in [routingSessionProvider] for the map overlay, and offers to start
/// route-follow guidance via a snackbar action.
///
/// When the main server is offline, prefers a precomputed route from the
/// active offline pack (matched by [destinationMarkerId]) so OSM guidance
/// still works with no LAN. Live GraphHopper is used when the routing server
/// is still reachable.
///
/// Asks for foot / bike / car before live routing, remembering the last choice.
///
/// Captures [ProviderContainer] / [messenger] / [l10n] before popping the
/// details dialog so async work never touches a disposed [WidgetRef].
Future<void> routeToMapPoint({
  required BuildContext context,
  required String destinationLabel,
  required double latitude,
  required double longitude,
  String? destinationMarkerId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  // Survive dialog dispose (pop below); do not use [ref] after that.
  final container = ProviderScope.containerOf(context);
  final units = container.read(measurementUnitsProvider);
  final offline = container.read(offlineModeActiveProvider);

  final packed = destinationMarkerId == null
      ? null
      : packedRouteForMarker(
          container.read(offlinePackedRoutesProvider),
          destinationMarkerId,
        );

  if (offline && packed != null) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    container
        .read(routingSessionProvider.notifier)
        .setRoute(
          result: packed.result,
          profile: packed.profile,
          destinationLabel: packed.destinationLabel,
        );
    final distanceText = formatLineDistance(
      packed.result.distanceMeters,
      units,
    );
    final durationText = formatEvacDuration(
      Duration(milliseconds: packed.result.timeMs),
    );
    final profileText = routingProfileLabel(l10n, packed.profile);
    _offerFollowSnackbar(
      messenger: messenger,
      container: container,
      l10n: l10n,
      summary: l10n.offlinePackRouteLoaded(
        profileText,
        distanceText,
        durationText,
      ),
    );
    return;
  }

  final repository = container.read(routingRepositoryProvider);
  if (!repository.isConfigured) {
    messenger.showSnackBar(
      _persistentRoutingSnackBar(
        content: Text(
          offline ? l10n.offlinePackRouteMissing : l10n.routingNotConfigured,
        ),
      ),
    );
    return;
  }

  bool reachable;
  try {
    reachable = await container.read(routingServerReachableProvider.future);
  } catch (_) {
    reachable = false;
  }
  if (!reachable) {
    messenger.showSnackBar(
      _permanentOfflineOrUnreachable(l10n, offline),
    );
    return;
  }

  RoutingStatus status;
  try {
    status = await container.read(routingStatusProvider.future);
  } catch (_) {
    status = RoutingStatus.unconfigured;
  }
  if (!status.ready) {
    messenger.showSnackBar(
      _persistentRoutingSnackBar(
        content: Text(
          offline ? l10n.offlinePackRouteMissing : l10n.routingNotReady,
        ),
      ),
    );
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

  var position = container.read(deviceLocationProvider).position;
  if (position == null) {
    await container.read(deviceLocationProvider.notifier).locateAndFollow();
    position = container.read(deviceLocationProvider).position;
  }
  if (position == null) {
    messenger.showSnackBar(
      _persistentRoutingSnackBar(content: Text(l10n.routeFollowGpsRequired)),
    );
    return;
  }

  try {
    final result = await repository.route(
      from: RoutingPoint(lat: position.latitude, lon: position.longitude),
      to: RoutingPoint(lat: latitude, lon: longitude),
      profile: profile,
    );
    container
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

    _offerFollowSnackbar(
      messenger: messenger,
      container: container,
      l10n: l10n,
      summary: summary,
    );
  } catch (error) {
    messenger.showSnackBar(
      _persistentRoutingSnackBar(
        content: Text(l10n.routingRouteRequestFailed(error.toString())),
      ),
    );
  }
}

SnackBar _permanentOfflineOrUnreachable(
  AppLocalizations l10n,
  bool offline,
) {
  return _persistentRoutingSnackBar(
    content: Text(
      offline ? l10n.offlinePackRouteMissing : l10n.routingServerUnreachable,
    ),
  );
}
