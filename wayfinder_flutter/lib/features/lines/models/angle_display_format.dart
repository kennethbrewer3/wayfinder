enum AngleDisplayFormat {
  decimal,
  degreesMinutesSeconds,
}

extension AngleDisplayFormatLabel on AngleDisplayFormat {
  String get label => switch (this) {
        AngleDisplayFormat.decimal => 'Decimal degrees',
        AngleDisplayFormat.degreesMinutesSeconds => 'Degrees, minutes, seconds',
      };

  String get shortLabel => switch (this) {
        AngleDisplayFormat.decimal => 'DD',
        AngleDisplayFormat.degreesMinutesSeconds => 'DMS',
      };
}

AngleDisplayFormat angleDisplayFormatFromStorage(String? value) {
  return switch (value) {
    'dms' || 'degreesMinutesSeconds' => AngleDisplayFormat.degreesMinutesSeconds,
    _ => AngleDisplayFormat.decimal,
  };
}

String angleDisplayFormatToStorage(AngleDisplayFormat format) {
  return switch (format) {
    AngleDisplayFormat.decimal => 'decimal',
    AngleDisplayFormat.degreesMinutesSeconds => 'dms',
  };
}
