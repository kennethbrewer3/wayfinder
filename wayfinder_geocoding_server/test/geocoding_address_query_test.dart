import 'package:test/test.dart';
import 'package:wayfinder_geocoding_server/src/geocoding/geocoding_address_query.dart';

void main() {
  group('parseAddressSearchQuery', () {
    test('parses housenumber and street tokens', () {
      final parsed = parseAddressSearchQuery('332 sherwood drive');
      expect(parsed, isNotNull);
      expect(parsed!.housenumber, '332');
      expect(parsed.streetTokens, ['sherwood', 'drive']);
    });

    test('returns null without a leading housenumber', () {
      expect(parseAddressSearchQuery('sherwood drive'), isNull);
    });
  });

  group('buildStructuredAddressSearch', () {
    test('matches drive and dr suffix variants', () {
      final parsed = parseAddressSearchQuery('332 sherwood drive')!;
      final built = buildStructuredAddressSearch(parsed);

      expect(built.sql, contains('"housenumber" ILIKE @housenumber'));
      expect(built.sql, contains('"street" ILIKE @streetToken0'));
      expect(built.sql, contains('"street" ILIKE @streetToken1_0'));
      expect(built.sql, contains('"street" ILIKE @streetToken1_1'));
      expect(built.parameters['streetToken1_0'], '%drive%');
      expect(built.parameters['streetToken1_1'], '%dr%');
    });
  });
}
