import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../app/app_locale_choice.dart';
import '../../../app/app_theme_choice.dart';
import '../../../app/app_theme_ids.dart';
import '../../../app/theme.dart';
import '../../../core/app_globals.dart';
import '../../../core/app_restart.dart';
import '../../../core/constants.dart';
import '../../../core/l10n/localized_labels.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/server_config.dart';
import '../../../core/serverpod_client.dart';
import '../../access/presentation/signed_in_account_tile.dart';
import '../../access/providers/access_session_provider.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/providers/circle_size_display_provider.dart';
import '../../geocoding/data/geocoding_repository.dart';
import '../../geocoding/presentation/address_search_readiness_indicator.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/bearing_reference.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/bearing_reference_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/models/home_location.dart';
import '../../map/models/map_zoom_limits.dart';
import '../../map/providers/dark_map_tiles_provider.dart';
import '../../map/providers/home_location_provider.dart';
import '../../map/providers/map_compass_rose_provider.dart';
import '../../map/providers/map_mgrs_grid_provider.dart';
import '../../map/providers/map_providers.dart';
import '../../map/providers/map_viewport_debug_provider.dart';
import '../../map/providers/map_zoom_range_provider.dart';
import '../../markers/models/map_marker_size.dart';
import '../../markers/models/marker_icon_registry.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/providers/map_marker_size_provider.dart';
import '../../polygons/providers/polygon_angle_snap_provider.dart';
import '../../themes/providers/app_theme_definitions_provider.dart';
import '../providers/app_locale_provider.dart';
import '../providers/app_theme_provider.dart';
import '../providers/server_config_provider.dart';
import '../settings_tab.dart';

/// Matches the map AppBar compact breakpoint — settings rows that fight for
/// horizontal space stack into a column below this width.
const _settingsCompactBreakpoint = 720.0;

class SettingsGeneralTab extends ConsumerStatefulWidget {
  const SettingsGeneralTab({super.key});

  @override
  ConsumerState<SettingsGeneralTab> createState() => _SettingsGeneralTabState();
}

class _SettingsGeneralTabState extends ConsumerState<SettingsGeneralTab> {
  static final _log = AppLogger.logSettings;

  bool _isSavingServerUrl = false;
  bool _isSavingHomeLocation = false;
  bool _isSavingMapZoomRange = false;
  final _serverUrlController = TextEditingController();
  final _webServerUrlController = TextEditingController();
  final _homeLatController = TextEditingController();
  final _homeLngController = TextEditingController();
  final _homeZoomController = TextEditingController();
  final _mapMinZoomController = TextEditingController();
  final _mapMaxZoomController = TextEditingController();

  @override
  void dispose() {
    _serverUrlController.dispose();
    _webServerUrlController.dispose();
    _homeLatController.dispose();
    _homeLngController.dispose();
    _homeZoomController.dispose();
    _mapMinZoomController.dispose();
    _mapMaxZoomController.dispose();
    super.dispose();
  }

