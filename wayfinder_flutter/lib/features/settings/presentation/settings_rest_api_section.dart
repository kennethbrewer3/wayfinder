import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/rest_api_key_storage.dart';
import '../data/app_settings_repository.dart';

final restApiKeyStatusProvider = FutureProvider<RestApiKeyInfo>((ref) async {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return repository.getRestApiKeyStatus();
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

  Future<void> _saveLocalKey() async {
    await RestApiKeyStorage.write(_localKeyController.text);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsRestApiKeySaved)),
    );
  }

  Future<void> _generateKey() async {
    setState(() => _busy = true);
    try {
      final info =
          await ref.read(appSettingsRepositoryProvider).generateRestApiKey();
      ref.invalidate(restApiKeyStatusProvider);
      if (info.apiKey != null) {
        await RestApiKeyStorage.write(info.apiKey);
        _localKeyController.text = info.apiKey!;
      }
      if (!mounted) {
        return;
      }
      await _showGeneratedKeyDialog(info);
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

  Future<void> _clearKey() async {
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
      await ref.read(appSettingsRepositoryProvider).clearRestApiKey();
      ref.invalidate(restApiKeyStatusProvider);
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

  Future<void> _showGeneratedKeyDialog(RestApiKeyInfo info) async {
    final l10n = AppLocalizations.of(context)!;
    final apiKey = info.apiKey;
    if (apiKey == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRestApiGeneratedTitle),
        content: SelectableText(
          '$apiKey\n\n${l10n.settingsRestApiGeneratedMessage}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: apiKey));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsRestApiCopied)),
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

    return statusAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text(l10n.settingsRestApiLoadFailed(error.toString())),
      data: (status) {
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
            if (status.keyPreview != null) ...[
              const SizedBox(height: 8),
              _InfoChip(
                label: l10n.settingsRestApiPreviewLabel,
                value: status.keyPreview!,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _generateKey,
                  icon: const Icon(Icons.vpn_key_outlined),
                  label: Text(
                    status.enabled
                        ? l10n.settingsRestApiRotateAction
                        : l10n.settingsRestApiGenerateAction,
                  ),
                ),
                if (status.enabled)
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _clearKey,
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
