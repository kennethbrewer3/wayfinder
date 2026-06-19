import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../providers/map_data_providers.dart';

class SettingsBackupTab extends ConsumerStatefulWidget {
  const SettingsBackupTab({super.key});

  @override
  ConsumerState<SettingsBackupTab> createState() => _SettingsBackupTabState();
}

class _SettingsBackupTabState extends ConsumerState<SettingsBackupTab> {
  static final _log = AppLogger.logSettings;

  bool _isExportingMapData = false;
  bool _isRestoringMapData = false;

  Future<void> _exportMapData() async {
    setState(() => _isExportingMapData = true);
    try {
      final repository = ref.read(mapDataRepositoryProvider);
      final jsonText = await repository.fetchBackupJson();
      final timestamp =
          DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final saved = await saveTextFile(
        fileName: 'wayfinder-backup-$timestamp.json',
        contents: jsonText,
      );
      if (!mounted) return;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Map data backup saved.')),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '💾 Map data export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingMapData = false);
      }
    }
  }

  Future<void> _restoreMapData() async {
    final jsonText = await pickTextFileContents();
    if (jsonText == null || !mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore map data?'),
          content: const Text(
            'This replaces all layers, markers, and zones on the server '
            'with the selected backup file. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isRestoringMapData = true);
    try {
      final repository = ref.read(mapDataRepositoryProvider);
      final result = await repository.restoreFromJson(jsonText);
      refreshMapData(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Restored ${result.layers} layer(s), ${result.markers} marker(s), '
            'and ${result.zones} zone(s).',
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '💾 Map data restore failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoringMapData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Map data backup',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Export or restore all layers, markers, and zones. You can also '
          'back up with curl: GET /api/map-data',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isExportingMapData ? null : _exportMapData,
          icon: _isExportingMapData
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(
            _isExportingMapData ? 'Exporting…' : 'Export map data (.json)',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isRestoringMapData ? null : _restoreMapData,
          icon: _isRestoringMapData
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(
            _isRestoringMapData ? 'Restoring…' : 'Restore from backup',
          ),
        ),
      ],
    );
  }
}
