import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../models/pmtiles_file.dart';
import '../providers/pmtiles_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static final _log = AppLogger.logSettings;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _log.info('⚙️ Settings screen opened');
  }

  Future<void> _uploadPmtiles() async {
    _log.info('📤 Upload button pressed — opening file picker');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pmtiles'],
      withData: false,
      withReadStream: true,
    );

    if (result == null || result.files.isEmpty) {
      _log.warn('📤 File picker cancelled or returned no files');
      return;
    }

    final picked = result.files.single;
    _log.info(
      '📤 File picked',
      data: describePlatformFile(picked),
    );

    setState(() => _isUploading = true);

    try {
      final repository = ref.read(pmtilesRepositoryProvider);
      final entry = await repository.uploadFile(picked);
      refreshPmtiles(ref);
      if (!mounted) return;
      _log.success('📤 Upload UI flow complete', data: '"${entry.name}"');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PMTiles file uploaded: ${entry.name}')),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📤 Upload UI flow failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _setActive(String id) async {
    _log.info('🎯 Use-on-map pressed', data: id);
    await ref.read(pmtilesRepositoryProvider).setActiveFile(id);
    refreshPmtiles(ref);
  }

  Future<void> _deleteFile(String id, String name) async {
    _log.info('🗑️ Delete pressed', data: 'id=$id name="$name"');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete PMTiles file?'),
          content: Text('Remove "$name" from this device?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      _log.warn('🗑️ Delete cancelled by user', data: id);
      return;
    }

    await ref.read(pmtilesRepositoryProvider).deleteFile(id);
    refreshPmtiles(ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PMTiles file deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(pmtilesCatalogProvider);
    final activeIdAsync = ref.watch(activePmtilesIdProvider);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final angleDisplayFormat = ref.watch(angleDisplayFormatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
              ref
                  .read(measurementUnitsProvider.notifier)
                  .setUnits(selection.first);
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
            'PMTiles Maps',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload offline map archives (.pmtiles). The active map is shown '
            'on the main map screen.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isUploading ? null : _uploadPmtiles,
            icon: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_isUploading ? 'Uploading…' : 'Upload .pmtiles file'),
          ),
          const SizedBox(height: 24),
          filesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              _log.error(
                '📋 Settings catalog load failed',
                error: error,
                stackTrace: stackTrace,
              );
              return Text('Failed to load files: $error');
            },
            data: (files) {
              if (files.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No PMTiles files uploaded yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              final activeId = activeIdAsync.maybeWhen(
                data: (value) => value,
                orElse: () => null,
              );

              return Card(
                child: Column(
                  children: [
                    for (var i = 0; i < files.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _PmtilesFileTile(
                        file: files[i],
                        isActive: files[i].id == activeId,
                        onActivate: () => _setActive(files[i].id),
                        onDelete: () => _deleteFile(files[i].id, files[i].name),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PmtilesFileTile extends StatelessWidget {
  const _PmtilesFileTile({
    required this.file,
    required this.isActive,
    required this.onActivate,
    required this.onDelete,
  });

  final PmtilesFile file;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isActive ? Icons.check_circle : Icons.map_outlined,
        color: isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(file.name),
      subtitle: Text('${file.formattedSize} • ${file.addedAt.toLocal()}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isActive)
            TextButton(
              onPressed: onActivate,
              child: const Text('Use on map'),
            ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
