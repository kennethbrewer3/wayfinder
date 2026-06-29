import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/clipboard_copy.dart';
import '../../../core/rest_api_key_storage.dart';
import '../data/app_settings_repository.dart';

final restApiKeyStatusProvider = FutureProvider<RestApiKeyInfo>((ref) async {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return repository.getRestApiKeyStatus();
});

final restApiKeysProvider = FutureProvider<List<RestApiKey>>((ref) async {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return repository.listRestApiKeys();
});

class SettingsRestApiSection extends ConsumerStatefulWidget {
  const SettingsRestApiSection({super.key});

  @override
  ConsumerState<SettingsRestApiSection> createState() =>
      _SettingsRestApiSectionState();
}

class _SettingsRestApiSectionState extends ConsumerState<SettingsRestApiSection> {
  final _localKeyController = TextEditingController();
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _loadLocalKey();
  }

  @override
  void dispose() {
    _localKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalKey() async {
    final stored = await RestApiKeyStorage.read();
    if (!mounted) {
      return;
    }
    _localKeyController.text = stored ?? '';
  }

  void _refreshKeyProviders() {
    ref.invalidate(restApiKeyStatusProvider);
    ref.invalidate(restApiKeysProvider);
  }

  Future<void> _saveLocalKey() async {
    await RestApiKeyStorage.write(_localKeyController.text);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsRestApiKeySaved)),
    );
  }

  Future<String?> _promptForKeyName() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRestApiCreateAction),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.settingsRestApiCreateNameLabel,
            hintText: l10n.settingsRestApiCreateNameHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.settingsRestApiCreateAction),
          ),
        ],
      ),
    );
    controller.dispose();
    return name;
  }

  Future<void> _createKey() async {
    final name = await _promptForKeyName();
    if (name == null || name.isEmpty || !mounted) {
      return;
    }

    setState(() => _busy = true);
    try {
      final created =
          await ref.read(appSettingsRepositoryProvider).createRestApiKey(name);
      _refreshKeyProviders();
      await RestApiKeyStorage.write(created.apiKey);
      _localKeyController.text = created.apiKey;
      if (!mounted) {
        return;
      }
      await _showGeneratedKeyDialog(created.apiKey, created.key.name);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _deleteKey(RestApiKey key) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRestApiDeleteConfirmTitle),
        content: Text(l10n.settingsRestApiDeleteConfirmMessage(key.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.settingsRestApiDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(appSettingsRepositoryProvider).deleteRestApiKey(key.id);
      _refreshKeyProviders();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsRestApiDeleted)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _clearKeys() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRestApiClearConfirmTitle),
        content: Text(l10n.settingsRestApiClearConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.settingsRestApiClearAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(appSettingsRepositoryProvider).clearRestApiKeys();
      _refreshKeyProviders();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsRestApiCleared)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _showGeneratedKeyDialog(String apiKey, String name) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRestApiGeneratedTitle),
        content: SelectableText(
          '${l10n.settingsRestApiGeneratedFor(name)}\n\n$apiKey\n\n${l10n.settingsRestApiGeneratedMessage}',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final copied = await copyTextToClipboard(apiKey);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    copied
                        ? l10n.settingsRestApiCopied
                        : l10n.mapDebugOverlayCopyFailedTitle,
                  ),
                ),
              );
            },
            child: Text(l10n.settingsRestApiCopyAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusAsync = ref.watch(restApiKeyStatusProvider);
    final keysAsync = ref.watch(restApiKeysProvider);

    return statusAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text(l10n.settingsRestApiLoadFailed(error.toString())),
      data: (status) {
        return keysAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              Text(l10n.settingsRestApiLoadFailed(error.toString())),
          data: (keys) {
            final dateFormat = DateFormat.yMMMd().add_jm();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsRestApiTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsRestApiDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _InfoChip(
                  label: l10n.settingsRestApiStatusLabel,
                  value: status.enabled
                      ? l10n.settingsRestApiStatusEnabled
                      : l10n.settingsRestApiStatusDisabled,
                ),
                if (status.envKeyConfigured) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.settingsRestApiEnvKeyNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  l10n.settingsRestApiKeysTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (keys.isEmpty)
                  Text(
                    l10n.settingsRestApiKeysEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Column(
                    children: [
                      for (final key in keys)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(key.name),
                            subtitle: Text(
                              '${key.keyPreview}\n${dateFormat.format(key.createdAt.toLocal())}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: l10n.settingsRestApiDeleteAction,
                              onPressed: _busy ? null : () => _deleteKey(key),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : _createKey,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.settingsRestApiCreateAction),
                    ),
                    if (keys.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _clearKeys,
                        icon: const Icon(Icons.no_encryption_outlined),
                        label: Text(l10n.settingsRestApiClearAction),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.settingsRestApiClientKeyTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsRestApiClientKeyDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _localKeyController,
                  decoration: InputDecoration(
                    labelText: l10n.settingsRestApiClientKeyLabel,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _busy ? null : _saveLocalKey,
                    child: Text(l10n.settingsRestApiSaveClientKeyAction),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
