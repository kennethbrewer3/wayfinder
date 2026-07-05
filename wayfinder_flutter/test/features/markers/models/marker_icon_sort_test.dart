import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_sort.dart';

void main() {
  test('compareMarkerIconDisplayLabels is case-insensitive', () {
    expect(compareMarkerIconDisplayLabels('Alpha', 'beta'), lessThan(0));
    expect(compareMarkerIconDisplayLabels('alpha', 'Beta'), lessThan(0));
    expect(compareMarkerIconDisplayLabels('Same', 'same'), 0);
  });
}
