import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../app/app_locale_choice.dart';
import '../../../app/app_theme_choice.dart';
import '../../../app/theme.dart';
import '../../../core/app_globals.dart';
import '../../../core/app_restart.dart';
import '../../../core/constants.dart';
import '../../../core/l10n/localized_labels.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/server_config.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/providers/circle_size_display_provider.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/line_arrow_density.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/line_arrow_density_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/models/home_location.dart';
import '../../map/providers/home_location_provider.dart';
import '../../map/providers/map_providers.dart';
import '../providers/app_locale_provider.dart';
import '../providers/app_theme_provider.dart';
import '../providers/server_config_provider.dart';

class SettingsGeneralTab extends ConsumerStatefulWidget {
  const SettingsGeneralTab({super.key});

  @override
  ConsumerState<SettingsGeneralTab> createState() =>
      _SettingsGeneralTabState();
}

class _SettingsGeneralTabState extends ConsumerState<SettingsGeneralTab> {
  static final _log = AppLogger.logSettings;

  bool _isSavingServerUrl = false;
  bool _isSavingHomeLocation = false;
  final _serverUrlController = TextEditingController();
  final _homeLatController = TextEditingController();
  final _homeLngController = TextEditingController();
  final _homeZoomController = TextEditingController();

  @override
  void dispose() {
    _serverUrlController.dispose();
    _homeLatController.dispose();
    _homeLngController.dispose();
    _homeZoomController.dispose();
    super.dispose();
  }

  void _syncHomeFields(HomeLocation home) {
    _homeLatController.text = home.latitude.toStringAsFixed(6);
    _homeLngController.text = home.longitude.toStringAsFixed(6);
    _homeZoomController.text = home.zoom.toStringAsFixed(1);
  }

