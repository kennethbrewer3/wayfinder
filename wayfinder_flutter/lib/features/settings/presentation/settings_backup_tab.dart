import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupExportSuccess)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '💾 Map data export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupExportFailed(error.toString()))),
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
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.backupRestoreConfirmTitle),
          content: Text(l10n.backupRestoreConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionRestore),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.backupRestoreSuccess(
              result.layers,
              result.markers,
              result.zones,
            ),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupRestoreFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoringMapData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.backupTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.backupDescription,
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
            _isExportingMapData ? l10n.actionExporting : l10n.backupExportButton,
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
            _isRestoringMapData ? l10n.actionRestoring : l10n.backupRestoreButton,
          ),
        ),
      ],
    );
  }
}
