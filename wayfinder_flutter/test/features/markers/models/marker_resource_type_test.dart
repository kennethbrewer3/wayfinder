import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_resource_type.dart';

void main() {
  test('tryParse accepts known wire values', () {
    expect(MarkerResourceType.tryParse('spring'), MarkerResourceType.spring);
    expect(MarkerResourceType.tryParse('WELL'), MarkerResourceType.well);
    expect(MarkerResourceType.tryParse('unknown'), isNull);
    expect(MarkerResourceType.tryParse(null), isNull);
  });

  test('resource filters match only persisted types', () {
    final well = MapMarker(
      name: 'Well',
      latitude: 0,
      longitude: 0,
      color: '#000000',
      icon: 'water_well',
      visible: true,
      resourceType: 'well',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final untypedWellIcon = MapMarker(
      name: 'Looks like a well',
      latitude: 0,
      longitude: 0,
      color: '#000000',
      icon: 'water_well',
      visible: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    expect(
      markerMatchesResourceTypeFilter(well, {MarkerResourceType.well}),
      isTrue,
    );
    expect(
      markerMatchesResourceTypeFilter(untypedWellIcon, {
        MarkerResourceType.well,
      }),
      isFalse,
    );
    expect(markerMatchesResourceTypeFilter(untypedWellIcon, {}), isTrue);
  });
}
