/// Parsed housenumber + street tokens from a free-form address query.
class AddressSearchQuery {
  const AddressSearchQuery({
    required this.housenumber,
    required this.streetTokens,
  });

  final String housenumber;
  final List<String> streetTokens;
}

/// Leading number plus remaining street words, e.g. "332 sherwood drive".
AddressSearchQuery? parseAddressSearchQuery(String input) {
  final trimmed = input.trim();
  final match = RegExp(r'^(\d[\d\-/A-Za-z]*)\s+(.+)$').firstMatch(trimmed);
  if (match == null) {
    return null;
  }

  final housenumber = match.group(1)!;
  final streetPart = match.group(2)!.trim();
  if (streetPart.length < 2) {
    return null;
  }

  final tokens = streetPart
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.isEmpty) {
    return null;
  }

  return AddressSearchQuery(
    housenumber: housenumber,
    streetTokens: tokens,
  );
}

/// Builds a parameterized housenumber + tokenized street search.
({String sql, Map<String, Object?> parameters}) buildStructuredAddressSearch(
  AddressSearchQuery query,
) {
  final parameters = <String, Object?>{
    'housenumber': _escapeLike(query.housenumber),
  };
  final conditions = <String>[
    '"housenumber" ILIKE @housenumber ESCAPE \'\\\'',
  ];

  for (var tokenIndex = 0; tokenIndex < query.streetTokens.length; tokenIndex++) {
    final patterns = _streetTokenLikePatterns(query.streetTokens[tokenIndex]);
    if (patterns.length == 1) {
      final key = 'streetToken$tokenIndex';
      parameters[key] = patterns.first;
      conditions.add('"street" ILIKE @$key ESCAPE \'\\\'');
      continue;
    }

    final orParts = <String>[];
    for (var variantIndex = 0; variantIndex < patterns.length; variantIndex++) {
      final key = 'streetToken${tokenIndex}_$variantIndex';
      parameters[key] = patterns[variantIndex];
      orParts.add('"street" ILIKE @$key ESCAPE \'\\\'');
    }
    conditions.add('(${orParts.join(' OR ')})');
  }

  final sql = '''
SELECT
  "id",
  "housenumber",
  "street",
  "latitude",
  "longitude"
FROM "geocode_housenumber"
WHERE ${conditions.join('\n  AND ')}
ORDER BY
  CASE
    WHEN lower("housenumber" || ' ' || "street") = lower(@exactLabel) THEN 0
    ELSE 1
  END,
  "street",
  "housenumber"
''';

  parameters['exactLabel'] =
      '${query.housenumber} ${query.streetTokens.join(' ')}';

  return (sql: sql, parameters: parameters);
}

List<String> _streetTokenLikePatterns(String token) {
  final variants = _streetTokenVariants(token);
  return variants.map((variant) => '%${_escapeLike(variant)}%').toList();
}

List<String> _streetTokenVariants(String token) {
  final lower = token.toLowerCase();
  for (final group in _streetSuffixGroups) {
    if (group.contains(lower)) {
      return group;
    }
  }
  return [token];
}

const _streetSuffixGroups = [
  ['avenue', 'ave'],
  ['boulevard', 'blvd'],
  ['circle', 'cir'],
  ['court', 'ct'],
  ['drive', 'dr'],
  ['lane', 'ln'],
  ['place', 'pl'],
  ['road', 'rd'],
  ['street', 'st'],
  ['terrace', 'ter'],
  ['way', 'wy'],
];

String _escapeLike(String input) {
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
}