  void _syncMapZoomFields(MapZoomRange range) {
    _mapMinZoomController.text = range.min.toStringAsFixed(1);
    _mapMaxZoomController.text = range.max.toStringAsFixed(1);
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
    _webServerUrlController.text = appServerConfig.webUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncHomeFields(ref.read(homeLocationProvider));
      _syncMapZoomFields(ref.read(mapZoomRangeProvider));
    });
  }

  Future<void> _saveMapZoomRange() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSavingMapZoomRange = true);
    try {
      final min = double.tryParse(_mapMinZoomController.text.trim());
      final max = double.tryParse(_mapMaxZoomController.text.trim());
      if (min == null || max == null) {
        throw FormatException(l10n.settingsMapZoomRangeInvalid);
      }
      final range = validateMapZoomRange(MapZoomRange(min: min, max: max));
      await ref.read(mapZoomRangeProvider.notifier).setRange(range);
      if (!mounted) {
        return;
      }
      _syncMapZoomFields(range);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsMapZoomRangeSaved)),
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
        '🗺️ Map zoom range save failed',
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
            errorL10n.settingsMapZoomRangeSaveFailed(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingMapZoomRange = false);
      }
    }
  }

  Future<void> _saveHomeLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSavingHomeLocation = true);
    try {
      final home = HomeLocation.tryParse(
        latitudeText: _homeLatController.text,
        longitudeText: _homeLngController.text,
        zoomText: _homeZoomController.text,
        maxZoom: ref.read(mapZoomRangeProvider).max,
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
      final config = await controller.saveServerUrls(
        apiUrlInput: _serverUrlController.text,
        webUrlInput: _webServerUrlController.text,
      );
      await applyAppServerConfig(config);
      ref.read(serverClientEpochProvider.notifier).state++;
      ref.invalidate(savedServerApiUrlProvider);
      ref.invalidate(savedServerWebUrlProvider);
      ref.invalidate(accessSessionProvider);
      if (!mounted) {
        return;
      }

      final restartNow = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.settingsServerUrlAppliedTitle),
            content: Text(
              l10n.settingsServerUrlAppliedMessage(
                config.apiUrl,
                config.webUrl,
              ),
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
    ref.invalidate(savedServerWebUrlProvider);
    setState(() {
      _serverUrlController.text = defaultApiUrl;
      _webServerUrlController.text = defaultWebUrl;
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
    final bearingReference = ref.watch(bearingReferenceProvider);
    final circleSizeDisplay = ref.watch(circleSizeDisplayProvider);
    final showMapViewportDebugBorder = ref.watch(
      mapViewportDebugBorderProvider,
    );
    final showMapTileBorderDebug = ref.watch(mapTileBorderDebugProvider);
    final showMapCompassRose = ref.watch(mapCompassRoseEnabledProvider);
    final showMapMgrsGrid = ref.watch(mapMgrsGridEnabledProvider);
    final darkMapTilesInDarkMode = ref.watch(darkMapTilesInDarkModeProvider);
    final polygonSnapRightAngles = ref.watch(polygonSnapRightAnglesProvider);
    final polygonSnap45Angles = ref.watch(polygonSnap45AnglesProvider);
    final mapZoomRange = ref.watch(mapZoomRangeProvider);
    ref.listen<MapZoomRange>(mapZoomRangeProvider, (previous, next) {
      if (previous != next) {
        _syncMapZoomFields(next);
      }
    });
    final mapMarkerSizeScale = ref.watch(mapMarkerSizeScaleProvider);
    final themeId = ref.watch(appThemeProvider);
    final customThemes =
        ref.watch(appThemeDefinitionsProvider).valueOrNull ?? const [];
    final builtInChoice = AppThemeChoice.values
        .where((choice) => choice.name == themeId)
        .firstOrNull;
    final localeChoice = ref.watch(appLocaleProvider);
    ref.listen<HomeLocation>(homeLocationProvider, (previous, next) {
      if (previous != next) {
        _syncHomeFields(next);
      }
    });
    final isCompactLayout =
        MediaQuery.sizeOf(context).width < _settingsCompactBreakpoint;

    final serverReadOnly = ref.watch(serverReadOnlyProvider);
    final session = ref.watch(accessSessionProvider).valueOrNull;
    final canManageMapHome = ref.watch(canManageMapHomeProvider);
    final canManageMapZoom = ref.watch(canManageMapZoomProvider);
    final canEditServerConnection = ref.watch(canEditServerConnectionProvider);
    final mapEditsLocked = ref.watch(mapEditsLockedByRoleProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (session?.authenticated == true) ...[
          Text(
            l10n.accessSignedIn,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const SignedInAccountTile(contentPadding: EdgeInsets.zero),
          const Divider(height: 32),
        ],
        Text(
          l10n.kioskModeTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.kioskModeDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (serverReadOnly) ...[
          const SizedBox(height: 12),
          Text(
            l10n.kioskModeBannerServerEnforced,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(l10n.kioskModeEnterConfirmTitle),
                    content: Text(l10n.kioskModeEnterConfirmMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.actionCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.kioskModeEnter),
                      ),
                    ],
                  );
                },
              );
              if (confirmed != true || !mounted) {
                return;
              }
              await ref.read(localKioskModeProvider.notifier).setEnabled(true);
              if (!mounted) {
                return;
              }
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.kioskModeEntered)),
              );
            },
            icon: const Icon(Icons.desktop_windows_outlined),
            label: Text(l10n.kioskModeEnter),
          ),
        ],
        const SizedBox(height: 32),
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
        // Narrow widths crush "System default" in a SegmentedButton.
        if (isCompactLayout)
          InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.settingsLanguageTitle,
              border: const OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppLocaleChoice>(
                value: localeChoice,
                isExpanded: true,
                isDense: true,
                items: [
                  for (final choice in appLocaleChoices)
                    DropdownMenuItem(
                      value: choice,
                      child: Text(choice.localizedLabel(l10n)),
                    ),
                ],
                onChanged: (selection) {
                  if (selection == null) {
                    return;
                  }
                  ref.read(appLocaleProvider.notifier).setLocale(selection);
                },
              ),
            ),
          )
        else
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
        Builder(
          builder: (context) {
            final themeDropdown = DropdownButtonFormField<String>(
              key: ValueKey(
                'appearance-theme-${_appearanceDropdownValue(themeId, customThemes)}',
              ),
              initialValue: _appearanceDropdownValue(themeId, customThemes),
              decoration: InputDecoration(
                labelText: l10n.settingsAppearanceTheme,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: AppThemeFamily.standard.name,
                  child: Text(AppThemeFamily.standard.localizedLabel(l10n)),
                ),
                DropdownMenuItem(
                  value: AppThemeFamily.military.name,
                  child: Text(AppThemeFamily.military.localizedLabel(l10n)),
                ),
                for (final theme in customThemes)
                  DropdownMenuItem(
                    value: AppThemeIds.forCustom(theme.id),
                    child: Text(theme.name),
                  ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                final notifier = ref.read(appThemeProvider.notifier);
                if (value == AppThemeFamily.standard.name) {
                  notifier.setFamily(AppThemeFamily.standard);
                  return;
                }
                if (value == AppThemeFamily.military.name) {
                  notifier.setFamily(AppThemeFamily.military);
                  return;
                }
                final customId = AppThemeIds.tryParseCustomId(value);
                if (customId == null) {
                  return;
                }
                notifier.setCustomTheme(customId);
              },
            );
            final darkModeSwitch = SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsDarkMode),
              subtitle: Text(l10n.settingsDarkModeDescription),
              value: _appearanceIsDark(
                themeId: themeId,
                customThemes: customThemes,
                builtInChoice: builtInChoice,
              ),
              onChanged: (enabled) {
                ref.read(appThemeProvider.notifier).setDarkMode(enabled);
              },
            );
            if (isCompactLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  themeDropdown,
                  const SizedBox(height: 8),
                  darkModeSwitch,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: themeDropdown),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: darkModeSwitch),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        _ThemePreview(
          themeId: themeId,
          customThemes: customThemes,
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsMapHomeTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          canManageMapHome
              ? l10n.settingsMapHomeDescription
              : l10n.settingsMapHomePermissionDenied,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (canManageMapHome) ...[
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
                mapZoomRange.max.toStringAsFixed(0),
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
                  _isSavingHomeLocation
                      ? l10n.actionSaving
                      : l10n.settingsSaveHome,
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
        ],
        const SizedBox(height: 32),
        Text(
          l10n.settingsServerConnectionTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          canEditServerConnection
              ? l10n.settingsServerConnectionDescription
              : l10n.settingsServerConnectionPermissionDenied,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (canEditServerConnection) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _serverUrlController,
            decoration: InputDecoration(
              labelText: l10n.settingsServerUrl,
              hintText: l10n.accessServerUrlHint,
              helperText: l10n.accessServerUrlHelp,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _webServerUrlController,
            decoration: InputDecoration(
              labelText: l10n.settingsWebServerUrl,
              hintText: l10n.accessWebServerUrlHint,
              helperText: l10n.accessWebServerUrlHelp,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: _isSavingServerUrl ? null : _saveServerUrl,
                child: Text(
                  _isSavingServerUrl
                      ? l10n.actionSaving
                      : l10n.settingsSaveServerUrl,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _isSavingServerUrl ? null : _resetServerUrl,
                child: Text(l10n.settingsResetToDefault),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            l10n.accessApiServerConfigured(appServerConfig.apiUrl),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsCurrentWebServer(appServerConfig.webUrl),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 32),
        const _GeocodingAvailabilitySection(),
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
            ref
                .read(measurementUnitsProvider.notifier)
                .setUnits(selection.first);
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
          l10n.settingsBearingsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsBearingsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<BearingReference>(
          segments: BearingReference.values
              .map(
                (reference) => ButtonSegment(
                  value: reference,
                  label: Text(reference.localizedShortLabel(l10n)),
                  tooltip: reference.localizedLabel(l10n),
                ),
              )
              .toList(),
          selected: {bearingReference},
          onSelectionChanged: (selection) {
            ref
                .read(bearingReferenceProvider.notifier)
                .setReference(selection.first);
          },
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
        if (!mapEditsLocked) ...[
          const SizedBox(height: 32),
          Text(
            l10n.settingsMapEditingTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsMapEditingDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsPolygonSnapRightAnglesTitle),
            subtitle: Text(l10n.settingsPolygonSnapRightAnglesDescription),
            value: polygonSnapRightAngles,
            onChanged: (enabled) {
              ref
                  .read(polygonSnapRightAnglesProvider.notifier)
                  .setEnabled(enabled);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsPolygonSnap45AnglesTitle),
            subtitle: Text(l10n.settingsPolygonSnap45AnglesDescription),
            value: polygonSnap45Angles,
            onChanged: (enabled) {
              ref
                  .read(polygonSnap45AnglesProvider.notifier)
                  .setEnabled(enabled);
            },
          ),
        ],
        const SizedBox(height: 32),
        Text(
          l10n.settingsMapMarkerSizeTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsMapMarkerSizeDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: MapMarkerIcon(
            color: Theme.of(context).colorScheme.primary,
            iconName: defaultMarkerIconKey,
            width: mapMarkerRenderWidth(mapMarkerSizeScale),
            height: mapMarkerRenderHeight(mapMarkerSizeScale),
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: mapMarkerSizeScale,
          min: mapMarkerSizeScaleMin,
          max: mapMarkerSizeScaleMax,
          divisions: ((mapMarkerSizeScaleMax - mapMarkerSizeScaleMin) / 0.05)
              .round(),
          label: l10n.settingsMapMarkerSizeValue(
            mapMarkerSizeScalePercent(mapMarkerSizeScale),
          ),
          onChanged: (value) {
            ref.read(mapMarkerSizeScaleProvider.notifier).setScale(value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.settingsMapMarkerSizeMinLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              l10n.settingsMapMarkerSizeValue(
                mapMarkerSizeScalePercent(mapMarkerSizeScale),
              ),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              l10n.settingsMapMarkerSizeMaxLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsMapDisplayTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsMapDisplayDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsMapCompassRoseTitle),
          subtitle: Text(l10n.settingsMapCompassRoseDescription),
          value: showMapCompassRose,
          onChanged: (enabled) {
            ref
                .read(mapCompassRoseEnabledProvider.notifier)
                .setEnabled(enabled);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsMapMgrsGridTitle),
          subtitle: Text(l10n.settingsMapMgrsGridDescription),
          value: showMapMgrsGrid,
          onChanged: (enabled) {
            ref.read(mapMgrsGridEnabledProvider.notifier).setEnabled(enabled);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsDarkMapTilesTitle),
          subtitle: Text(l10n.settingsDarkMapTilesDescription),
          value: darkMapTilesInDarkMode,
          onChanged: (enabled) {
            ref
                .read(darkMapTilesInDarkModeProvider.notifier)
                .setEnabled(enabled);
          },
        ),
        Visibility(
          visible: canManageMapZoom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                l10n.settingsMapZoomRangeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsMapZoomRangeDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer.withValues(
                  alpha: 0.45,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.settingsMapZoomRangeWarning,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mapMinZoomController,
                      decoration: InputDecoration(
                        labelText: l10n.settingsMapMinZoom,
                        helperText: l10n.settingsMapZoomLimitHelper(
                          AppConstants.absoluteMapMinZoom.toStringAsFixed(0),
                          (AppConstants.absoluteMapMaxZoom - 1).toStringAsFixed(
                            0,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _mapMaxZoomController,
                      decoration: InputDecoration(
                        labelText: l10n.settingsMapMaxZoom,
                        helperText: l10n.settingsMapZoomLimitHelper(
                          (AppConstants.absoluteMapMinZoom + 1).toStringAsFixed(
                            0,
                          ),
                          AppConstants.absoluteMapMaxZoom.toStringAsFixed(0),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _isSavingMapZoomRange ? null : _saveMapZoomRange,
                  child: Text(
                    _isSavingMapZoomRange
                        ? l10n.actionSaving
                        : l10n.settingsMapZoomRangeSave,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.settingsMapDebugTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsMapDebugDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsMapViewportDebugBorderTitle),
          subtitle: Text(l10n.settingsMapViewportDebugBorderDescription),
          value: showMapViewportDebugBorder,
          onChanged: (enabled) async {
            await ref
                .read(mapViewportDebugBorderProvider.notifier)
                .setEnabled(enabled);
            if (!enabled) {
              await ref
                  .read(mapTileBorderDebugProvider.notifier)
                  .setEnabled(false);
            }
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsMapTileBorderDebugTitle),
          subtitle: Text(l10n.settingsMapTileBorderDebugDescription),
          value: showMapViewportDebugBorder && showMapTileBorderDebug,
          onChanged: showMapViewportDebugBorder
              ? (enabled) {
                  ref
                      .read(mapTileBorderDebugProvider.notifier)
                      .setEnabled(enabled);
                }
              : null,
        ),
      ],
    );
  }
}

String _appearanceDropdownValue(
  String themeId,
  List<AppThemeDefinition> customThemes,
) {
  final customId = AppThemeIds.tryParseCustomId(themeId);
  if (customId != null) {
    final exists = customThemes.any((theme) => theme.id == customId);
    if (exists) {
      return AppThemeIds.forCustom(customId);
    }
    return AppThemeFamily.standard.name;
  }
  final builtIn = AppThemeChoice.values
      .where((choice) => choice.name == themeId)
      .firstOrNull;
  return (builtIn?.family ?? AppThemeFamily.standard).name;
}

class _GeocodingAvailabilitySection extends ConsumerWidget {
  const _GeocodingAvailabilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final repository = ref.watch(geocodingRepositoryProvider);
    final readinessAsync = ref.watch(geocodingSearchReadinessProvider);

    final String statusLabel;
    final IconData statusIcon;
    final Color statusColor;
    final String? detail;

    if (!repository.isConfigured) {
      statusLabel = l10n.searchReadinessGeocodingNotConfiguredTooltip;
      statusIcon = Icons.cloud_off_outlined;
      statusColor = theme.colorScheme.error;
      detail = null;
    } else if (readinessAsync.isLoading && !readinessAsync.hasValue) {
      statusLabel = l10n.searchReadinessCheckingTooltip;
      statusIcon = Icons.hourglass_top;
      statusColor = theme.colorScheme.onSurfaceVariant;
      detail = null;
    } else if (readinessAsync.hasError) {
      statusLabel = l10n.searchReadinessUnavailableTooltip;
      statusIcon = Icons.error_outline;
      statusColor = theme.colorScheme.error;
      detail = readinessAsync.error.toString();
    } else {
      final readiness =
          readinessAsync.valueOrNull ?? emptyGeocodingSearchReadiness;
      final unreachable =
          readiness.statusMessage == 'Geocoding server unavailable';
      if (unreachable) {
        statusLabel = l10n.searchReadinessGeocodingUnavailableTooltip;
        statusIcon = Icons.cloud_off_outlined;
        statusColor = theme.colorScheme.error;
        detail = null;
      } else {
        statusLabel = searchReadinessTooltip(l10n, readiness);
        statusIcon = readiness.isFullSearchReady
            ? Icons.check_circle_outline
            : (readiness.isPlacesSearchReady || readiness.isAddressSearchReady)
            ? Icons.info_outline
            : Icons.hourglass_empty;
        statusColor = readiness.isFullSearchReady
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;
        detail = searchReadinessSummaryMessage(l10n, readiness);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsGeocodingAvailabilityTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsGeocodingAvailabilityDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                  if (detail != null && detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(detail, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => context.push(SettingsTab.geocoding.routePath),
            icon: const Icon(Icons.travel_explore),
            label: Text(l10n.settingsGeocodingOpenTab),
          ),
        ),
      ],
    );
  }
}

bool _appearanceIsDark({
  required String themeId,
  required List<AppThemeDefinition> customThemes,
  required AppThemeChoice? builtInChoice,
}) {
  if (builtInChoice != null) {
    return builtInChoice.brightness == AppThemeBrightness.dark;
  }
  if (AppThemeIds.isCustom(themeId)) {
    return AppThemeIds.isCustomDark(themeId);
  }
  return false;
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({
    required this.themeId,
    required this.customThemes,
  });

  final String themeId;
  final List<AppThemeDefinition> customThemes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewTheme = AppTheme.resolve(
      themeId,
      customThemes: customThemes,
    );
    final colors = previewTheme.colorScheme;
    final label = () {
      for (final choice in AppThemeChoice.values) {
        if (choice.name == themeId) {
          return choice.localizedLabel(l10n);
        }
      }
      for (final theme in customThemes) {
        if (AppThemeIds.matchesCustom(themeId, theme.id)) {
          return theme.name;
        }
      }
      return themeId;
    }();

    return Theme(
      data: previewTheme,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: previewTheme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Swatch(
                    label: l10n.themePreviewPrimary,
                    color: colors.primary,
                  ),
                  _Swatch(
                    label: l10n.themePreviewSecondary,
                    color: colors.secondary,
                  ),
                  _Swatch(
                    label: l10n.themePreviewSurface,
                    color: colors.surface,
                  ),
                  _Swatch(
                    label: l10n.themePreviewAccent,
                    color: colors.tertiary,
                  ),
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
