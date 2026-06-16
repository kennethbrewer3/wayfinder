enum CircleSizeDisplay {
  radius,
  diameter,
  none,
}

extension CircleSizeDisplayLabel on CircleSizeDisplay {
  String get label => switch (this) {
        CircleSizeDisplay.radius => 'Radius',
        CircleSizeDisplay.diameter => 'Diameter',
        CircleSizeDisplay.none => 'None',
      };

  String get shortLabel => switch (this) {
        CircleSizeDisplay.radius => 'Radius',
        CircleSizeDisplay.diameter => 'Diameter',
        CircleSizeDisplay.none => 'None',
      };
}

CircleSizeDisplay circleSizeDisplayFromStorage(String? value) {
  return switch (value) {
    'diameter' => CircleSizeDisplay.diameter,
    'none' => CircleSizeDisplay.none,
    _ => CircleSizeDisplay.radius,
  };
}

CircleSizeDisplay circleSizeDisplayFromJson(String? value) {
  return circleSizeDisplayFromStorage(value);
}

String circleSizeDisplayToStorage(CircleSizeDisplay display) {
  return switch (display) {
    CircleSizeDisplay.radius => 'radius',
    CircleSizeDisplay.diameter => 'diameter',
    CircleSizeDisplay.none => 'none',
  };
}

CircleSizeDisplay nextCircleSizeDisplay(CircleSizeDisplay current) {
  return switch (current) {
    CircleSizeDisplay.radius => CircleSizeDisplay.diameter,
    CircleSizeDisplay.diameter => CircleSizeDisplay.none,
    CircleSizeDisplay.none => CircleSizeDisplay.radius,
  };
}

String circleSizeDisplayToggleTooltip(CircleSizeDisplay display) {
  return switch (display) {
    CircleSizeDisplay.radius => 'Showing radius on map · tap for diameter',
    CircleSizeDisplay.diameter => 'Showing diameter on map · tap for none',
    CircleSizeDisplay.none => 'Size hidden on map · tap for radius',
  };
}
