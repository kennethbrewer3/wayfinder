import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../web/rest/rest_json.dart';
import 'marker_icon_category_seed.dart';
import 'marker_icon_category_service.dart';
import 'marker_icon_key.dart';
import 'marker_icon_storage.dart';

/// JSON field holding raw SVG markup for a catalog entry.
const markerIconBackupSvgField = 'svgContent';

class MarkerIconRestoreCounts {
  const MarkerIconRestoreCounts({
    required this.categories,
    required this.icons,
  });

  final int categories;
  final int icons;

  Map<String, dynamic> toJson() => {
    'markerIconCategories': categories,
    'markerIcons': icons,
  };
}

Future<Map<String, dynamic>> exportMarkerIconBackup(Session session) async {
  await MarkerIconCategoryService.seedDefaultsIfEmpty(session);
  final categories = await MarkerIconCategoryService.listCategories(session);
  final entries = await MarkerIconCatalogEntry.db.find(
    session,
    orderBy: (t) => t.sortOrder,
  );

  final storage = MarkerIconStorage();
  await storage.ensureReady();

  final icons = <Map<String, dynamic>>[];
  for (final entry in entries) {
    final json = RestJson.encodeModel(entry);
    if (entry.hasCustomSvg && storage.exists(entry.key)) {
      final bytes = await storage.fileFor(entry.key).readAsBytes();
      json[markerIconBackupSvgField] = utf8.decode(bytes, allowMalformed: true);
    }
    icons.add(json);
  }

  return {
    'markerIconCategories': RestJson.encodeModels(categories),
    'markerIcons': icons,
  };
}

Future<MarkerIconRestoreCounts> restoreMarkerIconBackup(
  Session session,
  Map<String, dynamic> body,
) async {
  final categoriesRaw = body['markerIconCategories'];
  final iconsRaw = body['markerIcons'];
  if (categoriesRaw == null && iconsRaw == null) {
    return const MarkerIconRestoreCounts(categories: 0, icons: 0);
  }

  final categories = _parseModelList(
    categoriesRaw ?? const [],
    fieldName: 'markerIconCategories',
    fromJson: MarkerIconCategoryDefinition.fromJson,
  );
  final iconPayloads = _parseIconPayloads(iconsRaw ?? const []);

  final storage = MarkerIconStorage();
  await storage.ensureReady();

  final counts = await session.db.transaction((transaction) async {
    final existingIcons = await MarkerIconCatalogEntry.db.find(
      session,
      transaction: transaction,
    );
    for (final icon in existingIcons) {
      await storage.delete(icon.key);
      await MarkerIconCatalogEntry.db.deleteRow(
        session,
        icon,
        transaction: transaction,
      );
    }

    final existingCategories = await MarkerIconCategoryDefinition.db.find(
      session,
      transaction: transaction,
    );
    for (final category in existingCategories) {
      await MarkerIconCategoryDefinition.db.deleteRow(
        session,
        category,
        transaction: transaction,
      );
    }

    for (final category in categories) {
      await MarkerIconCategoryDefinition.db.insertRow(
        session,
        category,
        transaction: transaction,
      );
    }

    if (categories.isEmpty) {
      final now = DateTime.now().toUtc();
      for (final seed in MarkerIconCategorySeed.defaults) {
        await MarkerIconCategoryDefinition.db.insertRow(
          session,
          MarkerIconCategoryDefinition(
            key: seed.key,
            label: seed.label,
            sortOrder: seed.sortOrder,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      }
    }

    final effectiveCategories = categories.isEmpty
        ? await MarkerIconCategoryDefinition.db.find(
            session,
            transaction: transaction,
          )
        : categories;
    final categoryKeys =
        effectiveCategories.map((category) => category.key).toSet();
    final fallbackCategory = effectiveCategories.isEmpty
        ? MarkerIconCategorySeed.defaultCategoryKey
        : effectiveCategories.first.key;

    for (final payload in iconPayloads) {
      final entry = payload.entry;
      final resolvedCategory = categoryKeys.contains(entry.category)
          ? entry.category
          : fallbackCategory;
      final saved = await MarkerIconCatalogEntry.db.insertRow(
        session,
        entry.copyWith(
          category: resolvedCategory,
          hasCustomSvg: payload.svgContent != null,
        ),
        transaction: transaction,
      );
      if (payload.svgContent != null) {
        await storage.writeBytes(
          saved.key,
          Uint8List.fromList(utf8.encode(payload.svgContent!)),
        );
      }
    }

    return MarkerIconRestoreCounts(
      categories: categories.length,
      icons: iconPayloads.length,
    );
  });

  return counts;
}

class _MarkerIconBackupPayload {
  const _MarkerIconBackupPayload({
    required this.entry,
    this.svgContent,
  });

  final MarkerIconCatalogEntry entry;
  final String? svgContent;
}

List<_MarkerIconBackupPayload> _parseIconPayloads(Object? raw) {
  if (raw is! List) {
    throw FormatException('Field "markerIcons" must be a JSON array');
  }

  return [
    for (final entry in raw)
      if (entry is Map<String, dynamic>) _parseIconPayload(entry)
      else
        throw FormatException('Each entry in "markerIcons" must be a JSON object'),
  ];
}

_MarkerIconBackupPayload _parseIconPayload(Map<String, dynamic> json) {
  final svgRaw = json[markerIconBackupSvgField];
  String? svgContent;
  if (svgRaw != null) {
    if (svgRaw is! String || svgRaw.trim().isEmpty) {
      throw FormatException(
        'Field "$markerIconBackupSvgField" must be a non-empty SVG string',
      );
    }
    svgContent = svgRaw;
    if (!svgContent.contains('<svg')) {
      throw FormatException(
        'Field "$markerIconBackupSvgField" does not look like SVG content',
      );
    }
  }

  final modelJson = Map<String, dynamic>.from(json)..remove(markerIconBackupSvgField);
  final entry = MarkerIconCatalogEntry.fromJson(modelJson);
  MarkerIconKey.normalize(entry.key);

  return _MarkerIconBackupPayload(
    entry: entry,
    svgContent: svgContent,
  );
}

List<T> _parseModelList<T>(
  Object? raw, {
  required String fieldName,
  required T Function(Map<String, dynamic>) fromJson,
}) {
  if (raw is! List) {
    throw FormatException('Field "$fieldName" must be a JSON array');
  }

  return [
    for (final entry in raw)
      if (entry is Map<String, dynamic>)
        fromJson(entry)
      else
        throw FormatException(
          'Each entry in "$fieldName" must be a JSON object',
        ),
  ];
}
