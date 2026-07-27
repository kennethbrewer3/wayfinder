import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../core/app_globals.dart';
import '../core/server_config.dart';
import '../core/widgets/http_url_field.dart';
import '../features/access/providers/api_server_url_view_model.dart';

/// API + web server URL editor for connection / sign-in screens.
///
/// - **Web:** inline [TextField]s (physical keyboard; no soft-IME issues).
/// - **iOS/Android:** tappable summary rows (no IME). Tap opens a full-screen
///   route on AuthGate's nested [Navigator] so soft-keyboard editing is not
///   under AuthGate / MediaQuery rebuilds.
class ServerUrlSetupCard extends ConsumerStatefulWidget {
  const ServerUrlSetupCard({super.key});

  @override
  ConsumerState<ServerUrlSetupCard> createState() => _ServerUrlSetupCardState();
}

class _ServerUrlSetupCardState extends ConsumerState<ServerUrlSetupCard> {
  late final TextEditingController _apiController;
  late final TextEditingController _webController;

  /// Soft-keyboard platforms where AuthGate rebuilds fight the IME.
  bool get _useIsolatedEditor =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _apiController = TextEditingController(
      text: apiUrlForDeviceForm(appServerConfig.apiUrl) ?? '',
    );
    _webController = TextEditingController(
      text: webUrlForDeviceForm(appServerConfig.webUrl) ?? '',
    );
  }

  @override
  void dispose() {
    _apiController.dispose();
    _webController.dispose();
    super.dispose();
  }

  void _applyControllers(AppServerConfig config) {
    if (_apiController.text != config.apiUrl) {
      _apiController.value = TextEditingValue(
        text: config.apiUrl,
        selection: TextSelection.collapsed(offset: config.apiUrl.length),
      );
    }
    if (_webController.text != config.webUrl) {
      _webController.value = TextEditingValue(
        text: config.webUrl,
        selection: TextSelection.collapsed(offset: config.webUrl.length),
      );
    }
  }

  Future<void> _save({String? apiRaw, String? webRaw}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final config = await ref
        .read(apiServerUrlViewModelProvider.notifier)
        .save(
          apiUrl: apiRaw ?? _apiController.text,
          webUrl: webRaw ?? _webController.text,
        );
    if (config == null || !mounted) {
      return;
    }
    _applyControllers(config);
    setState(() {});
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.accessServerUrlsApplied(config.apiUrl, config.webUrl),
        ),
      ),
    );
  }

  Future<void> _openMobileEditor() async {
    final l10n = AppLocalizations.of(context)!;
    final edited = await Navigator.of(context).push<_ServerUrlEditResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _ServerUrlsEditorPage(
          initialApiUrl: _apiController.text,
          initialWebUrl: _webController.text,
          title: l10n.settingsEditServerUrls,
          apiLabel: l10n.settingsServerUrl,
          apiHint: l10n.accessServerUrlHint,
          apiHelp: l10n.accessServerUrlHelp,
          webLabel: l10n.settingsWebServerUrl,
          webHint: l10n.accessWebServerUrlHint,
          webHelp: l10n.accessWebServerUrlHelp,
          saveLabel: l10n.settingsSaveServerUrl,
        ),
      ),
    );
    if (edited == null || !mounted) {
      return;
    }
    _apiController.value = TextEditingValue(
      text: edited.apiUrl,
      selection: TextSelection.collapsed(offset: edited.apiUrl.length),
    );
    _webController.value = TextEditingValue(
      text: edited.webUrl,
      selection: TextSelection.collapsed(offset: edited.webUrl.length),
    );
    await _save(apiRaw: edited.apiUrl, webRaw: edited.webUrl);
  }

  Widget _mobileSummaryRow({
    required String label,
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final displayed = value.trim();
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayed.isEmpty ? hint : displayed,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: displayed.isEmpty
                            ? theme.hintColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsServerConnectionTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.settingsServerConnectionDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (_useIsolatedEditor) ...[
          _mobileSummaryRow(
            label: l10n.settingsServerUrl,
            value: _apiController.text,
            hint: l10n.accessServerUrlHint,
            onTap: _openMobileEditor,
          ),
          const SizedBox(height: 12),
          _mobileSummaryRow(
            label: l10n.settingsWebServerUrl,
            value: _webController.text,
            hint: l10n.accessWebServerUrlHint,
            onTap: _openMobileEditor,
          ),
        ] else ...[
          HttpUrlField(
            controller: _apiController,
            textInputAction: TextInputAction.next,
            labelText: l10n.settingsServerUrl,
            hintText: l10n.accessServerUrlHint,
            helperText: l10n.accessServerUrlHelp,
          ),
          const SizedBox(height: 12),
          HttpUrlField(
            controller: _webController,
            textInputAction: TextInputAction.done,
            labelText: l10n.settingsWebServerUrl,
            hintText: l10n.accessWebServerUrlHint,
            helperText: l10n.accessWebServerUrlHelp,
            onSubmitted: (_) => _save(),
          ),
        ],
        const _ApiServerUrlMessages(),
        const SizedBox(height: 12),
        _ApiServerUrlSaveButton(
          onPressed: () async {
            if (_useIsolatedEditor) {
              final apiEmpty = _apiController.text.trim().isEmpty;
              final webEmpty = _webController.text.trim().isEmpty;
              if (apiEmpty || webEmpty) {
                await _openMobileEditor();
                return;
              }
              await _save();
              return;
            }
            await _save();
          },
        ),
      ],
    );
  }
}

