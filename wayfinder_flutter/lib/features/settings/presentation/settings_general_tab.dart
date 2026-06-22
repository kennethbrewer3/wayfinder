import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme_choice.dart';
import '../../../app/theme.dart';
import '../../../core/app_globals.dart';
import '../../../core/app_restart.dart';
import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/server_config.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/providers/circle_size_display_provider.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/models/home_location.dart';
import '../../map/providers/home_location_provider.dart';
import '../../map/providers/map_providers.dart';
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
    setState(() => _isSavingHomeLocation = true);
    try {
      final home = HomeLocation.tryParse(
        latitudeText: _homeLatController.text,
        longitudeText: _homeLngController.text,
        zoomText: _homeZoomController.text,
      );
      if (home == null) {
        throw const FormatException(
          'Enter valid numbers for latitude, longitude, and zoom.',
        );
      }
      await ref.read(homeLocationProvider.notifier).setLocation(home);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Home location saved.')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save home location: $error')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Home location reset to default.')),
    );
  }

  void _useCurrentMapView() {
    final viewport = ref.read(mapViewportProvider).valueOrNull;
    if (viewport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Open the map first to capture its view.')),
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
          return AlertDialog(
            title: const Text('Restart required'),
            content: Text(
              'Server URL saved.\n\n'
              'API: ${config.apiUrl}\n'
              'Web: ${config.webUrl}\n\n'
              'Restart the app to connect to the new server.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(kIsWeb ? 'Reload now' : 'OK'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save server URL: $error')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Server URL reset to default. Restart the app to apply.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final angleDisplayFormat = ref.watch(angleDisplayFormatProvider);
    final circleSizeDisplay = ref.watch(circleSizeDisplayProvider);
    final themeChoice = ref.watch(appThemeProvider);
    ref.listen<HomeLocation>(homeLocationProvider, (previous, next) {
      if (previous != next) {
        _syncHomeFields(next);
      }
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a color theme for the app. Military themes use olive, tan, '
          'and forest green tones.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Theme style',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<AppThemeFamily>(
          segments: AppThemeFamily.values
              .map(
                (family) => ButtonSegment(
                  value: family,
                  label: Text(family.label),
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
          'Brightness',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<AppThemeBrightness>(
          segments: AppThemeBrightness.values
              .map(
                (brightness) => ButtonSegment(
                  value: brightness,
                  label: Text(brightness.label),
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
          'Map home',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Coordinates and zoom for the home button on the map. Stored on the '
          'server so all clients share the same home location. Also used as '
          'the starting view when no previous map position is saved.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _homeLatController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: '38.903481',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-77.262817',
                  border: OutlineInputBorder(),
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
            labelText: 'Zoom',
            hintText: '12',
            helperText: '0–${AppConstants.maxMapZoom.toStringAsFixed(0)}',
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
              child: Text(_isSavingHomeLocation ? 'Saving…' : 'Save home'),
            ),
            OutlinedButton(
              onPressed: _isSavingHomeLocation ? null : _useCurrentMapView,
              child: const Text('Use current map view'),
            ),
            OutlinedButton(
              onPressed: _isSavingHomeLocation ? null : _resetHomeLocation,
              child: const Text('Reset to default'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Server connection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Wayfinder API server URL, including host and port. The web '
          'server URL (REST API and PMTiles) is derived automatically '
          '(API port + 2). Restart the app after changing this.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _serverUrlController,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            hintText: 'http://localhost:18080',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
          autofillHints: const [AutofillHints.url],
        ),
        const SizedBox(height: 8),
        Text(
          'Current web server: ${appServerConfig.webUrl}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: _isSavingServerUrl ? null : _saveServerUrl,
              child: Text(_isSavingServerUrl ? 'Saving…' : 'Save server URL'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _isSavingServerUrl ? null : _resetServerUrl,
              child: const Text('Reset to default'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Measurements',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how line distances are displayed on the map.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<MeasurementUnits>(
          segments: MeasurementUnits.values
              .map(
                (units) => ButtonSegment(
                  value: units,
                  label: Text(units.label),
                  tooltip: units.shortLabel,
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
          'Angles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how relative angles are displayed on the map and in '
          'bearing plots.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<AngleDisplayFormat>(
          segments: AngleDisplayFormat.values
              .map(
                (format) => ButtonSegment(
                  value: format,
                  label: Text(format.shortLabel),
                  tooltip: format.label,
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
          'Circles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the default size label shown on new circular zones.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<CircleSizeDisplay>(
          segments: CircleSizeDisplay.values
              .map(
                (display) => ButtonSegment(
                  value: display,
                  label: Text(display.shortLabel),
                  tooltip: display.label,
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
                choice.label,
                style: previewTheme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Swatch(label: 'Primary', color: colors.primary),
                  _Swatch(label: 'Secondary', color: colors.secondary),
                  _Swatch(label: 'Surface', color: colors.surface),
                  _Swatch(label: 'Accent', color: colors.tertiary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton(onPressed: () {}, child: const Text('Button')),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outline'),
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
