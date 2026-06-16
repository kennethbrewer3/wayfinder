enum RectangleSizeDisplay {
  dimensions,
  area,
  none,
}

extension RectangleSizeDisplayLabel on RectangleSizeDisplay {
  String get label => switch (this) {
        RectangleSizeDisplay.dimensions => 'Dimensions',
        RectangleSizeDisplay.area => 'Area',
        RectangleSizeDisplay.none => 'None',
      };

  String get shortLabel => switch (this) {
        RectangleSizeDisplay.dimensions => 'W×H',
        RectangleSizeDisplay.area => 'Area',
        RectangleSizeDisplay.none => 'None',
      };
}

RectangleSizeDisplay rectangleSizeDisplayFromJson(String? value) {
  return switch (value) {
    'area' => RectangleSizeDisplay.area,
    'none' => RectangleSizeDisplay.none,
    _ => RectangleSizeDisplay.dimensions,
  };
}

String rectangleSizeDisplayToJson(RectangleSizeDisplay display) {
  return switch (display) {
    RectangleSizeDisplay.dimensions => 'dimensions',
    RectangleSizeDisplay.area => 'area',
    RectangleSizeDisplay.none => 'none',
  };
}

RectangleSizeDisplay nextRectangleSizeDisplay(RectangleSizeDisplay current) {
  return switch (current) {
    RectangleSizeDisplay.dimensions => RectangleSizeDisplay.area,
    RectangleSizeDisplay.area => RectangleSizeDisplay.none,
    RectangleSizeDisplay.none => RectangleSizeDisplay.dimensions,
  };
}

String rectangleSizeDisplayToggleTooltip(RectangleSizeDisplay display) {
  return switch (display) {
    RectangleSizeDisplay.dimensions =>
      'Showing width × height on map · tap for area',
    RectangleSizeDisplay.area => 'Showing area on map · tap for none',
    RectangleSizeDisplay.none => 'Size hidden on map · tap for dimensions',
  };
}
