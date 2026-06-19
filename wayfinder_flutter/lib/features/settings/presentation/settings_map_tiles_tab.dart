import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../models/pmtiles_file.dart';
import '../models/pmtiles_group.dart';
import '../providers/pmtiles_providers.dart';

class SettingsMapTilesTab extends ConsumerStatefulWidget {
  const SettingsMapTilesTab({super.key});

  @override
  ConsumerState<SettingsMapTilesTab> createState() => _SettingsMapTilesTabState();
}

class _SettingsMapTilesTabState extends ConsumerState<SettingsMapTilesTab> {
  static final _log = AppLogger.logSettings;

  bool _isUploading = false;
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

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(pmtilesCatalogProvider);
    final groupsAsync = ref.watch(pmtilesGroupsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
