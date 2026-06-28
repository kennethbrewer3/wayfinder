import 'geocoding_datasets.dart';

class GeocodingCountryOption {
  const GeocodingCountryOption({required this.code, required this.name});

  final String code;
  final String name;

  factory GeocodingCountryOption.fromJson(Map<String, dynamic> json) {
    return GeocodingCountryOption(
      code: (json['code'] as String).trim().toUpperCase(),
      name: (json['name'] as String).trim(),
    );
  }

  String get displayLabel => '$name ($code)';
}

class GeocodingCountryCatalog {
  const GeocodingCountryCatalog({
    required this.countries,
    required this.importPresets,
  });

  final List<GeocodingCountryOption> countries;
  final List<GeocodingDatasetOption> importPresets;

  factory GeocodingCountryCatalog.fromJson(Map<String, dynamic> json) {
    final countryItems = json['countries'];
    final presetItems = json['importPresets'];
    return GeocodingCountryCatalog(
      countries: countryItems is List
          ? countryItems
              .whereType<Map>()
              .map(
                (item) => GeocodingCountryOption.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      importPresets: presetItems is List
          ? presetItems
              .whereType<Map>()
              .map(
                (item) => GeocodingDatasetOption.fromServerJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }

  static GeocodingCountryCatalog fallback() {
    final countries = <String, GeocodingCountryOption>{};
    for (final preset in geocodingDatasetOptions) {
      for (final code in preset.countryCodes) {
        countries.putIfAbsent(
          code,
          () => GeocodingCountryOption(code: code, name: preset.label),
        );
      }
    }
    return GeocodingCountryCatalog(
      countries: countries.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name)),
      importPresets: geocodingDatasetOptions,
    );
  }

  GeocodingCountryOption? findCountry(String? code) {
    if (code == null || code.trim().isEmpty) {
      return null;
    }
    final normalized = code.trim().toUpperCase();
    for (final country in countries) {
      if (country.code == normalized) {
        return country;
      }
    }
    return null;
  }

  String? defaultCountryCode(String? settingsCountryCodes) {
    final codes = parseCountryCodeList(settingsCountryCodes);
    if (codes.isEmpty) {
      return null;
    }
    return codes.first;
  }
}

List<String> parseCountryCodeList(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  return raw
      .split(',')
      .map((code) => code.trim().toUpperCase())
      .where((code) => code.length == 2)
      .toList();
}
