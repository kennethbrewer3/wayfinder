import 'dart:math' as math;

class LineArrowDensity {
  const LineArrowDensity(this.level);

  static const minLevel = 1;
  static const maxLevel = 5;
  static const defaultLevel = 3;

  final int level;

  static LineArrowDensity fromLevel(int? value) {
    final normalized = (value ?? defaultLevel).clamp(minLevel, maxLevel);
    return LineArrowDensity(normalized);
  }

  double get spacingMeters => switch (level) {
        1 => 150.0,
        2 => 112.0,
        3 => 75.0,
        4 => 50.0,
        5 => 38.0,
        _ => 75.0,
      };

  int get maxArrowsPerLine => switch (level) {
        1 => 8,
        2 => 12,
        3 => 16,
        4 => 20,
        5 => 24,
        _ => 16,
      };

  double get minArrowSpacingPixels => switch (level) {
        1 => 64.0,
        2 => 56.0,
        3 => 48.0,
        4 => 40.0,
        5 => 32.0,
        _ => 48.0,
      };

  int arrowCountForPath({
    required double totalMeters,
    required double totalPixels,
  }) {
    var count = math.max(1, (totalMeters / spacingMeters).round());
    final maxByPixels =
        math.max(1, (totalPixels / minArrowSpacingPixels).floor());
    count = math.min(count, maxByPixels);
    return math.min(count, maxArrowsPerLine);
  }
}

int lineArrowDensityToStorage(LineArrowDensity density) => density.level;

LineArrowDensity lineArrowDensityFromStorage(int? value) =>
    LineArrowDensity.fromLevel(value);