  @override
  void initState() {
    super.initState();
    _serverUrlController.text = appServerConfig.apiUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncHomeFields(ref.read(homeLocationProvider));
    });
  }

  Future<void> _saveHomeLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSavingHomeLocation = true);
    try {
      final home = HomeLocation.tryParse(
        latitudeText: _homeLatController.text,
        longitudeText: _homeLngController.text,
        zoomText: _homeZoomController.text,
      );
      if (home == null) {
        throw FormatException(l10n.settingsHomeLocationInvalid);
      }
      await ref.read(homeLocationProvider.notifier).setLocation(home);
      if (!mounted) {
        return;
      }
      final savedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(savedL10n.settingsHomeLocationSaved)),
      );
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Home location save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorL10n.settingsHomeLocationSaveFailed(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingHomeLocation = false);
      }
    }
  }

  Future<void> _resetHomeLocation() async {
    await ref.read(homeLocationProvider.notifier).resetToDefaults();
    setState(() {
      _syncHomeFields(HomeLocation.defaults);
    });
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsHomeLocationReset)),
    );
  }

  void _useCurrentMapView() {
    final viewport = ref.read(mapViewportProvider).valueOrNull;
    if (viewport == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsOpenMapFirst)),
      );
      return;
    }

    setState(() {
      _homeLatController.text = viewport.center.latitude.toStringAsFixed(6);
      _homeLngController.text = viewport.center.longitude.toStringAsFixed(6);
      _homeZoomController.text = viewport.zoom.toStringAsFixed(1);
    });
  }

  Future<void> _saveServerUrl() async {
    setState(() => _isSavingServerUrl = true);
    try {
      final controller = ref.read(serverUrlSettingsControllerProvider);
      final config = await controller.saveApiUrl(_serverUrlController.text);
      ref.invalidate(savedServerApiUrlProvider);
      if (!mounted) {
        return;
      }

      final restartNow = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.settingsRestartRequiredTitle),
            content: Text(
              l10n.settingsRestartRequiredMessage(config.apiUrl, config.webUrl),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.actionLater),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(kIsWeb ? l10n.actionReloadNow : l10n.actionOk),
              ),
            ],
          );
        },
      );

      if (restartNow == true && mounted) {
        restartApp();
      }
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🔌 Server URL save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsServerUrlSaveFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingServerUrl = false);
      }
    }
  }

  Future<void> _resetServerUrl() async {
    await ref.read(serverUrlSettingsControllerProvider).resetToDefault();
    ref.invalidate(savedServerApiUrlProvider);
    setState(() {
      _serverUrlController.text = defaultApiUrl;
    });
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsServerUrlReset)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final angleDisplayFormat = ref.watch(angleDisplayFormatProvider);
    final lineArrowDensity = ref.watch(lineArrowDensityProvider);
    final circleSizeDisplay = ref.watch(circleSizeDisplayProvider);
    final themeChoice = ref.watch(appThemeProvider);
    final localeChoice = ref.watch(appLocaleProvider);
    ref.listen<HomeLocation>(homeLocationProvider, (previous, next) {
      if (previous != next) {
        _syncHomeFields(next);
      }
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.settingsLanguageTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsLanguageDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<AppLocaleChoice>(
          segments: appLocaleChoices
              .map(
                (choice) => ButtonSegment(
                  value: choice,
                  label: Text(choice.localizedLabel(l10n)),
                ),
              )
              .toList(),
          selected: {localeChoice},
          onSelectionChanged: (selection) {
            ref.read(appLocaleProvider.notifier).setLocale(selection.first);
          },
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsAppearanceTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsAppearanceDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.settingsThemeStyle,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<AppThemeFamily>(
          segments: AppThemeFamily.values
              .map(
                (family) => ButtonSegment(
                  value: family,
                  label: Text(family.localizedLabel(l10n)),
                ),
              )
              .toList(),
          selected: {themeChoice.family},
          onSelectionChanged: (selection) {
            ref.read(appThemeProvider.notifier).setFamily(selection.first);
          },
        ),
        const SizedBox(height: 16),
        Text(
          l10n.settingsBrightness,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<AppThemeBrightness>(
          segments: AppThemeBrightness.values
              .map(
                (brightness) => ButtonSegment(
                  value: brightness,
                  label: Text(brightness.localizedLabel(l10n)),
                ),
              )
              .toList(),
          selected: {themeChoice.brightness},
          onSelectionChanged: (selection) {
            ref
                .read(appThemeProvider.notifier)
                .setBrightness(selection.first);
          },
        ),
        const SizedBox(height: 12),
        _ThemePreview(choice: themeChoice),
        const SizedBox(height: 32),
        Text(
          l10n.settingsMapHomeTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsMapHomeDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _homeLatController,
                decoration: InputDecoration(
                  labelText: l10n.settingsLatitude,
                  hintText: '38.903481',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _homeLngController,
                decoration: InputDecoration(
                  labelText: l10n.settingsLongitude,
                  hintText: '-77.262817',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _homeZoomController,
          decoration: InputDecoration(
            labelText: l10n.settingsZoom,
            hintText: '12',
            helperText: l10n.settingsZoomHelper(
              AppConstants.maxMapZoom.toStringAsFixed(0),
            ),
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _isSavingHomeLocation ? null : _saveHomeLocation,
              child: Text(
                _isSavingHomeLocation ? l10n.actionSaving : l10n.settingsSaveHome,
              ),
            ),
            OutlinedButton(
              onPressed: _isSavingHomeLocation ? null : _useCurrentMapView,
              child: Text(l10n.settingsUseCurrentMapView),
            ),
            OutlinedButton(
              onPressed: _isSavingHomeLocation ? null : _resetHomeLocation,
              child: Text(l10n.settingsResetToDefault),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsServerConnectionTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsServerConnectionDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _serverUrlController,
          decoration: InputDecoration(
            labelText: l10n.settingsServerUrl,
            hintText: 'http://localhost:18080',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
          autofillHints: const [AutofillHints.url],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsCurrentWebServer(appServerConfig.webUrl),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: _isSavingServerUrl ? null : _saveServerUrl,
              child: Text(
                _isSavingServerUrl ? l10n.actionSaving : l10n.settingsSaveServerUrl,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _isSavingServerUrl ? null : _resetServerUrl,
              child: Text(l10n.settingsResetToDefault),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsMeasurementsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsMeasurementsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<MeasurementUnits>(
          segments: MeasurementUnits.values
              .map(
                (units) => ButtonSegment(
                  value: units,
                  label: Text(units.localizedLabel(l10n)),
                  tooltip: units.localizedShortLabel(l10n),
                ),
              )
              .toList(),
          selected: {measurementUnits},
          onSelectionChanged: (selection) {
            ref.read(measurementUnitsProvider.notifier).setUnits(selection.first);
          },
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsAnglesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsAnglesDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<AngleDisplayFormat>(
          segments: AngleDisplayFormat.values
              .map(
                (format) => ButtonSegment(
                  value: format,
                  label: Text(format.localizedShortLabel(l10n)),
                  tooltip: format.localizedLabel(l10n),
                ),
              )
              .toList(),
          selected: {angleDisplayFormat},
          onSelectionChanged: (selection) {
            ref
                .read(angleDisplayFormatProvider.notifier)
                .setFormat(selection.first);
          },
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsLineArrowsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsLineArrowsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              l10n.lineArrowDensitySparse,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Expanded(
              child: Slider(
                value: lineArrowDensity.level.toDouble(),
                min: LineArrowDensity.minLevel.toDouble(),
                max: LineArrowDensity.maxLevel.toDouble(),
                divisions: LineArrowDensity.maxLevel - LineArrowDensity.minLevel,
                label: lineArrowDensity.localizedLabel(l10n),
                onChanged: (value) {
                  ref.read(lineArrowDensityProvider.notifier).setDensity(
                        LineArrowDensity.fromLevel(value.round()),
                      );
                },
              ),
            ),
            Text(
              l10n.lineArrowDensityDense,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        Text(
          lineArrowDensity.localizedLabel(l10n),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsCirclesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsCirclesDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<CircleSizeDisplay>(
          segments: CircleSizeDisplay.values
              .map(
                (display) => ButtonSegment(
                  value: display,
                  label: Text(display.localizedShortLabel(l10n)),
                  tooltip: display.localizedLabel(l10n),
                ),
              )
              .toList(),
          selected: {circleSizeDisplay},
          onSelectionChanged: (selection) {
            ref
                .read(circleSizeDisplayProvider.notifier)
                .setDisplay(selection.first);
          },
        ),
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.choice});

  final AppThemeChoice choice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewTheme = AppTheme.forChoice(choice);
    final colors = previewTheme.colorScheme;

    return Theme(
      data: previewTheme,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                choice.localizedLabel(l10n),
                style: previewTheme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Swatch(label: l10n.themePreviewPrimary, color: colors.primary),
                  _Swatch(label: l10n.themePreviewSecondary, color: colors.secondary),
                  _Swatch(label: l10n.themePreviewSurface, color: colors.surface),
                  _Swatch(label: l10n.themePreviewAccent, color: colors.tertiary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: Text(l10n.themePreviewButton),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text(l10n.themePreviewOutline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
