import 'package:wayfinder_client/wayfinder_client.dart' as wf;

import '../../../app/app_locale_choice.dart';
import '../../../app/app_theme_choice.dart';
import '../../circles/models/circle_size_display.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/line_arrow_density.dart';
import '../../lines/models/measurement_units.dart';

class ClientPreferences {
  const ClientPreferences({
    required this.measurementUnits,
    required this.angleDisplayFormat,
    required this.circleSizeDisplay,
    required this.appTheme,
    required this.appLocale,
    required this.lineArrowDensity,
  });

  final MeasurementUnits measurementUnits;
  final AngleDisplayFormat angleDisplayFormat;
  final CircleSizeDisplay circleSizeDisplay;
  final AppThemeChoice appTheme;
  final AppLocaleChoice appLocale;
  final LineArrowDensity lineArrowDensity;

  static const defaults = ClientPreferences(
    measurementUnits: MeasurementUnits.metric,
    angleDisplayFormat: AngleDisplayFormat.decimal,
    circleSizeDisplay: CircleSizeDisplay.radius,
    appTheme: AppThemeChoice.light,
    appLocale: AppLocaleChoice.system,
    lineArrowDensity: LineArrowDensity(LineArrowDensity.defaultLevel),
  );

  factory ClientPreferences.fromAppSettings(wf.AppSettings settings) {
    return ClientPreferences(
      measurementUnits: measurementUnitsFromStorage(settings.measurementUnits),
      angleDisplayFormat:
          angleDisplayFormatFromStorage(settings.angleDisplayFormat),
      circleSizeDisplay:
          circleSizeDisplayFromStorage(settings.circleSizeDisplay),
      appTheme: appThemeChoiceFromStorage(settings.appTheme),
      appLocale: appLocaleChoiceFromStorage(settings.appLocale),
      lineArrowDensity:
          lineArrowDensityFromStorage(settings.lineArrowDensity),
    );
  }

  factory ClientPreferences.fromJson(Map<String, dynamic> json) {
    return ClientPreferences(
      measurementUnits: measurementUnitsFromStorage(
        json['measurementUnits'] as String?,
      ),
      angleDisplayFormat: angleDisplayFormatFromStorage(
        json['angleDisplayFormat'] as String?,
      ),
      circleSizeDisplay: circleSizeDisplayFromStorage(
        json['circleSizeDisplay'] as String?,
      ),
      appTheme: appThemeChoiceFromStorage(json['appTheme'] as String?),
      appLocale: appLocaleChoiceFromStorage(json['appLocale'] as String?),
      lineArrowDensity: lineArrowDensityFromStorage(
        _readInt(json['lineArrowDensity']),
      ),
    );
  }

  ClientPreferences copyWith({
    MeasurementUnits? measurementUnits,
    AngleDisplayFormat? angleDisplayFormat,
    CircleSizeDisplay? circleSizeDisplay,
    AppThemeChoice? appTheme,
    AppLocaleChoice? appLocale,
    LineArrowDensity? lineArrowDensity,
  }) {
    return ClientPreferences(
      measurementUnits: measurementUnits ?? this.measurementUnits,
      angleDisplayFormat: angleDisplayFormat ?? this.angleDisplayFormat,
      circleSizeDisplay: circleSizeDisplay ?? this.circleSizeDisplay,
      appTheme: appTheme ?? this.appTheme,
      appLocale: appLocale ?? this.appLocale,
      lineArrowDensity: lineArrowDensity ?? this.lineArrowDensity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measurementUnits': measurementUnitsToStorage(measurementUnits),
      'angleDisplayFormat': angleDisplayFormatToStorage(angleDisplayFormat),
      'circleSizeDisplay': circleSizeDisplayToStorage(circleSizeDisplay),
      'appTheme': appThemeChoiceToStorage(appTheme),
      'appLocale': appLocaleChoiceToStorage(appLocale),
      'lineArrowDensity': lineArrowDensityToStorage(lineArrowDensity),
    };
  }
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}
