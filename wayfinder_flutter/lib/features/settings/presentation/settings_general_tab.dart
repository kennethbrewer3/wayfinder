import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_globals.dart';
import '../../../core/app_restart.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/server_config.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/providers/circle_size_display_provider.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
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
  final _serverUrlController = TextEditingController();

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _serverUrlController.text = appServerConfig.apiUrl;
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
