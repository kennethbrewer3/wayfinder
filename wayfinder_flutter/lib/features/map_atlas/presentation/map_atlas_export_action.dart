import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../../markers/providers/markers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../utils/atlas_pdf_builder.dart';
import 'map_atlas_export_dialog.dart';

final _log = AppLogger.logSettings;

/// Shows the atlas export dialog, builds the PDF, and saves it.
///
/// Returns `true` when a file was saved, `false` when cancelled or failed.
Future<bool> runMapAtlasExport({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final options = await showMapAtlasExportDialog(
    context: context,
    ref: ref,
  );
  if (options == null || !context.mounted) {
    return false;
  }

  final l10n = AppLocalizations.of(context)!;
  try {
    final coverage = resolveAtlasCoverage(options: options, ref: ref);
    if (coverage == null || !coverage.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapAtlasExportNoCoverage)),
      );
      return false;
    }

    final markers = await ref.read(markersProvider.future);
    final zones = await ref.read(zonesProvider.future);
    if (!context.mounted) {
      return false;
    }

    final bytes = await buildAtlasPdf(
      options: options,
      coverage: coverage,
      markers: markers,
      zones: zones,
    );
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final saved = await saveBinaryFile(
      fileName: 'wayfinder-atlas-$timestamp.pdf',
      bytes: bytes,
    );
    if (!context.mounted) {
      return false;
    }
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapAtlasExportSuccess)),
      );
    }
    return saved;
  } catch (error, stackTrace) {
    _log.error(
      '🗺️ Map atlas export failed',
      error: error,
      stackTrace: stackTrace,
    );
    if (!context.mounted) {
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mapAtlasExportFailed(error.toString()))),
    );
    return false;
  }
}
