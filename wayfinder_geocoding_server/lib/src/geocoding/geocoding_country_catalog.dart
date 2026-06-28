import 'dart:convert';
import 'dart:io';

import 'geocoding_constants.dart';

/// ISO 3166-1 alpha-2 codes and OSMNames import presets served to clients.
abstract final class GeocodingCountryCatalog {
  static List<GeocodingCountryEntry>? _countriesCache;

  static const importPresets = <GeocodingImportPreset>[
    GeocodingImportPreset(
      id: 'sample',
      label: 'Sample (100k places)',
      sourceUrl: GeocodingConstants.sampleSourceUrl,
      description:
          'A small preview dataset. Best for testing search in a few minutes.',
    ),
    GeocodingImportPreset(
      id: 'planet',
      label: 'Full planet (~23M places)',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      description:
          'Imports every place in the OSMNames planet file. The download is about 1.4 GB compressed and the import can take many hours depending on your server hardware and network speed.',
    ),
    GeocodingImportPreset(
      id: 'us',
      label: 'United States',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['US'],
      description:
          'Downloads the global OSMNames file but only imports United States places. The download is still large, but the database import is much faster than the full planet.',
    ),
    GeocodingImportPreset(
      id: 'ca',
      label: 'Canada',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['CA'],
      description:
          'Downloads the global OSMNames file but only imports Canadian places.',
    ),
    GeocodingImportPreset(
      id: 'mx',
      label: 'Mexico',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['MX'],
    ),
    GeocodingImportPreset(
      id: 'gb',
      label: 'United Kingdom',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['GB'],
    ),
    GeocodingImportPreset(
      id: 'de',
      label: 'Germany',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['DE'],
    ),
    GeocodingImportPreset(
      id: 'fr',
      label: 'France',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['FR'],
    ),
    GeocodingImportPreset(
      id: 'es',
      label: 'Spain',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['ES'],
    ),
    GeocodingImportPreset(
      id: 'it',
      label: 'Italy',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['IT'],
    ),
    GeocodingImportPreset(
      id: 'nl',
      label: 'Netherlands',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['NL'],
    ),
    GeocodingImportPreset(
      id: 'au',
      label: 'Australia',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['AU'],
    ),
    GeocodingImportPreset(
      id: 'nz',
      label: 'New Zealand',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['NZ'],
    ),
    GeocodingImportPreset(
      id: 'jp',
      label: 'Japan',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['JP'],
    ),
    GeocodingImportPreset(
      id: 'br',
      label: 'Brazil',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['BR'],
    ),
    GeocodingImportPreset(
      id: 'in',
      label: 'India',
      sourceUrl: GeocodingConstants.defaultSourceUrl,
      countryCodes: ['IN'],
    ),
    GeocodingImportPreset(
      id: 'custom',
      label: 'Custom URL…',
      sourceUrl: '',
      description: 'Provide your own OSMNames .tsv.gz URL.',
    ),
  ];

  static List<GeocodingCountryEntry> countries() {
    return _countriesCache ??= _loadCountries();
  }

  static Map<String, Object?> toJson() {
    return {
      'countries': [
        for (final country in countries())
          {'code': country.code, 'name': country.name},
      ],
      'importPresets': [
        for (final preset in importPresets) preset.toJson(),
      ],
    };
  }

  static List<GeocodingCountryEntry> _loadCountries() {
    for (final path in _countryDataPaths) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is! List) {
          continue;
        }
        final entries = <GeocodingCountryEntry>[];
        for (final item in decoded) {
          if (item is! Map) {
            continue;
          }
          final code = (item['code'] as String?)?.trim().toUpperCase();
          final name = (item['name'] as String?)?.trim();
          if (code == null ||
              code.length != 2 ||
              name == null ||
              name.isEmpty) {
            continue;
          }
          entries.add(GeocodingCountryEntry(code: code, name: name));
        }
        if (entries.isNotEmpty) {
          entries.sort((a, b) => a.name.compareTo(b.name));
          return entries;
        }
      } catch (_) {
        continue;
      }
    }

    return _fallbackCountries();
  }

  static List<GeocodingCountryEntry> _fallbackCountries() {
    final codes = <String>{};
    for (final preset in importPresets) {
      codes.addAll(preset.countryCodes);
    }
    return [
      for (final code in codes)
        GeocodingCountryEntry(code: code, name: code),
    ]..sort((a, b) => a.code.compareTo(b.code));
  }

  static const _countryDataPaths = [
    'lib/src/geocoding/data/country_codes.json',
    'wayfinder_geocoding_server/lib/src/geocoding/data/country_codes.json',
  ];
}

final class GeocodingCountryEntry {
  const GeocodingCountryEntry({required this.code, required this.name});

  final String code;
  final String name;
}

final class GeocodingImportPreset {
  const GeocodingImportPreset({
    required this.id,
    required this.label,
    required this.sourceUrl,
    this.countryCodes = const [],
    this.description,
  });

  final String id;
  final String label;
  final String sourceUrl;
  final List<String> countryCodes;
  final String? description;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'label': label,
      'sourceUrl': sourceUrl,
      'countryCodes': countryCodes,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}
