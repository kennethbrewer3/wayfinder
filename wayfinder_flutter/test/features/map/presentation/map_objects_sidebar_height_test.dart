import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/map/presentation/map_screen.dart';

void main() {
  test('portrait phone keeps a substantial expanded sheet', () {
    expect(mapObjectsSidebarExpandedHeight(844), closeTo(405.12, 0.01));
  });

  test('landscape phone does not force 320px over a short body', () {
    final height = mapObjectsSidebarExpandedHeight(390);
    expect(height, lessThan(390 * 0.56));
    expect(height, greaterThanOrEqualTo(120));
    // Leaves room for the map + app chrome.
    expect(height, lessThanOrEqualTo(390 * 0.55));
  });

  test('very short heights stay within the screen', () {
    expect(
      mapObjectsSidebarExpandedHeight(200),
      closeTo(200 * 0.55, 0.01),
    );
  });
}
