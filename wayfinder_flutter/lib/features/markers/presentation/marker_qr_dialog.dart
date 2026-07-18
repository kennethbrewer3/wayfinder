import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/app_globals.dart';
import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../utils/marker_qr_export.dart';
import '../utils/marker_share_url.dart';

Future<void> showMarkerQrDialog({
  required BuildContext context,
  required MapMarker marker,
}) {
  final qrUrl = buildMarkerQrUrl(
    marker: marker,
    webBaseUrl: appServerConfig.webUrl,
  );
  return showDialog<void>(
    context: context,
    builder: (context) => _MarkerQrDialog(
      markerName: marker.name,
      qrUrl: qrUrl,
    ),
  );
}

class _MarkerQrDialog extends StatefulWidget {
  const _MarkerQrDialog({
    required this.markerName,
    required this.qrUrl,
  });

  final String markerName;
  final String qrUrl;

  @override
  State<_MarkerQrDialog> createState() => _MarkerQrDialogState();
}

class _MarkerQrDialogState extends State<_MarkerQrDialog> {
  static final _log = AppLogger.logMarkers;

  bool _savingPng = false;
  bool _savingSvg = false;

  String get _fileStem => sanitizeMarkerQrFileStem(widget.markerName);

  Future<void> _savePng() async {
    setState(() => _savingPng = true);
    try {
      final bytes = await buildMarkerQrPngBytes(data: widget.qrUrl);
      final saved = await saveBinaryFile(
        fileName: '$_fileStem-qr.png',
        bytes: bytes,
        allowedExtensions: const ['png'],
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapMarkerQrSavedPng)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '📍 Marker QR PNG export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapMarkerQrSaveFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _savingPng = false);
      }
    }
  }

  Future<void> _saveSvg() async {
    setState(() => _savingSvg = true);
    try {
      final svg = await buildMarkerQrSvg(data: widget.qrUrl);
      final saved = await saveTextFile(
        fileName: '$_fileStem-qr.svg',
        contents: svg,
        allowedExtensions: const ['svg'],
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapMarkerQrSavedSvg)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '📍 Marker QR SVG export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapMarkerQrSaveFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _savingSvg = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final busy = _savingPng || _savingSvg;

    return AlertDialog(
      title: Text(l10n.mapMarkerQrTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.markerName,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: widget.qrUrl,
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  size: 280,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF000000),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF000000),
                  ),
                  embeddedImage: const AssetImage(wayfinderFaviconAsset),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(62, 62),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              widget.qrUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        TextButton.icon(
          onPressed: busy ? null : _saveSvg,
          icon: _savingSvg
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.architecture),
          label: Text(l10n.mapMarkerQrSaveSvg),
        ),
        FilledButton.icon(
          onPressed: busy ? null : _savePng,
          icon: _savingPng
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.image),
          label: Text(l10n.mapMarkerQrSavePng),
        ),
      ],
    );
  }
}
