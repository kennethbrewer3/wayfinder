import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/routing_models.dart';

const _preferredProfilePrefsKey = 'wayfinder.routing.preferred_profile';

Future<RoutingProfile> loadPreferredRoutingProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_preferredProfilePrefsKey);
  return switch (raw) {
    'bike' => RoutingProfile.bike,
    'car' => RoutingProfile.car,
    _ => RoutingProfile.foot,
  };
}

Future<void> savePreferredRoutingProfile(RoutingProfile profile) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_preferredProfilePrefsKey, profile.apiValue);
}

String routingProfileLabel(AppLocalizations l10n, RoutingProfile profile) {
  return switch (profile) {
    RoutingProfile.foot => l10n.routingProfileFoot,
    RoutingProfile.bike => l10n.routingProfileBike,
    RoutingProfile.car => l10n.routingProfileCar,
  };
}

IconData routingProfileIcon(RoutingProfile profile) {
  return switch (profile) {
    RoutingProfile.foot => Icons.directions_walk,
    RoutingProfile.bike => Icons.directions_bike,
    RoutingProfile.car => Icons.directions_car,
  };
}

/// Lets the user choose foot / bike / car before computing a route.
Future<RoutingProfile?> showRoutingProfilePicker({
  required BuildContext context,
  RoutingProfile initial = RoutingProfile.foot,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<RoutingProfile>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.routingProfilePickerTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.routingProfilePickerDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final profile in RoutingProfile.values)
                ListTile(
                  leading: Icon(routingProfileIcon(profile)),
                  title: Text(routingProfileLabel(l10n, profile)),
                  selected: profile == initial,
                  trailing: profile == initial ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(context).pop(profile),
                ),
            ],
          ),
        ),
      );
    },
  );
}