class _ServerUrlEditResult {
  const _ServerUrlEditResult({required this.apiUrl, required this.webUrl});

  final String apiUrl;
  final String webUrl;
}

/// Full-screen API + web URL editor — owns its own controllers / focus.
class _ServerUrlsEditorPage extends StatefulWidget {
  const _ServerUrlsEditorPage({
    required this.initialApiUrl,
    required this.initialWebUrl,
    required this.title,
    required this.apiLabel,
    required this.apiHint,
    required this.apiHelp,
    required this.webLabel,
    required this.webHint,
    required this.webHelp,
    required this.saveLabel,
  });

  final String initialApiUrl;
  final String initialWebUrl;
  final String title;
  final String apiLabel;
  final String apiHint;
  final String apiHelp;
  final String webLabel;
  final String webHint;
  final String webHelp;
  final String saveLabel;

  @override
  State<_ServerUrlsEditorPage> createState() => _ServerUrlsEditorPageState();
}

class _ServerUrlsEditorPageState extends State<_ServerUrlsEditorPage> {
  late final TextEditingController _apiController;
  late final TextEditingController _webController;
  late final FocusNode _apiFocusNode;

  @override
  void initState() {
    super.initState();
    _apiController = TextEditingController(text: widget.initialApiUrl);
    _webController = TextEditingController(text: widget.initialWebUrl);
    _apiFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _apiFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _apiController.dispose();
    _webController.dispose();
    _apiFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _ServerUrlEditResult(
        apiUrl: _apiController.text,
        webUrl: _webController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text(
              widget.apiHelp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            HttpUrlField(
              controller: _apiController,
              focusNode: _apiFocusNode,
              textInputAction: TextInputAction.next,
              labelText: widget.apiLabel,
              hintText: widget.apiHint,
            ),
            const SizedBox(height: 20),
            Text(
              widget.webHelp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            HttpUrlField(
              controller: _webController,
              textInputAction: TextInputAction.done,
              labelText: widget.webLabel,
              hintText: widget.webHint,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.saveLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiServerUrlMessages extends ConsumerWidget {
  const _ApiServerUrlMessages();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      apiServerUrlViewModelProvider.select((s) => s.errorMessage),
    );
    if (error == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        error,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _ApiServerUrlSaveButton extends ConsumerWidget {
  const _ApiServerUrlSaveButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final saving = ref.watch(
      apiServerUrlViewModelProvider.select((s) => s.saving),
    );

    return FilledButton(
      onPressed: saving ? null : onPressed,
      child: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(l10n.settingsSaveServerUrl),
    );
  }
}
