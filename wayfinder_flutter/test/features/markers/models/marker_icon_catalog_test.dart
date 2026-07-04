import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_catalog.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_categories.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_registry.dart';

void main() {
  test('merge replaces bundled SVG with server SVG url', () {
    final defaults = markerIconOptions
        .where((option) => option.key == 'horse')
        .toList(growable: false);
    final now = DateTime.utc(2026, 7, 3, 12);

    final catalog = MarkerIconCatalog.merge(
      defaults: defaults,
      remote: [
        MarkerIconCatalogEntry(
          key: 'horse',
          label: 'Horse',
          category: MarkerIconCategories.transportation,
          materialIcon: 'pets',
          coloredAsset: true,
          glyphScale: 0.94,
          hasCustomSvg: true,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      webBaseUrl: 'http://localhost:18082',
    );

    expect(catalog.asset('horse'), 'assets/markers/horse.svg');
    expect(
      catalog.svgUrl('horse'),
      'http://localhost:18082/marker-icons/files/horse.svg?v=${now.millisecondsSinceEpoch}',
    );
    expect(catalog.coloredAsset('horse'), isTrue);
    expect(
      catalog.option('horse')?.resolvedCategory,
      MarkerIconCategories.transportation,
    );
  });

  test('merge appends custom server-only icons', () {
    final now = DateTime.utc(2026, 7, 3, 12);
    final catalog = MarkerIconCatalog.merge(
      defaults: const [
        MarkerIconOption(key: 'place', icon: Icons.place, label: 'Place'),
      ],
      remote: [
        MarkerIconCatalogEntry(
          key: 'custom_drone',
          label: 'Drone',
          category: MarkerIconCategories.custom,
          materialIcon: 'flight',
          coloredAsset: false,
          glyphScale: 1.0,
          hasCustomSvg: true,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      webBaseUrl: 'http://localhost:18082',
    );

    expect(catalog.options.map((option) => option.key), [
      'place',
      'custom_drone',
    ]);
    expect(catalog.label('custom_drone'), 'Drone');
  });

  test('groupedByCategory uses built-in defaults and server overrides', () {
    final now = DateTime.utc(2026, 7, 3, 12);
    final catalog = MarkerIconCatalog.merge(
      defaults: markerIconOptions
          .where(
            (option) => option.key == 'place' || option.key == 'ambulance',
          )
          .toList(growable: false),
      remote: [
        MarkerIconCatalogEntry(
          key: 'ambulance',
          label: 'Ambulance',
          category: MarkerIconCategories.custom,
          materialIcon: 'local_hospital',
          coloredAsset: false,
          glyphScale: 1.0,
          hasCustomSvg: true,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      webBaseUrl: 'http://localhost:18082',
    );

    final grouped = catalog.groupedByCategory(
      categoryOrder: MarkerIconCategories.orderedKeys,
    );
    expect(grouped[MarkerIconCategories.general]?.map((o) => o.key), ['place']);
    expect(
      grouped[MarkerIconCategories.custom]?.map((o) => o.key),
      ['ambulance'],
    );
  });
}
