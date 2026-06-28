import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../clipboard_copy.dart';
import '../../l10n/app_localizations.dart';

String formatCoordinates(double latitude, double longitude) {
  return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

String formatLatLng(LatLng point) {
  return formatCoordinates(point.latitude, point.longitude);
}

Future<void> copyCoordinatesToClipboard(
  BuildContext context,
  LatLng point,
) async {
  final text = formatLatLng(point);
  final copied = await copyTextToClipboard(text);
  if (!context.mounted) {
    return;
  }
  final l10n = AppLocalizations.of(context)!;
  if (copied) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.mapCoordinatesCopied),
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.mapDebugOverlayCopyFailedTitle),
        content: SelectableText(
          text,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      );
    },
  );
}
