import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../../comms_plan/models/comms_card_of_the_day.dart';
import '../../comms_plan/models/comms_challenge_table.dart';
import '../../comms_plan/models/comms_one_time_pad.dart';
import '../../comms_plan/providers/comms_plan_provider.dart';
import '../../map/providers/map_mgrs_grid_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../settings/providers/pmtiles_providers.dart';
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
    final enabledPmtiles = await ref.read(
      pmtilesEnabledMetadataProvider.future,
    );
    final includeMgrsGrid = ref.read(mapMgrsGridEnabledProvider);
    final routeExport = buildAtlasRouteExport(ref: ref, l10n: l10n);
    AtlasCommsChallengeExport? challengeExport;
    AtlasCommsOneTimePadExport? oneTimePadExport;
    AtlasCommsCardOfTheDayExport? cardOfTheDayExport;
    if (options.includeCommsChallengeTable ||
        options.includeCommsOneTimePad ||
        options.includeCommsCardOfTheDay) {
      final plans = ref.read(commsPlansProvider).valueOrNull ?? const [];
      final active = activeCommsPlan(plans);
      if (options.includeCommsChallengeTable) {
        final tables = decodeCommsChallengeTables(active?.challengeTableJson);
        if (active != null && tables.isNotEmpty) {
          challengeExport = AtlasCommsChallengeExport(
            planName: active.name,
            tables: tables,
            title: l10n.commsChallengeTableTitle,
            instructions: l10n.commsChallengeTableInstructions,
            generatedLabel: l10n.commsChallengeTableGeneratedPrefix,
          );
        }
      }
      if (options.includeCommsOneTimePad) {
        final pads = decodeCommsOneTimePads(active?.oneTimePadJson);
        if (active != null && pads.isNotEmpty) {
          oneTimePadExport = AtlasCommsOneTimePadExport(
            planName: active.name,
            pads: pads,
            title: l10n.commsOneTimePadTitle,
            instructions: l10n.commsOneTimePadInstructions,
            generatedLabel: l10n.commsOneTimePadGeneratedPrefix,
          );
        }
      }
      if (options.includeCommsCardOfTheDay) {
        final cards = decodeCommsCardsOfTheDay(active?.cardOfTheDayJson);
        if (active != null && cards.isNotEmpty) {
          cardOfTheDayExport = AtlasCommsCardOfTheDayExport(
            planName: active.name,
            cards: cards,
            title: l10n.commsCardOfTheDayTitle,
            instructions: l10n.commsCardOfTheDayInstructions,
            dateLabel: l10n.commsCardOfTheDayDatePrefix,
            digitKeyTitle: l10n.commsCardOfTheDayDigitKeyTitle,
            itemColumn: l10n.commsCardOfTheDayItemLabel,
            codeWordColumn: l10n.commsCardOfTheDayCodeWordLabel,
            placesTitle: l10n.commsCardOfTheDayPlaces,
            peopleTitle: l10n.commsCardOfTheDayPeople,
            objectsTitle: l10n.commsCardOfTheDayObjects,
            directionsTitle: l10n.commsCardOfTheDayDirections,
            conditionsTitle: l10n.commsCardOfTheDayConditions,
            otherTitle: l10n.commsCardOfTheDayOther,
            emptyCategory: l10n.commsCardOfTheDayCategoryEmpty,
            digitKeyMissing: l10n.commsCardOfTheDayDigitKeyMissing,
          );
        }
      }
    }
    if (!context.mounted) {
      return false;
    }

    final bytes = await buildAtlasPdf(
      options: options,
      coverage: coverage,
      markers: markers,
      zones: zones,
      enabledPmtiles: enabledPmtiles,
      includeMgrsGrid: includeMgrsGrid,
      route: routeExport,
      challengeTable: challengeExport,
      oneTimePad: oneTimePadExport,
      cardOfTheDay: cardOfTheDayExport,
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
