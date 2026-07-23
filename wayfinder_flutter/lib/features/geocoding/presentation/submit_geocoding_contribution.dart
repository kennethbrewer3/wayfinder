import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../data/geocoding_repository.dart';
import '../providers/geocoding_providers.dart';

final _log = AppLogger.logSettings;

Future<bool> submitGeocodingContribution({
  required BuildContext context,
  required WidgetRef ref,
  required String name,
  required double latitude,
  required double longitude,
  String? notes,
}) async {
  final l10n = AppLocalizations.of(context)!;
  if (ref.read(offlineModeActiveProvider)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.offlineGeocodingUnavailable)),
    );
    return false;
  }
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.geocodingContributionNameLabel)),
    );
    return false;
  }

  final repository = ref.read(geocodingRepositoryProvider);
  if (!repository.isConfigured) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.geocodingContributionsConfigureServerHint)),
    );
    return false;
  }

  try {
    await repository.createContribution(
      name: trimmedName,
      latitude: latitude,
      longitude: longitude,
      notes: notes?.trim().isEmpty ?? true ? null : notes!.trim(),
    );
    refreshGeocoding(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionSaved)),
      );
    }
    return true;
  } catch (error, stackTrace) {
    _log.error(
      '📍 Map geocoding contribution failed',
      error: error,
      stackTrace: stackTrace,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
    return false;
  }
}
