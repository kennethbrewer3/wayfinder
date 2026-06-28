const geocodingSampleSourceUrl =
    'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest-100k_geonames.tsv.gz';

const geocodingPlanetSourceUrl =
    'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_geonames.tsv.gz';

const geocodingHousenumbersSourceUrl =
    'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_housenumbers.tsv.gz';

/// Preset datasets users can pick in settings.
class GeocodingDatasetOption {
  const GeocodingDatasetOption({
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

  bool get usesPlanetDownload => sourceUrl == geocodingPlanetSourceUrl;

  bool get isCustom => id == 'custom';

  bool get isFullPlanet => id == 'planet';

  bool get isSample => id == 'sample';

  String get countryCodesValue =>
      countryCodes.map((code) => code.toUpperCase()).join(',');

  factory GeocodingDatasetOption.fromServerJson(Map<String, dynamic> json) {
    final countryCodesRaw = json['countryCodes'];
    final countryCodes = countryCodesRaw is List
        ? countryCodesRaw
            .whereType<String>()
            .map((code) => code.trim().toUpperCase())
            .where((code) => code.length == 2)
            .toList()
        : const <String>[];
    return GeocodingDatasetOption(
      id: json['id'] as String,
      label: json['label'] as String,
      sourceUrl: json['sourceUrl'] as String? ?? '',
      countryCodes: countryCodes,
      description: json['description'] as String?,
    );
  }

  static GeocodingDatasetOption? byId(String id) {
    for (final option in geocodingDatasetOptions) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  static GeocodingDatasetOption match({
    required String sourceUrl,
    required String? countryCodes,
    List<GeocodingDatasetOption> options = geocodingDatasetOptions,
  }) {
    final normalizedCodes = _normalizeCountryCodes(countryCodes);
    for (final option in options) {
      if (option.isCustom) {
        continue;
      }
      if (option.sourceUrl == sourceUrl &&
          _normalizeCountryCodes(option.countryCodesValue) ==
              normalizedCodes) {
        return option;
      }
    }
    return options.last;
  }
}

String _normalizeCountryCodes(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return '';
  }
  final codes = raw
      .split(',')
      .map((code) => code.trim().toUpperCase())
      .where((code) => code.length == 2)
      .toList()
    ..sort();
  return codes.join(',');
}

const geocodingDatasetOptions = <GeocodingDatasetOption>[
  GeocodingDatasetOption(
    id: 'sample',
    label: 'Sample (100k places)',
    sourceUrl: geocodingSampleSourceUrl,
    description:
        'A small preview dataset. Best for testing search in a few minutes.',
  ),
  GeocodingDatasetOption(
    id: 'planet',
    label: 'Full planet (~23M places)',
    sourceUrl: geocodingPlanetSourceUrl,
    description:
        'Imports every place in the OSMNames planet file. The download is about 1.4 GB compressed and the import can take many hours depending on your server hardware and network speed.',
  ),
  GeocodingDatasetOption(
    id: 'us',
    label: 'United States',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['US'],
    description:
        'Downloads the global OSMNames file but only imports United States places. The download is still large, but the database import is much faster than the full planet.',
  ),
  GeocodingDatasetOption(
    id: 'ca',
    label: 'Canada',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['CA'],
    description:
        'Downloads the global OSMNames file but only imports Canadian places.',
  ),
  GeocodingDatasetOption(
    id: 'mx',
    label: 'Mexico',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['MX'],
  ),
  GeocodingDatasetOption(
    id: 'gb',
    label: 'United Kingdom',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['GB'],
  ),
  GeocodingDatasetOption(
    id: 'de',
    label: 'Germany',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['DE'],
  ),
  GeocodingDatasetOption(
    id: 'fr',
    label: 'France',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['FR'],
  ),
  GeocodingDatasetOption(
    id: 'es',
    label: 'Spain',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['ES'],
  ),
  GeocodingDatasetOption(
    id: 'it',
    label: 'Italy',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['IT'],
  ),
  GeocodingDatasetOption(
    id: 'nl',
    label: 'Netherlands',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['NL'],
  ),
  GeocodingDatasetOption(
    id: 'au',
    label: 'Australia',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['AU'],
  ),
  GeocodingDatasetOption(
    id: 'nz',
    label: 'New Zealand',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['NZ'],
  ),
  GeocodingDatasetOption(
    id: 'jp',
    label: 'Japan',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['JP'],
  ),
  GeocodingDatasetOption(
    id: 'br',
    label: 'Brazil',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['BR'],
  ),
  GeocodingDatasetOption(
    id: 'in',
    label: 'India',
    sourceUrl: geocodingPlanetSourceUrl,
    countryCodes: ['IN'],
  ),
  GeocodingDatasetOption(
    id: 'custom',
    label: 'Custom URL…',
    sourceUrl: '',
    description: 'Provide your own OSMNames .tsv.gz URL.',
  ),
];

/// Shared copy for long-running import warnings shown in settings.
const geocodingPlanetImportWarning =
    'The full planet import downloads about 1.4 GB and can take many hours to finish. '
    'For most users, start with the sample dataset or import a single country instead.';

const geocodingCountryImportDownloadNote =
    'Country imports still download the global OSMNames file (~1.4 GB), but only the '
    'selected country is loaded into the database, so import finishes much sooner than the full planet.';

const geocodingHousenumbersImportWarning =
    'The housenumbers file is separate from place names and is also about 1.4 GB compressed. '
    'Import can take many hours and loads street addresses (house number + street) worldwide. '
    'Place-name search and address search work independently.';
