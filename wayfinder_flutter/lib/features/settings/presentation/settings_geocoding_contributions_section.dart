import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/file_save.dart';
import '../../../core/format/locale_count_format.dart';
import '../../../core/logging/app_logger.dart';
import '../../geocoding/data/geocoding_repository.dart';
import '../../geocoding/models/geocoding_contribution.dart';
import '../../geocoding/models/geocoding_models.dart';
import '../../geocoding/providers/geocoding_providers.dart';

class SettingsGeocodingContributionsSection extends ConsumerStatefulWidget {
  const SettingsGeocodingContributionsSection({
    super.key,
    required this.settings,
    required this.enabled,
    required this.serverConfigured,
  });

  final GeocodingImportState settings;
  final bool enabled;
  final bool serverConfigured;

  @override
  ConsumerState<SettingsGeocodingContributionsSection> createState() =>
      _SettingsGeocodingContributionsSectionState();
}

enum _ContributionListFilter { all, yours, community }

class _SettingsGeocodingContributionsSectionState
    extends ConsumerState<SettingsGeocodingContributionsSection> {
  static final _log = AppLogger.logSettings;

  late final TextEditingController _crowdsourceUrlController;
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _notesController = TextEditingController();
  final _countryController = TextEditingController();
  int? _editingId;
  bool _savingContribution = false;
  List<GeocodingContribution> _contributions = const [];
  bool _loadingContributions = false;
  String? _loadError;
  _ContributionListFilter _listFilter = _ContributionListFilter.all;
  bool _archiveBusy = false;
  bool _crowdsourceBusy = false;
  bool _savingCrowdsourceUrl = false;

  @override
  void initState() {
    super.initState();
    _crowdsourceUrlController = TextEditingController(
      text: widget.settings.crowdsourceSourceUrl,
    );
    if (widget.serverConfigured) {
      _loadContributions();
    }
  }

  @override
  void didUpdateWidget(SettingsGeocodingContributionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.crowdsourceSourceUrl !=
        widget.settings.crowdsourceSourceUrl) {
      _crowdsourceUrlController.text = widget.settings.crowdsourceSourceUrl;
    }
    if (widget.serverConfigured &&
        (!oldWidget.serverConfigured ||
            oldWidget.settings.contributionCount !=
                widget.settings.contributionCount)) {
      _loadContributions();
    }
    if (!widget.serverConfigured && oldWidget.serverConfigured) {
      setState(() {
        _contributions = const [];
        _loadError = null;
      });
    }
  }

  @override
  void dispose() {
    _crowdsourceUrlController.dispose();
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() => _editingId = null);
    _nameController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _notesController.clear();
    _countryController.clear();
  }

  void _startEdit(GeocodingContribution row) {
    setState(() => _editingId = row.id);
    _nameController.text = row.name;
    _latitudeController.text = row.latitude.toString();
    _longitudeController.text = row.longitude.toString();
    _notesController.text = row.notes ?? '';
    _countryController.text = row.countryCode ?? '';
  }

  Future<void> _saveFromForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (!widget.serverConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionsConfigureServerHint)),
      );
      return;
    }

    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();
    final countryCode = _countryController.text.trim();
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionNameLabel)),
      );
      return;
    }
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionInvalidCoordinates)),
      );
      return;
    }

    setState(() => _savingContribution = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      if (_editingId == null) {
        await repository.createContribution(
          name: name,
          latitude: latitude,
          longitude: longitude,
          notes: notes,
          countryCode: countryCode,
        );
      } else {
        await repository.updateContribution(
          id: _editingId!,
          name: name,
          latitude: latitude,
          longitude: longitude,
          notes: notes,
          countryCode: countryCode,
        );
      }
      refreshGeocoding(ref);
      await _loadContributions();
      _clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionSaved)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Contribution save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _savingContribution = false);
      }
    }
  }

  Future<void> _loadContributions() async {
    if (!widget.serverConfigured) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _loadingContributions = true;
      _loadError = null;
    });
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final rows = await repository.listContributions();
      if (!mounted) return;
      setState(() => _contributions = rows);
    } catch (error, stackTrace) {
      _log.error(
        '📍 Contribution list failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _contributions = const [];
      });
    } finally {
      if (mounted) {
        setState(() => _loadingContributions = false);
      }
    }
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _deleteContribution(GeocodingContribution contribution) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingContributionDeleteTitle,
      message: l10n.geocodingContributionDeleteMessage(contribution.name),
      confirmLabel: l10n.actionDelete,
    );
    if (!confirmed || !mounted) {
      return;
    }

    try {
      final repository = ref.read(geocodingRepositoryProvider);
      await repository.deleteContribution(contribution.id);
      refreshGeocoding(ref);
      await _loadContributions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionDeleted)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Contribution delete failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _exportContributions() async {
    setState(() => _archiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final jsonText = await repository.exportContributionsArchive();
      final timestamp =
          DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final saved = await saveTextFile(
        fileName: 'wayfinder-geocode-contributions-$timestamp.json',
        contents: jsonText,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.geocodingContributionDataExported)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '📍 Contribution export failed',
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
        setState(() => _archiveBusy = false);
      }
    }
  }

  Future<void> _importContributions() async {
    final jsonText = await pickTextFileContents();
    if (jsonText == null || !mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingImportContributionArchiveTitle,
      message: l10n.geocodingImportContributionArchiveMessage,
      confirmLabel: l10n.actionImport,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _archiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final rowCount = await repository.importContributionsArchive(jsonText);
      refreshGeocoding(ref);
      await _loadContributions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.geocodingContributionArchiveImported(rowCount)),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Contribution import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingImportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _archiveBusy = false);
      }
    }
  }

  Future<void> _clearContributions() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingRemoveAllContributionsTitle,
      message: l10n.geocodingRemoveAllContributionsMessage,
      confirmLabel: l10n.actionRemoveAll,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _archiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final removed = await repository.clearContributions();
      refreshGeocoding(ref);
      await _loadContributions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingContributionsRemoved(removed))),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Contribution clear failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingRemoveFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _archiveBusy = false);
      }
    }
  }

  Future<void> _saveCrowdsourceUrl() async {
    final l10n = AppLocalizations.of(context)!;
    final trimmed = _crowdsourceUrlController.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingCrowdsourceUrlRequired)),
      );
      return;
    }

    setState(() => _savingCrowdsourceUrl = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      await repository.updateCrowdsourceConfig(crowdsourceSourceUrl: trimmed);
      refreshGeocoding(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingCrowdsourceUrlSaved)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Crowdsource URL save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _savingCrowdsourceUrl = false);
      }
    }
  }

  Future<void> _importCrowdsource() async {
    setState(() => _crowdsourceBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final rowCount = await repository.importCrowdsource(
        sourceUrl: _crowdsourceUrlController.text.trim(),
      );
      refreshGeocoding(ref);
      await _loadContributions();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingCrowdsourceImported(rowCount))),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Crowdsource import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingImportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _crowdsourceBusy = false);
      }
    }
  }

  Future<void> _submitCrowdsource() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingCrowdsourceSubmitTitle,
      message: l10n.geocodingCrowdsourceSubmitMessage,
      confirmLabel: l10n.geocodingCrowdsourceSubmitAction,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _crowdsourceBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final result = await repository.submitCrowdsource();
      if (!mounted) return;

      if (result.bundleJson != null && !result.uploadedToGit) {
        if (!mounted) return;
        final timestamp =
            DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
        await saveTextFile(
          fileName: 'wayfinder-geocode-crowdsource-$timestamp.json',
          contents: result.bundleJson!,
        );
      }

      if (!mounted) return;
      final message = result.uploadedToGit
          ? l10n.geocodingCrowdsourceSubmitted(result.submittedCount)
          : (result.message ??
              l10n.geocodingCrowdsourceBundleSaved(result.submittedCount));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Crowdsource submit failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _crowdsourceBusy = false);
      }
    }
  }

  String _formatCount(int value) {
    return formatLocaleCount(value, Localizations.localeOf(context).toString());
  }

  List<GeocodingContribution> get _filteredContributions {
    return switch (_listFilter) {
      _ContributionListFilter.all => _contributions,
      _ContributionListFilter.yours =>
        _contributions.where((row) => !row.importedFromCrowd).toList(),
      _ContributionListFilter.community =>
        _contributions.where((row) => row.importedFromCrowd).toList(),
    };
  }

  int get _yoursCount =>
      _contributions.where((row) => !row.importedFromCrowd).length;

  int get _communityCount =>
      _contributions.where((row) => row.importedFromCrowd).length;

  Widget _buildSourceChip(AppLocalizations l10n, GeocodingContribution row) {
    final label = row.importedFromCrowd
        ? l10n.geocodingContributionsSourceCommunity
        : l10n.geocodingContributionsSourceYours;
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controlsEnabled =
        widget.serverConfigured && widget.enabled && !_archiveBusy && !_crowdsourceBusy;
    final archiveEnabled = widget.serverConfigured && widget.enabled && !_archiveBusy;
    final filtered = _filteredContributions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.serverConfigured)
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.geocodingContributionsConfigureServerHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!widget.serverConfigured) const SizedBox(height: 12),
        Text(
          l10n.geocodingContributionsSectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.geocodingContributionsSectionDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text(
          _editingId == null
              ? l10n.geocodingContributionFormTitle
              : l10n.geocodingContributionFormEditTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.geocodingContributionNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: widget.serverConfigured && !_savingContribution,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitudeController,
                        decoration: InputDecoration(
                          labelText: l10n.geocodingContributionLatitudeLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled:
                            widget.serverConfigured && !_savingContribution,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _longitudeController,
                        decoration: InputDecoration(
                          labelText: l10n.geocodingContributionLongitudeLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled:
                            widget.serverConfigured && !_savingContribution,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.geocodingContributionNotesLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  enabled: widget.serverConfigured && !_savingContribution,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: l10n.geocodingContributionCountryLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 2,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UpperCaseTextFormatter()],
                  enabled: widget.serverConfigured && !_savingContribution,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: widget.serverConfigured &&
                              !_savingContribution &&
                              widget.enabled
                          ? _saveFromForm
                          : null,
                      icon: _savingContribution
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(l10n.geocodingContributionSaveAction),
                    ),
                    OutlinedButton(
                      onPressed: _savingContribution ? null : _clearForm,
                      child: Text(l10n.geocodingContributionClearForm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.geocodingContributionsListTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.geocodingStatusLabel(
            l10n.geocodingStatusReady(
              _formatCount(widget.settings.contributionCount),
              l10n.geocodingRowLabelContributions,
            ),
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_yoursCount > 0 || _communityCount > 0) ...[
          const SizedBox(height: 4),
          Text(
            '${l10n.geocodingContributionsFilterYours}: ${_formatCount(_yoursCount)} · '
            '${l10n.geocodingContributionsFilterCommunity}: ${_formatCount(_communityCount)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        SegmentedButton<_ContributionListFilter>(
          segments: [
            ButtonSegment(
              value: _ContributionListFilter.all,
              label: Text(l10n.geocodingContributionsFilterAll),
            ),
            ButtonSegment(
              value: _ContributionListFilter.yours,
              label: Text(l10n.geocodingContributionsFilterYours),
            ),
            ButtonSegment(
              value: _ContributionListFilter.community,
              label: Text(l10n.geocodingContributionsFilterCommunity),
            ),
          ],
          selected: {_listFilter},
          onSelectionChanged: controlsEnabled
              ? (selection) {
                  setState(() => _listFilter = selection.first);
                }
              : null,
        ),
        const SizedBox(height: 12),
        if (_loadingContributions)
          const LinearProgressIndicator()
        else if (_loadError != null)
          Text(
            l10n.geocodingServerUnreachable(
              ref.read(geocodingRepositoryProvider).baseUrl,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          )
        else if (!widget.serverConfigured)
          Text(
            l10n.geocodingContributionsConfigureServerHint,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else if (filtered.isEmpty)
          Text(
            l10n.geocodingContributionsEmpty,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final row = filtered[index];
                final subtitleParts = <String>[
                  '${row.latitude.toStringAsFixed(5)}, ${row.longitude.toStringAsFixed(5)}',
                  if (row.notes != null && row.notes!.isNotEmpty) row.notes!,
                ];
                return ListTile(
                  title: Text(row.name),
                  subtitle: Text(subtitleParts.join('\n')),
                  isThreeLine: row.notes != null && row.notes!.isNotEmpty,
                  leading: _buildSourceChip(l10n, row),
                  trailing: controlsEnabled
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.actionEdit,
                              onPressed: () => _startEdit(row),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: l10n.actionDelete,
                              onPressed: () => _deleteContribution(row),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: controlsEnabled && !_loadingContributions
                ? _loadContributions
                : null,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.actionRefresh),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.geocodingContributionsArchiveDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: archiveEnabled ? _exportContributions : null,
              icon: _archiveBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_outlined),
              label: Text(l10n.actionExport),
            ),
            OutlinedButton.icon(
              onPressed: archiveEnabled ? _importContributions : null,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.actionImport),
            ),
            OutlinedButton.icon(
              onPressed: archiveEnabled ? _clearContributions : null,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.actionRemoveAll),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          l10n.geocodingCrowdsourceSectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.geocodingCrowdsourceSectionDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _crowdsourceUrlController,
          decoration: InputDecoration(
            labelText: l10n.geocodingCrowdsourceUrlLabel,
            hintText: defaultCrowdsourceSourceUrl,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
          enabled: controlsEnabled,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: controlsEnabled && !_savingCrowdsourceUrl
                ? _saveCrowdsourceUrl
                : null,
            child: Text(
              _savingCrowdsourceUrl
                  ? l10n.actionSaving
                  : l10n.geocodingCrowdsourceSaveUrl,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: controlsEnabled ? _importCrowdsource : null,
              icon: _crowdsourceBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(l10n.geocodingCrowdsourceImportAction),
            ),
            OutlinedButton.icon(
              onPressed: controlsEnabled ? _submitCrowdsource : null,
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: Text(l10n.geocodingCrowdsourceSubmitAction),
            ),
          ],
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
