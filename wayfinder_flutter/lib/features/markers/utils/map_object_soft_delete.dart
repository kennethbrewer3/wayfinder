import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../markers/providers/markers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../radio_sync/providers/radio_sync_controller.dart';

/// Soft-deletes a marker and offers an Undo snackbar.
Future<bool> softDeleteMarkerWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required UuidValue markerId,
  String? markerName,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final client = ref.read(serverClientProvider);
  final deleted = await client.mapMarker.deleteMarker(markerId);
  if (!deleted) {
    return false;
  }
  await ref.read(radioSyncControllerProvider).emitMarkerDelete(markerId);
  ref.invalidate(markersProvider);
  if (!context.mounted) {
    return true;
  }
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        markerName == null || markerName.isEmpty
            ? l10n.mapObjectDeletedSnackbar
            : l10n.mapObjectDeletedNamedSnackbar(markerName),
      ),
      action: SnackBarAction(
        label: l10n.actionUndo,
        onPressed: () async {
          await client.mapMarker.restoreMarker(markerId);
          ref.invalidate(markersProvider);
        },
      ),
    ),
  );
  return true;
}

/// Soft-deletes a zone and offers an Undo snackbar.
Future<bool> softDeleteZoneWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required UuidValue zoneId,
  String? zoneName,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final client = ref.read(serverClientProvider);
  final existing = await client.mapZone.getZone(zoneId);
  final deleted = await client.mapZone.deleteZone(zoneId);
  if (!deleted) {
    return false;
  }
  await ref
      .read(radioSyncControllerProvider)
      .emitZoneDelete(
        zoneId,
        zoneType: existing?.type ?? '',
      );
  ref.read(zonesProvider.notifier).reload();
  if (!context.mounted) {
    return true;
  }
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        zoneName == null || zoneName.isEmpty
            ? l10n.mapObjectDeletedSnackbar
            : l10n.mapObjectDeletedNamedSnackbar(zoneName),
      ),
      action: SnackBarAction(
        label: l10n.actionUndo,
        onPressed: () async {
          await client.mapZone.restoreZone(zoneId);
          ref.read(zonesProvider.notifier).reload();
        },
      ),
    ),
  );
  return true;
}
