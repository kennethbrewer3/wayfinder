import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import 'marker_icon_categories.dart';
import 'marker_color.dart';
import 'marker_icon_registry.dart';

/// Runtime marker icon catalog merged from built-in defaults and server entries.
class MarkerIconCatalog {
  const MarkerIconCatalog(this.options);

  final List<MarkerIconOption> options;

  factory MarkerIconCatalog.defaults() =>
      MarkerIconCatalog(List<MarkerIconOption>.from(markerIconOptions));

  factory MarkerIconCatalog.merge({
    required List<MarkerIconOption> defaults,
    required List<MarkerIconCatalogEntry> remote,
    required String webBaseUrl,
  }) {
    final byKey = {for (final option in defaults) option.key: option};
    final defaultKeys = defaults.map((option) => option.key).toSet();
    final remoteOnly = <MarkerIconCatalogEntry>[];

    for (final entry in remote) {
      final existing = byKey[entry.key];
      final svgUrl = entry.hasCustomSvg
          ? _svgUrl(webBaseUrl, entry.key, entry.updatedAt)
          : null;
      byKey[entry.key] = MarkerIconOption(
        key: entry.key,
        icon: existing?.icon ?? materialIconFromServerKey(entry.materialIcon),
        label: entry.label,
        assetPath: svgUrl == null ? existing?.assetPath : null,
        svgUrl: svgUrl,
        emoji: existing?.emoji,
        coloredAsset: entry.coloredAsset,
        glyphScale: entry.glyphScale,
        category: entry.category,
        iconBackgroundColor: entry.iconBackgroundColor,
      );
      if (!defaultKeys.contains(entry.key)) {
        remoteOnly.add(entry);
      }
    }

    remoteOnly.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final merged = <MarkerIconOption>[
      for (final option in defaults)
        if (byKey.containsKey(option.key)) byKey[option.key]!,
      for (final entry in remoteOnly) byKey[entry.key]!,
    ];

    return MarkerIconCatalog(merged);
  }

  MarkerIconOption? option(String iconName) {
    for (final option in options) {
      if (option.key == iconName) {
        return option;
      }
    }
    return null;
  }

  IconData data(String iconName) => option(iconName)?.icon ?? Icons.place;

  String label(String iconName) => option(iconName)?.label ?? 'Place';

  String normalize(String iconName) =>
      option(iconName) == null ? 'place' : iconName;

  String? asset(String iconName) => option(iconName)?.assetPath;

  String? svgUrl(String iconName) => option(iconName)?.svgUrl;

  String? emoji(String iconName) => option(iconName)?.emoji;

  double glyphScale(String iconName) => option(iconName)?.glyphScale ?? 1.0;

  bool coloredAsset(String iconName) => option(iconName)?.coloredAsset ?? false;

  String iconBackgroundColorHex(String iconName) =>
      option(iconName)?.iconBackgroundColor ?? '#FFFFFF';

  Color iconBackgroundColor(String iconName) =>
      parseMarkerColor(iconBackgroundColorHex(iconName));

  /// Icons grouped by category key in display order.
  Map<String, List<MarkerIconOption>> groupedByCategory({
    List<String>? categoryOrder,
  }) {
    final grouped = <String, List<MarkerIconOption>>{};
    for (final option in options) {
      grouped.putIfAbsent(option.resolvedCategory, () => []).add(option);
    }

    final order = categoryOrder ?? MarkerIconCategories.orderedKeys;
    final ordered = <String, List<MarkerIconOption>>{};
    for (final category in order) {
      final items = grouped.remove(category);
      if (items != null && items.isNotEmpty) {
        ordered[category] = items;
      }
    }
    for (final entry in grouped.entries) {
      ordered[entry.key] = entry.value;
    }
    return ordered;
  }

  static String _svgUrl(String webBaseUrl, String key, DateTime updatedAt) {
    final base = webBaseUrl.endsWith('/')
        ? webBaseUrl.substring(0, webBaseUrl.length - 1)
        : webBaseUrl;
    final version = updatedAt.toUtc().millisecondsSinceEpoch;
    return '$base/marker-icons/files/$key.svg?v=$version';
  }
}

IconData materialIconFromServerKey(String? materialIcon) {
  if (materialIcon == null || materialIcon.isEmpty) {
    return Icons.place;
  }
  for (final option in markerIconOptions) {
    if (option.key == materialIcon) {
      return option.icon;
    }
  }
  return Icons.place;
}
