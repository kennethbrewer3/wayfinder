import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../tracks/models/track_transportation_mode.dart';
import '../providers/route_follow_provider.dart';

Future<void> startRouteFollowFromDetails({
  required BuildContext context,
  required WidgetRef ref,
  required UuidValue zoneId,
  required String routeName,
  required List<LatLng> path,
  TrackTransportationMode mode = TrackTransportationMode.onFoot,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  Navigator.of(context).pop();

  final ok = await ref
      .read(routeFollowProvider.notifier)
      .start(
        zoneId: zoneId,
        routeName: routeName,
        path: path,
        mode: mode,
      );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        ok ? l10n.routeFollowStarted(routeName) : l10n.routeFollowGpsRequired,
      ),
    ),
  );
}
