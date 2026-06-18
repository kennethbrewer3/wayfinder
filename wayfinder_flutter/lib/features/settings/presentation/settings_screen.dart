import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_globals.dart';
import '../../../core/app_restart.dart';
import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../../../core/server_config.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/providers/circle_size_display_provider.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../models/pmtiles_file.dart';
import '../models/pmtiles_group.dart';
import '../providers/map_data_providers.dart';
import '../providers/pmtiles_providers.dart';
import '../providers/server_config_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static final _log = AppLogger.logSettings;

  bool _isUploading = false;
  bool _isExportingMapData = false;
  bool _isRestoringMapData = false;
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
    _log.info('⚙️ Settings screen opened');
    _serverUrlController.text = appServerConfig.apiUrl;
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

  Future<void> _setFileEnabled(String id, bool enabled) async {
    _log.info('🎯 Toggle map visibility', data: 'id=$id enabled=$enabled');
    await ref.read(pmtilesRepositoryProvider).setFileEnabled(
          id,
          enabled: enabled,
        );
    refreshPmtiles(ref);
  }

  Future<void> _enableAllPmtiles() async {
    await ref.read(pmtilesRepositoryProvider).enableAllFiles();
    refreshPmtiles(ref);
  }

  Future<void> _disableAllPmtiles() async {
    await ref.read(pmtilesRepositoryProvider).disableAllFiles();
    refreshPmtiles(ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All map tiles hidden from the map.')),
    );
  }

  Future<void> _createPmtilesGroup() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New tile group'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'e.g. Mid-Atlantic states',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(nameController.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty || !mounted) {
      return;
    }

    try {
      await ref.read(pmtilesRepositoryProvider).createGroup(name);
      refreshPmtiles(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created group "$name".')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create group: $error')),
      );
    }
  }

  Future<void> _setGroupEnabled(String groupId, bool enabled) async {
    await ref.read(pmtilesRepositoryProvider).setGroupEnabled(
          groupId,
          enabled: enabled,
        );
    refreshPmtiles(ref);
  }

  Future<void> _setUngroupedEnabled(bool enabled) async {
    await ref.read(pmtilesRepositoryProvider).setUngroupedEnabled(
          enabled: enabled,
        );
    refreshPmtiles(ref);
  }

  Future<void> _assignFileGroup(String fileId, String? groupId) async {
    await ref.read(pmtilesRepositoryProvider).setFileGroup(
          fileId,
          groupId: groupId,
        );
    refreshPmtiles(ref);
  }

  Future<void> _deleteGroup(PmtilesGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete tile group?'),
          content: Text(
            'Delete "${group.name}"? Files in this group will become ungrouped.',
          ),
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

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(pmtilesRepositoryProvider).deleteGroup(group.id);
    refreshPmtiles(ref);
  }

  Future<void> _deleteFile(String id, String name) async {
    _log.info('🗑️ Delete pressed', data: 'id=$id name="$name"');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete PMTiles file?'),
          content: Text('Remove "$name" from the server?'),
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

  Future<void> _exportMapData() async {
    setState(() => _isExportingMapData = true);
    try {
      final repository = ref.read(mapDataRepositoryProvider);
      final jsonText = await repository.fetchBackupJson();
      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
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

      if (restartNow == true && kIsWeb) {
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
    final filesAsync = ref.watch(pmtilesCatalogProvider);
    final groupsAsync = ref.watch(pmtilesGroupsProvider);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final angleDisplayFormat = ref.watch(angleDisplayFormatProvider);
    final circleSizeDisplay = ref.watch(circleSizeDisplayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
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
          const SizedBox(height: 32),
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
          const SizedBox(height: 32),
          Text(
            'PMTiles Maps',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Organize offline map archives into groups and choose which ones '
            'are drawn on the map. Only the best-matching enabled archive is '
            'shown at once to keep the map responsive.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: _createPmtilesGroup,
                child: const Text('New group'),
              ),
              OutlinedButton(
                onPressed: _enableAllPmtiles,
                child: const Text('Show all on map'),
              ),
              OutlinedButton(
                onPressed: _disableAllPmtiles,
                child: const Text('Hide all from map'),
              ),
            ],
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
              return groupsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  _log.error(
                    '📋 Settings groups load failed',
                    error: error,
                    stackTrace: stackTrace,
                  );
                  return Text('Failed to load groups: $error');
                },
                data: (groups) {
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

                  final enabledCount =
                      files.where((file) => file.enabledOnMap).length;
                  final filesByGroupId = <String, List<PmtilesFile>>{};
                  final ungroupedFiles = <PmtilesFile>[];

                  for (final file in files) {
                    final groupId = file.groupId;
                    if (groupId == null) {
                      ungroupedFiles.add(file);
                    } else {
                      filesByGroupId.putIfAbsent(groupId, () => []).add(file);
                    }
                  }
                  ungroupedFiles.sort(
                    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                  );
                  for (final groupFiles in filesByGroupId.values) {
                    groupFiles.sort(
                      (a, b) =>
                          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                    );
                  }
                  final sortedGroups = [...groups]
                    ..sort(
                      (a, b) =>
                          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                    );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '$enabledCount of ${files.length} shown on map',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      for (final group in sortedGroups) ...[
                        _PmtilesGroupSection(
                          group: group,
                          files: filesByGroupId[group.id] ?? const [],
                          groups: groups,
                          onToggleGroup: (enabled) =>
                              _setGroupEnabled(group.id, enabled),
                          onDeleteGroup: () => _deleteGroup(group),
                          onToggleFile: (file, enabled) =>
                              _setFileEnabled(file.id, enabled),
                          onAssignGroup: _assignFileGroup,
                          onDeleteFile: _deleteFile,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _PmtilesGroupSection(
                        isUngrouped: true,
                        files: ungroupedFiles,
                        groups: groups,
                        onToggleGroup: _setUngroupedEnabled,
                        onToggleFile: (file, enabled) =>
                            _setFileEnabled(file.id, enabled),
                        onAssignGroup: _assignFileGroup,
                        onDeleteFile: _deleteFile,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PmtilesGroupSection extends StatelessWidget {
  const _PmtilesGroupSection({
    this.group,
    this.isUngrouped = false,
    required this.files,
    required this.groups,
    this.onToggleGroup,
    this.onDeleteGroup,
    required this.onToggleFile,
    required this.onAssignGroup,
    required this.onDeleteFile,
  });

  final PmtilesGroup? group;
  final bool isUngrouped;
  final List<PmtilesFile> files;
  final List<PmtilesGroup> groups;
  final ValueChanged<bool>? onToggleGroup;
  final VoidCallback? onDeleteGroup;
  final void Function(PmtilesFile file, bool enabled) onToggleFile;
  final Future<void> Function(String fileId, String? groupId) onAssignGroup;
  final Future<void> Function(String id, String name) onDeleteFile;

  bool get _groupEnabled =>
      files.isNotEmpty && files.every((file) => file.enabledOnMap);

  @override
  Widget build(BuildContext context) {
    final enabledCount = files.where((file) => file.enabledOnMap).length;
    final title = isUngrouped ? 'Ungrouped' : group!.name;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: isUngrouped || group != null,
        title: Text(title),
        subtitle: Text(
          files.isEmpty
              ? 'No files assigned'
              : '$enabledCount of ${files.length} shown on map',
        ),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          if (onToggleGroup != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    isUngrouped ? 'Show ungrouped on map' : 'Show group on map',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: _groupEnabled,
                    onChanged: files.isEmpty ? null : onToggleGroup,
                  ),
                  if (!isUngrouped && onDeleteGroup != null)
                    IconButton(
                      tooltip: 'Delete group',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDeleteGroup,
                    ),
                ],
              ),
            ),
          if (files.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isUngrouped
                    ? 'Files not assigned to a group appear here.'
                    : 'Assign files to this group from the menu on each tile.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            for (var i = 0; i < files.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _PmtilesFileTile(
                file: files[i],
                groups: groups,
                onToggleEnabled: (enabled) => onToggleFile(files[i], enabled),
                onAssignGroup: (groupId) => onAssignGroup(files[i].id, groupId),
                onDelete: () => onDeleteFile(files[i].id, files[i].name),
              ),
            ],
        ],
      ),
    );
  }
}

class _PmtilesFileTile extends StatelessWidget {
  const _PmtilesFileTile({
    required this.file,
    required this.groups,
    required this.onToggleEnabled,
    required this.onAssignGroup,
    required this.onDelete,
  });

  final PmtilesFile file;
  final List<PmtilesGroup> groups;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<String?> onAssignGroup;
  final VoidCallback onDelete;

  List<PmtilesGroup> get _sortedGroups => [
        ...groups,
      ]..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        file.enabledOnMap ? Icons.layers : Icons.layers_outlined,
        color: file.enabledOnMap ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(file.name),
      subtitle: Text('${file.formattedSize} • ${file.addedAt.toLocal()}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String?>(
            tooltip: 'Assign group',
            icon: const Icon(Icons.folder_outlined),
            onSelected: onAssignGroup,
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: null,
                  child: Text('Ungrouped'),
                ),
                for (final group in _sortedGroups)
                  PopupMenuItem(
                    value: group.id,
                    child: Text(group.name),
                  ),
              ];
            },
          ),
          Switch(
            value: file.enabledOnMap,
            onChanged: onToggleEnabled,
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
