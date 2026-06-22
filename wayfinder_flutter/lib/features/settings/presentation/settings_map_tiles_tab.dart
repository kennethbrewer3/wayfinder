import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../data/app_settings_repository.dart';
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
  bool _isSavingStoragePath = false;
  final _storagePathController = TextEditingController();

  @override
  void dispose() {
    _storagePathController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoragePath();
    });
  }

  Future<void> _loadStoragePath() async {
    try {
      final settings =
          await ref.read(appSettingsRepositoryProvider).getPmtilesStoragePath();
      if (!mounted) {
        return;
      }
      setState(() {
        _storagePathController.text = settings.storagePath;
      });
    } catch (error, stackTrace) {
      _log.error(
        '🗺️ PMTiles storage path load failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveStoragePath() async {
    final l10n = AppLocalizations.of(context)!;
    final storagePath = _storagePathController.text.trim();
    if (storagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapTilesStoragePathRequired)),
      );
      return;
    }

    setState(() => _isSavingStoragePath = true);
    try {
      final settings = await ref
          .read(appSettingsRepositoryProvider)
          .updatePmtilesStoragePath(storagePath);
      refreshPmtiles(ref);
      if (!mounted) {
        return;
      }
      final savedL10n = AppLocalizations.of(context)!;
      setState(() {
        _storagePathController.text = settings.storagePath;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedL10n.mapTilesFolderSaved(settings.effectiveStoragePath),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🗺️ PMTiles storage path save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.mapTilesFolderSaveFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingStoragePath = false);
      }
    }
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
      final l10n = AppLocalizations.of(context)!;
      _log.success('📤 Upload UI flow complete', data: '"${entry.name}"');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapTilesUploadSuccess(entry.name))),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📤 Upload UI flow failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapTilesUploadFailed(error.toString()))),
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mapTilesAllHidden)),
    );
  }

  Future<void> _createPmtilesGroup() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.mapTilesNewGroupTitle),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.mapTilesGroupNameLabel,
              hintText: l10n.mapTilesGroupNameHint,
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(nameController.text.trim()),
              child: Text(l10n.actionCreate),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapTilesGroupCreated(name))),
      );
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapTilesGroupCreateFailed(error.toString()))),
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

  Future<void> _toggleFileGroupMembership(
    String fileId,
    String groupId, {
    required bool include,
  }) async {
    final repository = ref.read(pmtilesRepositoryProvider);
    if (include) {
      await repository.addFileToGroup(fileId, groupId);
    } else {
      await repository.removeFileFromGroup(fileId, groupId);
    }
    refreshPmtiles(ref);
  }

  bool _fileVisibleOnMap(
    PmtilesFile file,
    Map<String, PmtilesGroup> groupsById,
  ) {
    if (file.enabledOnMap) {
      return true;
    }
    return file.groupIds.any(
      (groupId) => groupsById[groupId]?.showOnMap ?? false,
    );
  }

  Future<void> _deleteGroup(PmtilesGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.mapTilesDeleteGroupTitle),
          content: Text(l10n.mapTilesDeleteGroupMessage(group.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionDelete),
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
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.mapTilesDeleteFileTitle),
          content: Text(l10n.mapTilesDeleteFileMessage(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionDelete),
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mapTilesFileDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filesAsync = ref.watch(pmtilesCatalogProvider);
    final groupsAsync = ref.watch(pmtilesGroupsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.mapTilesFolderTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.mapTilesFolderDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _storagePathController,
          decoration: InputDecoration(
            labelText: l10n.mapTilesStoragePathLabel,
            hintText: '/Volumes/maptiles',
            border: const OutlineInputBorder(),
          ),
          autocorrect: false,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _isSavingStoragePath ? null : _saveStoragePath,
          child: Text(
            _isSavingStoragePath ? l10n.actionSaving : l10n.mapTilesSaveAndRescan,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.mapTilesMapsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.mapTilesMapsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: _createPmtilesGroup,
              child: Text(l10n.mapTilesNewGroup),
            ),
            OutlinedButton(
              onPressed: _enableAllPmtiles,
              child: Text(l10n.mapTilesShowAllOnMap),
            ),
            OutlinedButton(
              onPressed: _disableAllPmtiles,
              child: Text(l10n.mapTilesHideAllFromMap),
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
          label: Text(
            _isUploading ? l10n.actionUploading : l10n.mapTilesUploadButton,
          ),
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
            return Text(l10n.mapTilesFilesLoadFailed(error.toString()));
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
                return Text(l10n.mapTilesGroupsLoadFailed(error.toString()));
              },
              data: (groups) {
                if (files.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.mapTilesNoFiles,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                final groupsById = {for (final group in groups) group.id: group};
                final enabledCount = files
                    .where((file) => _fileVisibleOnMap(file, groupsById))
                    .length;
                final filesByGroupId = <String, List<PmtilesFile>>{};
                final ungroupedFiles = <PmtilesFile>[];

                for (final file in files) {
                  if (file.groupIds.isEmpty) {
                    ungroupedFiles.add(file);
                  } else {
                    for (final groupId in file.groupIds) {
                      filesByGroupId.putIfAbsent(groupId, () => []).add(file);
                    }
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
                      l10n.mapTilesShownOnMapCount(enabledCount, files.length),
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
                        onToggleGroupMembership: _toggleFileGroupMembership,
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
                      onToggleGroupMembership: _toggleFileGroupMembership,
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
    required this.onToggleGroupMembership,
    required this.onDeleteFile,
  });

  final PmtilesGroup? group;
  final bool isUngrouped;
  final List<PmtilesFile> files;
  final List<PmtilesGroup> groups;
  final ValueChanged<bool>? onToggleGroup;
  final VoidCallback? onDeleteGroup;
  final void Function(PmtilesFile file, bool enabled) onToggleFile;
  final Future<void> Function(
    String fileId,
    String groupId, {
    required bool include,
  }) onToggleGroupMembership;
  final Future<void> Function(String id, String name) onDeleteFile;

  bool get _groupEnabled => isUngrouped
      ? files.isNotEmpty && files.every((file) => file.enabledOnMap)
      : group?.showOnMap ?? false;

  int _visibleCount() {
    if (isUngrouped) {
      return files.where((file) => file.enabledOnMap).length;
    }
    final showOnMap = group?.showOnMap ?? false;
    return files
        .where((file) => file.enabledOnMap || showOnMap)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabledCount = _visibleCount();
    final title = isUngrouped ? l10n.mapTilesUngrouped : group!.name;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: isUngrouped || group != null,
        title: Text(title),
        subtitle: Text(
          files.isEmpty
              ? l10n.mapTilesNoFilesAssigned
              : l10n.mapTilesShownOnMapCount(enabledCount, files.length),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          if (onToggleGroup != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    isUngrouped
                        ? l10n.mapTilesShowUngroupedOnMap
                        : l10n.mapTilesShowGroupOnMap,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: _groupEnabled,
                    onChanged: files.isEmpty ? null : onToggleGroup,
                  ),
                  if (!isUngrouped && onDeleteGroup != null)
                    IconButton(
                      tooltip: l10n.mapTilesDeleteGroupTooltip,
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
                    ? l10n.mapTilesUngroupedEmptyMessage
                    : l10n.mapTilesGroupEmptyMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            for (var i = 0; i < files.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _PmtilesFileTile(
                file: files[i],
                groups: groups,
                visibleOnMap: isUngrouped
                    ? files[i].enabledOnMap
                    : files[i].enabledOnMap || (group?.showOnMap ?? false),
                onToggleEnabled: (enabled) => onToggleFile(files[i], enabled),
                onToggleGroupMembership: (groupId, include) =>
                    onToggleGroupMembership(
                  files[i].id,
                  groupId,
                  include: include,
                ),
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
    required this.visibleOnMap,
    required this.onToggleEnabled,
    required this.onToggleGroupMembership,
    required this.onDelete,
  });

  final PmtilesFile file;
  final List<PmtilesGroup> groups;
  final bool visibleOnMap;
  final ValueChanged<bool> onToggleEnabled;
  final Future<void> Function(String groupId, bool include)
      onToggleGroupMembership;
  final VoidCallback onDelete;

  List<PmtilesGroup> get _sortedGroups => [
        ...groups,
      ]..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupLabel = file.groupIds.isEmpty
        ? l10n.mapTilesNoGroups
        : l10n.mapTilesGroupCount(file.groupIds.length);

    return ListTile(
      leading: Icon(
        visibleOnMap ? Icons.layers : Icons.layers_outlined,
        color: visibleOnMap ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(file.name),
      subtitle: Text(
        '${file.formattedSize} • ${file.addedAt.toLocal()} • $groupLabel',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            tooltip: l10n.mapTilesManageGroupsTooltip,
            icon: Icon(
              file.groupIds.isEmpty
                  ? Icons.folder_outlined
                  : Icons.folder_copy_outlined,
            ),
            onSelected: (groupId) async {
              final include = !file.isInGroup(groupId);
              await onToggleGroupMembership(groupId, include);
            },
            itemBuilder: (context) {
              return [
                for (final group in _sortedGroups)
                  PopupMenuItem(
                    value: group.id,
                    child: Row(
                      children: [
                        Icon(
                          file.isInGroup(group.id)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(group.name)),
                      ],
                    ),
                  ),
              ];
            },
          ),
          Switch(
            value: visibleOnMap,
            onChanged: onToggleEnabled,
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
