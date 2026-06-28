import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/map/utils/pmtiles_archive_selection.dart';
import 'package:wayfinder_flutter/features/settings/models/pmtiles_archive_entry.dart';
import 'package:wayfinder_flutter/features/settings/models/pmtiles_geo_bounds.dart';
import 'package:wayfinder_flutter/features/settings/models/pmtiles_source.dart';

void main() {
  PmtilesArchiveEntry entry(String name) {
    return PmtilesArchiveEntry(
      id: name,
      name: name,
      source: PmtilesSourcePath('/tmp/$name'),
      bounds: const PmtilesGeoBounds(
        south: 36,
        west: -84,
        north: 40,
        east: -75,
      ),
      boundsKnown: true,
      minZoom: 0,
      maxZoom: 15,
    );
  }

  group('compareArchiveCenterTileScores', () {
    test('prefers higher probe zoom over higher feature count', () {
      final virginia = ArchiveCenterTileScore(
        entry: entry('virginia'),
        tileFound: true,
        tileZoom: 15,
        featureCount: 1036,
        mapFeatureCount: 1031,
      );
      final globalMin = ArchiveCenterTileScore(
        entry: entry('global-min'),
        tileFound: true,
        tileZoom: 7,
        featureCount: 1436,
        mapFeatureCount: 1426,
      );

      expect(compareArchiveCenterTileScores(virginia, globalMin), isNegative);
      expect(compareArchiveCenterTileScores(globalMin, virginia), isPositive);
    });

    test('breaks ties by map feature count at the same zoom', () {
      final richer = ArchiveCenterTileScore(
        entry: entry('virginia'),
        tileFound: true,
        tileZoom: 15,
        featureCount: 1100,
        mapFeatureCount: 1050,
      );
      final sparser = ArchiveCenterTileScore(
        entry: entry('maryland'),
        tileFound: true,
        tileZoom: 15,
        featureCount: 900,
        mapFeatureCount: 850,
      );

      expect(compareArchiveCenterTileScores(richer, sparser), isNegative);
      expect(compareArchiveCenterTileScores(sparser, richer), isPositive);
    });
  });
}
